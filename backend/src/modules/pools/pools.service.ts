import { PrismaClient } from '@prisma/client';
import { customAlphabet } from 'nanoid';
import { NotFoundError, ForbiddenError, ConflictError } from '../../shared/errors/AppError.js';
import { notifyMemberJoined } from '../notifications/notifications.triggers.js';
import type { CreatePoolInput, UpdatePoolInput } from './pools.schema.js';

const nanoid = customAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', 8);

const POOL_SELECT = {
  id: true,
  name: true,
  description: true,
  ownerId: true,
  competitionId: true,
  inviteCode: true,
  inviteUrl: true,
  scoringExact: true,
  scoringResult: true,
  isPublic: true,
  status: true,
  createdAt: true,
  owner: { select: { id: true, name: true, avatarUrl: true } },
  competition: { select: { id: true, name: true, country: true, logoUrl: true, season: true } },
  _count: { select: { members: true, poolMatches: true } },
} as const;

export class PoolsService {
  constructor(
    private prisma: PrismaClient,
    private frontendUrl: string,
  ) {}

  async create(userId: string, input: CreatePoolInput) {
    // Validate matches belong to the competition and are not finished/cancelled
    const matches = await this.prisma.match.findMany({
      where: {
        id: { in: input.matchIds },
        competitionId: input.competitionId,
        status: { in: ['scheduled', 'live'] },
      },
      select: { id: true },
    });

    if (matches.length !== input.matchIds.length) {
      throw new ConflictError(
        'Alguns jogos selecionados não pertencem à competição ou já estão encerrados',
      );
    }

    const inviteCode = nanoid();
    const inviteUrl = `${this.frontendUrl}/join/${inviteCode}`;

    const pool = await this.prisma.$transaction(async (tx) => {
      const created = await tx.pool.create({
        data: {
          name: input.name,
          description: input.description,
          ownerId: userId,
          competitionId: input.competitionId,
          inviteCode,
          inviteUrl,
          scoringExact: input.scoringExact,
          scoringResult: input.scoringResult,
          isPublic: input.isPublic,
          poolMatches: {
            createMany: { data: input.matchIds.map((matchId) => ({ matchId })) },
          },
          members: {
            create: { userId, totalPoints: 0 },
          },
        },
        select: POOL_SELECT,
      });
      return created;
    });

    return pool;
  }

  async listForUser(userId: string) {
    return this.prisma.pool.findMany({
      where: { members: { some: { userId } } },
      orderBy: { createdAt: 'desc' },
      select: {
        ...POOL_SELECT,
        members: {
          where: { userId },
          select: { totalPoints: true, joinedAt: true },
        },
      },
    });
  }

  async getById(id: string, userId?: string) {
    const pool = await this.prisma.pool.findUnique({
      where: { id },
      select: {
        ...POOL_SELECT,
        poolMatches: {
          orderBy: { match: { scheduledAt: 'asc' } },
          select: {
            match: {
              select: {
                id: true,
                homeTeam: true,
                awayTeam: true,
                scheduledAt: true,
                status: true,
                homeScore: true,
                awayScore: true,
                minute: true,
                period: true,
              },
            },
          },
        },
      },
    });

    if (!pool) throw new NotFoundError('Bolão não encontrado');

    if (!pool.isPublic && userId) {
      const isMember = await this.prisma.poolMember.findUnique({
        where: { poolId_userId: { poolId: id, userId } },
      });
      if (!isMember) throw new ForbiddenError('Você não é membro deste bolão');
    }

    return pool;
  }

  async getByInviteCode(inviteCode: string) {
    const pool = await this.prisma.pool.findUnique({
      where: { inviteCode: inviteCode.toUpperCase() },
      select: {
        id: true,
        name: true,
        description: true,
        inviteCode: true,
        status: true,
        owner: { select: { id: true, name: true, avatarUrl: true } },
        competition: { select: { id: true, name: true, country: true, logoUrl: true } },
        _count: { select: { members: true } },
      },
    });
    if (!pool) throw new NotFoundError('Código de convite inválido');
    return pool;
  }

  async join(inviteCode: string, userId: string) {
    const pool = await this.prisma.pool.findUnique({
      where: { inviteCode: inviteCode.toUpperCase() },
      select: { id: true, status: true },
    });
    if (!pool) throw new NotFoundError('Código de convite inválido');
    if (pool.status !== 'open') throw new ConflictError('Este bolão não está mais aceitando novos membros');

    const existing = await this.prisma.poolMember.findUnique({
      where: { poolId_userId: { poolId: pool.id, userId } },
    });
    if (existing) throw new ConflictError('Você já está neste bolão');

    const [, newUser] = await Promise.all([
      this.prisma.poolMember.create({ data: { poolId: pool.id, userId } }),
      this.prisma.user.findUnique({ where: { id: userId }, select: { name: true } }),
    ]);

    // Fire-and-forget — notifica o dono do bolão
    if (newUser) {
      notifyMemberJoined(this.prisma, pool.id, newUser.name).catch(() => {});
    }

    return { poolId: pool.id };
  }

  async update(id: string, userId: string, input: UpdatePoolInput) {
    const pool = await this.prisma.pool.findUnique({ where: { id }, select: { ownerId: true } });
    if (!pool) throw new NotFoundError('Bolão não encontrado');
    if (pool.ownerId !== userId) throw new ForbiddenError('Somente o dono pode editar o bolão');

    return this.prisma.pool.update({
      where: { id },
      data: input,
      select: POOL_SELECT,
    });
  }

  async delete(id: string, userId: string) {
    const pool = await this.prisma.pool.findUnique({ where: { id }, select: { ownerId: true } });
    if (!pool) throw new NotFoundError('Bolão não encontrado');
    if (pool.ownerId !== userId) throw new ForbiddenError('Somente o dono pode excluir o bolão');

    await this.prisma.pool.delete({ where: { id } });
  }

  async getMembers(poolId: string, userId: string) {
    await this.assertMember(poolId, userId);
    return this.prisma.poolMember.findMany({
      where: { poolId },
      orderBy: [{ totalPoints: 'desc' }, { joinedAt: 'asc' }],
      select: {
        joinedAt: true,
        totalPoints: true,
        user: { select: { id: true, name: true, avatarUrl: true } },
      },
    });
  }

  async removeMember(poolId: string, ownerId: string, targetUserId: string) {
    const pool = await this.prisma.pool.findUnique({ where: { id: poolId }, select: { ownerId: true } });
    if (!pool) throw new NotFoundError('Bolão não encontrado');
    if (pool.ownerId !== ownerId) throw new ForbiddenError('Somente o dono pode remover membros');
    if (ownerId === targetUserId) throw new ConflictError('O dono não pode ser removido do bolão');

    await this.prisma.poolMember.delete({
      where: { poolId_userId: { poolId, userId: targetUserId } },
    });
  }

  async addMatches(poolId: string, userId: string, matchIds: string[]) {
    const pool = await this.prisma.pool.findUnique({
      where: { id: poolId },
      select: { ownerId: true, competitionId: true },
    });
    if (!pool) throw new NotFoundError('Bolão não encontrado');
    if (pool.ownerId !== userId) throw new ForbiddenError('Somente o dono pode adicionar jogos');

    const validMatches = await this.prisma.match.findMany({
      where: {
        id: { in: matchIds },
        competitionId: pool.competitionId,
        status: 'scheduled',
      },
      select: { id: true },
    });

    if (validMatches.length === 0) throw new ConflictError('Nenhum jogo válido para adicionar');

    await this.prisma.poolMatch.createMany({
      data: validMatches.map((m) => ({ poolId, matchId: m.id })),
      skipDuplicates: true,
    });

    return { added: validMatches.length };
  }

  async removeMatch(poolId: string, userId: string, matchId: string) {
    const pool = await this.prisma.pool.findUnique({
      where: { id: poolId },
      select: { ownerId: true },
    });
    if (!pool) throw new NotFoundError('Bolão não encontrado');
    if (pool.ownerId !== userId) throw new ForbiddenError('Somente o dono pode remover jogos');

    const match = await this.prisma.match.findUnique({ where: { id: matchId }, select: { status: true } });
    if (match?.status !== 'scheduled') throw new ConflictError('Só é possível remover jogos ainda não iniciados');

    await this.prisma.poolMatch.delete({
      where: { poolId_matchId: { poolId, matchId } },
    });
  }

  private async assertMember(poolId: string, userId: string) {
    const member = await this.prisma.poolMember.findUnique({
      where: { poolId_userId: { poolId, userId } },
    });
    if (!member) throw new ForbiddenError('Você não é membro deste bolão');
  }
}
