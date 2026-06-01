import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createPrismaMock, resetPrismaMock } from '../helpers/prisma-mock.js';

vi.mock('../../src/config/env.js', () => ({
  env: { FRONTEND_URL: 'http://localhost:4000', NODE_ENV: 'test' },
}));
vi.mock('../../src/modules/notifications/notifications.triggers.js', () => ({
  notifyMemberJoined: vi.fn().mockResolvedValue(undefined),
}));

const { PoolsService } = await import('../../src/modules/pools/pools.service.js');

const prisma = createPrismaMock();
const service = new PoolsService(prisma as never, 'http://localhost:4000');

const MOCK_COMPETITION = { id: 'comp-1', name: 'Brasileirão', externalId: '71' };
const MOCK_USER = { id: 'user-1', name: 'Rafael', email: 'r@t.com' };
const MOCK_POOL = {
  id: 'pool-1',
  name: 'Bolão Top',
  description: null,
  ownerId: 'user-1',
  competitionId: 'comp-1',
  inviteCode: 'ABCD1234',
  inviteUrl: 'http://localhost:4000/join/ABCD1234',
  scoringExact: 3,
  scoringResult: 1,
  isPublic: false,
  status: 'open',
  createdAt: new Date(),
  owner: MOCK_USER,
  competition: MOCK_COMPETITION,
  _count: { members: 1, poolMatches: 2 },
};

beforeEach(() => {
  resetPrismaMock(prisma);
});

describe('PoolsService.create', () => {
  it('cria bolão com jogos válidos', async () => {
    prisma.match.findMany.mockResolvedValue([{ id: 'm-1' }, { id: 'm-2' }]);
    prisma.pool.create.mockResolvedValue(MOCK_POOL);

    const result = await service.create('user-1', {
      name: 'Bolão Top',
      competitionId: 'comp-1',
      matchIds: ['m-1', 'm-2'],
      scoringExact: 3,
      scoringResult: 1,
      isPublic: false,
    });

    expect(result.inviteCode).toMatch(/^[A-Z0-9]{8}$/);
    expect(prisma.pool.create).toHaveBeenCalledOnce();
  });

  it('lança ConflictError se algum jogo não pertence à competição', async () => {
    // Retorna 1 jogo mas foram pedidos 2
    prisma.match.findMany.mockResolvedValue([{ id: 'm-1' }]);

    await expect(
      service.create('user-1', {
        name: 'Bolão',
        competitionId: 'comp-1',
        matchIds: ['m-1', 'm-invalido'],
        scoringExact: 3,
        scoringResult: 1,
        isPublic: false,
      }),
    ).rejects.toMatchObject({ statusCode: 409 });
  });
});

describe('PoolsService.getByInviteCode', () => {
  it('retorna preview para código válido', async () => {
    prisma.pool.findUnique.mockResolvedValue(MOCK_POOL);
    const result = await service.getByInviteCode('ABCD1234');
    expect(result.inviteCode).toBe('ABCD1234');
  });

  it('converte código para maiúsculas antes de buscar', async () => {
    prisma.pool.findUnique.mockResolvedValue(MOCK_POOL);
    await service.getByInviteCode('abcd1234');
    expect(prisma.pool.findUnique).toHaveBeenCalledWith(
      expect.objectContaining({ where: { inviteCode: 'ABCD1234' } }),
    );
  });

  it('lança NotFoundError para código inválido', async () => {
    prisma.pool.findUnique.mockResolvedValue(null);
    await expect(service.getByInviteCode('XXXXXXXX')).rejects.toMatchObject({ statusCode: 404 });
  });
});

describe('PoolsService.join', () => {
  it('adiciona membro com sucesso', async () => {
    prisma.pool.findUnique.mockResolvedValue({ id: 'pool-1', status: 'open' });
    prisma.poolMember.findUnique.mockResolvedValue(null); // não é membro ainda
    prisma.poolMember.create.mockResolvedValue({});
    prisma.user.findUnique.mockResolvedValue({ name: 'Novo' });

    const result = await service.join('ABCD1234', 'user-2');
    expect(result.poolId).toBe('pool-1');
  });

  it('lança ConflictError se já é membro', async () => {
    prisma.pool.findUnique.mockResolvedValue({ id: 'pool-1', status: 'open' });
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'pool-1', userId: 'user-1' });

    await expect(service.join('ABCD1234', 'user-1')).rejects.toMatchObject({ statusCode: 409 });
  });

  it('lança ConflictError se bolão está fechado', async () => {
    prisma.pool.findUnique.mockResolvedValue({ id: 'pool-1', status: 'closed' });

    await expect(service.join('ABCD1234', 'user-2')).rejects.toMatchObject({ statusCode: 409 });
  });
});

describe('PoolsService.update', () => {
  it('permite ao dono atualizar o bolão', async () => {
    prisma.pool.findUnique.mockResolvedValue({ ownerId: 'user-1' });
    prisma.pool.update.mockResolvedValue({ ...MOCK_POOL, name: 'Novo Nome' });

    const result = await service.update('pool-1', 'user-1', { name: 'Novo Nome' });
    expect(result.name).toBe('Novo Nome');
  });

  it('lança ForbiddenError para não-dono', async () => {
    prisma.pool.findUnique.mockResolvedValue({ ownerId: 'user-1' });

    await expect(service.update('pool-1', 'user-outro', { name: 'Hack' })).rejects.toMatchObject({
      statusCode: 403,
    });
  });
});

describe('PoolsService.removeMember', () => {
  it('lança ConflictError se dono tentar remover a si mesmo', async () => {
    prisma.pool.findUnique.mockResolvedValue({ ownerId: 'user-1' });

    await expect(service.removeMember('pool-1', 'user-1', 'user-1')).rejects.toMatchObject({
      statusCode: 409,
    });
  });

  it('permite ao dono remover outro membro', async () => {
    prisma.pool.findUnique.mockResolvedValue({ ownerId: 'user-1' });
    prisma.poolMember.delete.mockResolvedValue({});

    await service.removeMember('pool-1', 'user-1', 'user-2');
    expect(prisma.poolMember.delete).toHaveBeenCalledOnce();
  });
});
