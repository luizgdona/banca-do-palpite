import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createPrismaMock, resetPrismaMock } from '../helpers/prisma-mock.js';

vi.mock('../../src/config/env.js', () => ({
  env: {
    JWT_SECRET: 'test-jwt-secret-at-least-32-chars!!',
    JWT_EXPIRES_IN: '15m',
    REFRESH_TOKEN_SECRET: 'test-refresh-secret',
    REFRESH_TOKEN_EXPIRES_IN: '30d',
    NODE_ENV: 'test',
    GOOGLE_CLIENT_ID: 'test-google-client-id',
  },
}));

// Import after mocking env
const { AuthService } = await import('../../src/modules/auth/auth.service.js');

const prisma = createPrismaMock();
const service = new AuthService(prisma as never);

const MOCK_USER = {
  id: 'user-1',
  name: 'Rafael',
  email: 'rafael@test.com',
  passwordHash: null as string | null,
  avatarUrl: null,
  provider: 'email' as const,
  providerId: null,
  fcmToken: null,
  createdAt: new Date(),
  updatedAt: new Date(),
};

beforeEach(() => {
  resetPrismaMock(prisma);
});

describe('AuthService.register', () => {
  it('cria usuário com email único', async () => {
    prisma.user.findUnique.mockResolvedValue(null);
    prisma.user.create.mockResolvedValue({ ...MOCK_USER, passwordHash: 'hashed' });
    prisma.refreshToken.create.mockResolvedValue({});

    const result = await service.register({
      name: 'Rafael',
      email: 'rafael@test.com',
      password: 'senha123',
    });

    expect(result.user.email).toBe('rafael@test.com');
    expect(result.accessToken).toBeTruthy();
    expect(result.refreshToken).toBeTruthy();
  });

  it('lança ConflictError para email duplicado', async () => {
    prisma.user.findUnique.mockResolvedValue(MOCK_USER);

    await expect(
      service.register({ name: 'X', email: 'rafael@test.com', password: 'senha123' }),
    ).rejects.toMatchObject({ statusCode: 409, code: 'CONFLICT' });
  });
});

describe('AuthService.login', () => {
  it('retorna tokens para credenciais válidas', async () => {
    const bcrypt = await import('bcryptjs');
    const hash = await bcrypt.hash('senha123', 1);
    prisma.user.findUnique.mockResolvedValue({ ...MOCK_USER, passwordHash: hash });
    prisma.refreshToken.create.mockResolvedValue({});

    const result = await service.login({ email: 'rafael@test.com', password: 'senha123' });

    expect(result.user.email).toBe('rafael@test.com');
    expect(result.accessToken).toBeTruthy();
  });

  it('lança UnauthorizedError para email inexistente', async () => {
    prisma.user.findUnique.mockResolvedValue(null);

    await expect(
      service.login({ email: 'nao@existe.com', password: 'qualquer' }),
    ).rejects.toMatchObject({ statusCode: 401 });
  });

  it('lança UnauthorizedError para senha errada', async () => {
    const bcrypt = await import('bcryptjs');
    const hash = await bcrypt.hash('correta', 1);
    prisma.user.findUnique.mockResolvedValue({ ...MOCK_USER, passwordHash: hash });

    await expect(
      service.login({ email: 'rafael@test.com', password: 'errada' }),
    ).rejects.toMatchObject({ statusCode: 401 });
  });

  it('lança UnauthorizedError para usuário OAuth sem senha', async () => {
    prisma.user.findUnique.mockResolvedValue({ ...MOCK_USER, passwordHash: null });

    await expect(
      service.login({ email: 'rafael@test.com', password: 'qualquer' }),
    ).rejects.toMatchObject({ statusCode: 401 });
  });
});

describe('AuthService.refresh', () => {
  it('emite novos tokens para refresh token válido', async () => {
    const future = new Date(Date.now() + 86400_000);
    prisma.refreshToken.findUnique.mockResolvedValue({
      id: 'rt-1',
      tokenHash: 'hash',
      expiresAt: future,
      user: MOCK_USER,
    });
    prisma.refreshToken.delete.mockResolvedValue({});
    prisma.refreshToken.create.mockResolvedValue({});

    const result = await service.refresh('raw-token');

    expect(result.accessToken).toBeTruthy();
    expect(result.refreshToken).toBeTruthy();
    expect(prisma.refreshToken.delete).toHaveBeenCalledOnce();
  });

  it('lança UnauthorizedError para token expirado', async () => {
    prisma.refreshToken.findUnique.mockResolvedValue({
      id: 'rt-1',
      tokenHash: 'hash',
      expiresAt: new Date(0), // já expirou
      user: MOCK_USER,
    });

    await expect(service.refresh('expired-token')).rejects.toMatchObject({ statusCode: 401 });
  });

  it('lança UnauthorizedError para token inexistente', async () => {
    prisma.refreshToken.findUnique.mockResolvedValue(null);

    await expect(service.refresh('unknown-token')).rejects.toMatchObject({ statusCode: 401 });
  });
});

describe('AuthService.logout', () => {
  it('deleta o refresh token', async () => {
    prisma.refreshToken.deleteMany.mockResolvedValue({ count: 1 });
    await service.logout('raw-token');
    expect(prisma.refreshToken.deleteMany).toHaveBeenCalledOnce();
  });
});

describe('AuthService.getMe', () => {
  it('retorna usuário existente', async () => {
    prisma.user.findUnique.mockResolvedValue(MOCK_USER);
    const user = await service.getMe('user-1');
    expect(user.id).toBe('user-1');
  });

  it('lança NotFoundError para usuário inexistente', async () => {
    prisma.user.findUnique.mockResolvedValue(null);
    await expect(service.getMe('nao-existe')).rejects.toMatchObject({ statusCode: 404 });
  });
});

describe('AuthService.updateFcmToken', () => {
  it('chama user.update com o token correto', async () => {
    prisma.user.update.mockResolvedValue({});
    await service.updateFcmToken('user-1', 'fcm-abc123');
    expect(prisma.user.update).toHaveBeenCalledWith({
      where: { id: 'user-1' },
      data: { fcmToken: 'fcm-abc123' },
    });
  });
});
