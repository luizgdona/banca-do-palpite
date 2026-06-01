import bcrypt from 'bcryptjs';
import { PrismaClient } from '@prisma/client';
import { ConflictError, UnauthorizedError, NotFoundError } from '../../shared/errors/AppError.js';
import { verifyGoogleIdToken } from './google-oauth.js';
import {
  generateAccessToken,
  generateRefreshToken,
  hashToken,
  getRefreshTokenExpiry,
} from '../../shared/utils/tokens.js';
import type { RegisterInput, LoginInput } from './auth.schema.js';

export class AuthService {
  constructor(private prisma: PrismaClient) {}

  async register(input: RegisterInput) {
    const existing = await this.prisma.user.findUnique({
      where: { email: input.email },
    });
    if (existing) {
      throw new ConflictError('Email já cadastrado');
    }

    const passwordHash = await bcrypt.hash(input.password, 12);
    const user = await this.prisma.user.create({
      data: { name: input.name, email: input.email, passwordHash },
      select: { id: true, name: true, email: true, avatarUrl: true, createdAt: true },
    });

    const { accessToken, refreshToken } = await this.issueTokens(user.id, user.email);
    return { user, accessToken, refreshToken };
  }

  async login(input: LoginInput) {
    const user = await this.prisma.user.findUnique({ where: { email: input.email } });
    if (!user || !user.passwordHash) {
      throw new UnauthorizedError('Email ou senha inválidos');
    }

    const valid = await bcrypt.compare(input.password, user.passwordHash);
    if (!valid) {
      throw new UnauthorizedError('Email ou senha inválidos');
    }

    const { accessToken, refreshToken } = await this.issueTokens(user.id, user.email);
    return {
      user: { id: user.id, name: user.name, email: user.email, avatarUrl: user.avatarUrl },
      accessToken,
      refreshToken,
    };
  }

  async refresh(rawRefreshToken: string) {
    const tokenHash = hashToken(rawRefreshToken);
    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: true },
    });

    if (!stored || stored.expiresAt < new Date()) {
      throw new UnauthorizedError('Refresh token inválido ou expirado');
    }

    await this.prisma.refreshToken.delete({ where: { id: stored.id } });

    const { accessToken, refreshToken } = await this.issueTokens(
      stored.user.id,
      stored.user.email,
    );
    return { accessToken, refreshToken };
  }

  async logout(rawRefreshToken: string) {
    const tokenHash = hashToken(rawRefreshToken);
    await this.prisma.refreshToken.deleteMany({ where: { tokenHash } });
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, name: true, email: true, avatarUrl: true, provider: true, createdAt: true },
    });
    if (!user) throw new NotFoundError('Usuário não encontrado');
    return user;
  }

  async loginWithGoogle(idToken: string) {
    const profile = await verifyGoogleIdToken(idToken);

    const user = await this.prisma.user.upsert({
      where: { email: profile.email },
      update: {
        name: profile.name,
        avatarUrl: profile.picture,
        provider: 'google',
        providerId: profile.sub,
      },
      create: {
        email: profile.email,
        name: profile.name,
        avatarUrl: profile.picture,
        provider: 'google',
        providerId: profile.sub,
      },
    });

    const { accessToken, refreshToken } = await this.issueTokens(user.id, user.email);
    return {
      user: { id: user.id, name: user.name, email: user.email, avatarUrl: user.avatarUrl },
      accessToken,
      refreshToken,
    };
  }

  async updateFcmToken(userId: string, fcmToken: string) {
    await this.prisma.user.update({
      where: { id: userId },
      data: { fcmToken },
    });
  }

  private async issueTokens(userId: string, email: string) {
    const accessToken = generateAccessToken(userId, email);
    const refreshToken = generateRefreshToken();
    const tokenHash = hashToken(refreshToken);

    await this.prisma.refreshToken.create({
      data: { userId, tokenHash, expiresAt: getRefreshTokenExpiry() },
    });

    return { accessToken, refreshToken };
  }
}
