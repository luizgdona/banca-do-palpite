import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createPrismaMock, resetPrismaMock } from '../helpers/prisma-mock.js';

vi.mock('../../src/config/env.js', () => ({ env: { NODE_ENV: 'test' } }));

const { PredictionsService } = await import('../../src/modules/predictions/predictions.service.js');

const prisma = createPrismaMock();
const service = new PredictionsService(prisma as never);

const FUTURE = new Date(Date.now() + 3600_000);
const PAST   = new Date(Date.now() - 3600_000);

beforeEach(() => resetPrismaMock(prisma));

describe('PredictionsService.upsert', () => {
  it('salva palpite para jogo futuro', async () => {
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    prisma.match.findFirst.mockResolvedValue({ id: 'm1', scheduledAt: FUTURE, status: 'scheduled' });
    prisma.prediction.upsert.mockResolvedValue({
      id: 'pred-1', matchId: 'm1', homeScore: 2, awayScore: 1, pointsEarned: 0, updatedAt: new Date(),
    });

    const result = await service.upsert('p1', 'u1', { matchId: 'm1', homeScore: 2, awayScore: 1 });
    expect(result.homeScore).toBe(2);
    expect(prisma.prediction.upsert).toHaveBeenCalledOnce();
  });

  it('lança 422 para jogo já iniciado (scheduledAt no passado)', async () => {
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    prisma.match.findFirst.mockResolvedValue({ id: 'm1', scheduledAt: PAST, status: 'scheduled' });

    await expect(
      service.upsert('p1', 'u1', { matchId: 'm1', homeScore: 1, awayScore: 0 }),
    ).rejects.toMatchObject({ statusCode: 422, code: 'PREDICTION_LOCKED' });
  });

  it('lança 422 para jogo com status live', async () => {
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    prisma.match.findFirst.mockResolvedValue({ id: 'm1', scheduledAt: FUTURE, status: 'live' });

    await expect(
      service.upsert('p1', 'u1', { matchId: 'm1', homeScore: 0, awayScore: 0 }),
    ).rejects.toMatchObject({ statusCode: 422, code: 'PREDICTION_LOCKED' });
  });

  it('lança ForbiddenError para não-membro', async () => {
    prisma.poolMember.findUnique.mockResolvedValue(null);

    await expect(
      service.upsert('p1', 'intruso', { matchId: 'm1', homeScore: 1, awayScore: 0 }),
    ).rejects.toMatchObject({ statusCode: 403 });
  });

  it('lança NotFoundError se jogo não pertence ao bolão', async () => {
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    prisma.match.findFirst.mockResolvedValue(null);

    await expect(
      service.upsert('p1', 'u1', { matchId: 'm-outro', homeScore: 0, awayScore: 0 }),
    ).rejects.toMatchObject({ statusCode: 404 });
  });
});

describe('PredictionsService.getMatchPredictions — revelação', () => {
  it('não revela palpites alheios antes do jogo', async () => {
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    prisma.match.findUnique.mockResolvedValue({ scheduledAt: FUTURE, status: 'scheduled' });
    prisma.prediction.findUnique.mockResolvedValue({ homeScore: 2, awayScore: 0, updatedAt: new Date() });
    prisma.prediction.count.mockResolvedValue(3);
    prisma.poolMember.count.mockResolvedValue(5);

    const result = await service.getMatchPredictions('p1', 'm1', 'u1');

    expect(result.revealed).toBe(false);
    expect(result.predictions).toHaveLength(0);
    expect(result.predictedCount).toBe(3);
    expect(result.totalMembers).toBe(5);
  });

  it('revela todos os palpites após scheduled_at', async () => {
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    prisma.match.findUnique.mockResolvedValue({ scheduledAt: PAST, status: 'live' });
    prisma.prediction.findMany.mockResolvedValue([
      { homeScore: 2, awayScore: 1, pointsEarned: 3, user: { id: 'u1', name: 'A', avatarUrl: null } },
      { homeScore: 1, awayScore: 0, pointsEarned: 1, user: { id: 'u2', name: 'B', avatarUrl: null } },
    ]);
    prisma.poolMember.count.mockResolvedValue(2);

    const result = await service.getMatchPredictions('p1', 'm1', 'u1');

    expect(result.revealed).toBe(true);
    expect(result.predictions).toHaveLength(2);
  });
});

describe('PredictionsService.batchUpsert', () => {
  it('retorna saved e errors separados', async () => {
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    prisma.match.findFirst
      .mockResolvedValueOnce({ id: 'm1', scheduledAt: FUTURE, status: 'scheduled' })
      .mockResolvedValueOnce({ id: 'm2', scheduledAt: PAST, status: 'scheduled' }); // travado

    prisma.prediction.upsert.mockResolvedValue({
      id: 'pred-1', matchId: 'm1', homeScore: 1, awayScore: 0, pointsEarned: 0, updatedAt: new Date(),
    });

    const result = await service.batchUpsert('p1', 'u1', {
      predictions: [
        { matchId: 'm1', homeScore: 1, awayScore: 0 },
        { matchId: 'm2', homeScore: 2, awayScore: 0 },
      ],
    });

    expect(result.saved).toHaveLength(1);
    expect(result.errors).toHaveLength(1);
    expect(result.errors[0].matchId).toBe('m2');
  });
});
