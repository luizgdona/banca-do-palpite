import { FastifyInstance } from 'fastify';
import { calculatePointsForMatch } from './calculate-points.js';
import { z } from 'zod';

function isAuthorized(request: { headers: Record<string, unknown> }): boolean {
  if (process.env.NODE_ENV !== 'production') return true;
  const key = request.headers['x-admin-key'];
  return !!key && key === process.env.SYNC_ADMIN_KEY;
}

export async function syncRoutes(fastify: FastifyInstance) {
  fastify.post('/sync/calculate-points', async (request, reply) => {
    if (!isAuthorized(request)) {
      return reply.status(403).send({ error: 'FORBIDDEN' });
    }

    const { matchId } = z.object({ matchId: z.string().uuid() }).parse(request.body);
    const result = await calculatePointsForMatch(fastify.prisma, matchId);
    return reply.send(result);
  });

  // Recalculate from scratch (admin only — useful for corrections)
  fastify.post('/sync/recalculate', async (request, reply) => {
    if (!isAuthorized(request)) {
      return reply.status(403).send({ error: 'FORBIDDEN' });
    }

    const { matchId } = z.object({ matchId: z.string().uuid() }).parse(request.body);

    // Delete existing events for this match, then recalculate
    await fastify.prisma.$transaction(async (tx) => {
      const events = await tx.pointEvent.findMany({
        where: { matchId },
        select: { userId: true, poolId: true, points: true },
      });

      // Subtract points from members
      for (const ev of events) {
        if (ev.points > 0) {
          await tx.poolMember.update({
            where: { poolId_userId: { poolId: ev.poolId, userId: ev.userId } },
            data: { totalPoints: { decrement: ev.points } },
          });
        }
      }

      await tx.pointEvent.deleteMany({ where: { matchId } });
      await tx.prediction.updateMany({
        where: { matchId },
        data: { pointsEarned: 0 },
      });
    });

    const result = await calculatePointsForMatch(fastify.prisma, matchId);
    return reply.send(result);
  });
}
