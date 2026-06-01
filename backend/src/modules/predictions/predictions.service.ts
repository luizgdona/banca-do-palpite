import { PrismaClient } from '@prisma/client';
import { AppError, ForbiddenError, NotFoundError } from '../../shared/errors/AppError.js';
import type { UpsertPredictionInput, BatchUpsertInput } from './predictions.schema.js';

export class PredictionsService {
  constructor(private prisma: PrismaClient) {}

  async upsert(poolId: string, userId: string, input: UpsertPredictionInput) {
    await this.assertMember(poolId, userId);

    const match = await this.prisma.match.findFirst({
      where: {
        id: input.matchId,
        poolMatches: { some: { poolId } },
      },
      select: { id: true, scheduledAt: true, status: true },
    });

    if (!match) throw new NotFoundError('Jogo não encontrado neste bolão');

    // Validação temporal — nunca confiar no cliente
    if (match.scheduledAt <= new Date()) {
      throw new AppError('O prazo para palpitar neste jogo já encerrou', 422, 'PREDICTION_LOCKED');
    }
    if (match.status !== 'scheduled') {
      throw new AppError('O prazo para palpitar neste jogo já encerrou', 422, 'PREDICTION_LOCKED');
    }

    return this.prisma.prediction.upsert({
      where: { poolId_matchId_userId: { poolId, matchId: input.matchId, userId } },
      update: { homeScore: input.homeScore, awayScore: input.awayScore },
      create: {
        poolId,
        matchId: input.matchId,
        userId,
        homeScore: input.homeScore,
        awayScore: input.awayScore,
      },
      select: {
        id: true,
        matchId: true,
        homeScore: true,
        awayScore: true,
        pointsEarned: true,
        updatedAt: true,
      },
    });
  }

  async batchUpsert(poolId: string, userId: string, input: BatchUpsertInput) {
    const results = await Promise.allSettled(
      input.predictions.map((p) => this.upsert(poolId, userId, p)),
    );

    const saved = results
      .filter((r) => r.status === 'fulfilled')
      .map((r) => (r as PromiseFulfilledResult<unknown>).value);

    const errors = results
      .map((r, i) => ({ index: i, result: r }))
      .filter((r) => r.result.status === 'rejected')
      .map((r) => ({
        matchId: input.predictions[r.index].matchId,
        error: (r.result as PromiseRejectedResult).reason?.message ?? 'Erro desconhecido',
      }));

    return { saved, errors };
  }

  async getMyPredictions(poolId: string, userId: string) {
    await this.assertMember(poolId, userId);

    return this.prisma.prediction.findMany({
      where: { poolId, userId },
      select: {
        id: true,
        matchId: true,
        homeScore: true,
        awayScore: true,
        pointsEarned: true,
        updatedAt: true,
      },
    });
  }

  async getMatchPredictions(poolId: string, matchId: string, userId: string) {
    await this.assertMember(poolId, userId);

    const match = await this.prisma.match.findUnique({
      where: { id: matchId },
      select: { scheduledAt: true, status: true },
    });

    if (!match) throw new NotFoundError('Jogo não encontrado');

    // Revelar palpites alheios somente após scheduled_at
    const revealed = match.scheduledAt <= new Date() || match.status !== 'scheduled';

    if (!revealed) {
      // Retorna só o palpite do próprio usuário + contador
      const [myPrediction, count] = await Promise.all([
        this.prisma.prediction.findUnique({
          where: { poolId_matchId_userId: { poolId, matchId, userId } },
          select: { homeScore: true, awayScore: true, updatedAt: true },
        }),
        this.prisma.prediction.count({ where: { poolId, matchId } }),
      ]);

      const totalMembers = await this.prisma.poolMember.count({ where: { poolId } });

      return {
        revealed: false,
        predictedCount: count,
        totalMembers,
        myPrediction,
        predictions: [],
      };
    }

    const [predictions, totalMembers] = await Promise.all([
      this.prisma.prediction.findMany({
        where: { poolId, matchId },
        select: {
          homeScore: true,
          awayScore: true,
          pointsEarned: true,
          user: { select: { id: true, name: true, avatarUrl: true } },
        },
        orderBy: { pointsEarned: 'desc' },
      }),
      this.prisma.poolMember.count({ where: { poolId } }),
    ]);

    return {
      revealed: true,
      predictedCount: predictions.length,
      totalMembers,
      myPrediction: predictions.find((p) => p.user.id === userId) ?? null,
      predictions,
    };
  }

  private async assertMember(poolId: string, userId: string) {
    const member = await this.prisma.poolMember.findUnique({
      where: { poolId_userId: { poolId, userId } },
    });
    if (!member) throw new ForbiddenError('Você não é membro deste bolão');
  }
}
