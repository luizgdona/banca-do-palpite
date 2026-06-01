import { PrismaClient } from '@prisma/client';
import { ForbiddenError } from '../../shared/errors/AppError.js';

export class RankingsService {
  constructor(private prisma: PrismaClient) {}

  async getPoolRanking(poolId: string, userId: string) {
    await this.assertMember(poolId, userId);

    const members = await this.prisma.poolMember.findMany({
      where: { poolId },
      orderBy: [{ totalPoints: 'desc' }, { joinedAt: 'asc' }],
      select: {
        totalPoints: true,
        joinedAt: true,
        user: { select: { id: true, name: true, avatarUrl: true } },
      },
    });

    // Calculate exact count per member for tiebreaker display
    const exactCounts = await this.prisma.prediction.groupBy({
      by: ['userId'],
      where: {
        poolId,
        pointsEarned: {
          // exact = scoring_exact points; we use pointsEarned > scoring_result as proxy
          // Real exact count comes from point_events
          gt: 1,
        },
      },
      _count: { userId: true },
    });

    const exactByUser = new Map(exactCounts.map((e) => [e.userId, e._count.userId]));

    return members.map((m, i) => ({
      position: i + 1,
      user: m.user,
      totalPoints: m.totalPoints,
      exactCount: exactByUser.get(m.user.id) ?? 0,
      isMe: m.user.id === userId,
    }));
  }

  async getMatchBreakdown(poolId: string, userId: string) {
    await this.assertMember(poolId, userId);

    const poolMatches = await this.prisma.poolMatch.findMany({
      where: { poolId },
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
          },
        },
      },
    });

    const events = await this.prisma.pointEvent.findMany({
      where: { poolId },
      select: {
        matchId: true,
        userId: true,
        points: true,
        reason: true,
        user: { select: { id: true, name: true, avatarUrl: true } },
      },
    });

    return poolMatches.map((pm) => {
      const matchEvents = events.filter((e) => e.matchId === pm.match.id);
      return {
        match: pm.match,
        results: matchEvents,
      };
    });
  }

  private async assertMember(poolId: string, userId: string) {
    const member = await this.prisma.poolMember.findUnique({
      where: { poolId_userId: { poolId, userId } },
    });
    if (!member) throw new ForbiddenError('Você não é membro deste bolão');
  }
}
