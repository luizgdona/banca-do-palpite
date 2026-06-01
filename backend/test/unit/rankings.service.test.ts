import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createPrismaMock, resetPrismaMock } from '../helpers/prisma-mock.js';

vi.mock('../../src/config/env.js', () => ({ env: { NODE_ENV: 'test' } }));

const { RankingsService } = await import('../../src/modules/rankings/rankings.service.js');

const prisma = createPrismaMock();
const service = new RankingsService(prisma as never);

beforeEach(() => resetPrismaMock(prisma));

// Prisma retorna já ordenado por totalPoints DESC, joinedAt ASC
const MEMBERS = [
  { totalPoints: 21, joinedAt: new Date('2024-01-01'), user: { id: 'u1', name: 'A', avatarUrl: null } },
  { totalPoints: 18, joinedAt: new Date('2024-01-02'), user: { id: 'u2', name: 'B', avatarUrl: null } },
  { totalPoints: 10, joinedAt: new Date('2024-01-03'), user: { id: 'u3', name: 'C', avatarUrl: null } },
];

describe('RankingsService.getPoolRanking', () => {
  it('lança ForbiddenError para não-membro', async () => {
    prisma.poolMember.findUnique.mockResolvedValue(null);
    await expect(service.getPoolRanking('p1', 'intruso')).rejects.toMatchObject({ statusCode: 403 });
  });

  it('retorna ranking ordenado por pontos', async () => {
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    prisma.poolMember.findMany.mockResolvedValue(MEMBERS);
    prisma.prediction.groupBy.mockResolvedValue([]);

    const ranking = await service.getPoolRanking('p1', 'u1');

    expect(ranking[0].user.name).toBe('A');
    expect(ranking[0].position).toBe(1);
    expect(ranking[0].totalPoints).toBe(21);
    expect(ranking[1].user.name).toBe('B');
    expect(ranking[2].user.name).toBe('C');
  });

  it('marca isMe=true para o usuário autenticado', async () => {
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u2' });
    prisma.poolMember.findMany.mockResolvedValue(MEMBERS);
    prisma.prediction.groupBy.mockResolvedValue([]);

    const ranking = await service.getPoolRanking('p1', 'u2');
    const me = ranking.find(r => r.isMe);

    expect(me?.user.id).toBe('u2');
    expect(me?.position).toBe(2);
  });

  it('atribui exactCount a partir dos eventos', async () => {
    prisma.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    prisma.poolMember.findMany.mockResolvedValue(MEMBERS);
    prisma.prediction.groupBy.mockResolvedValue([
      { userId: 'u1', _count: { userId: 4 } },
    ]);

    const ranking = await service.getPoolRanking('p1', 'u1');
    expect(ranking[0].exactCount).toBe(4);
    expect(ranking[1].exactCount).toBe(0);
  });
});
