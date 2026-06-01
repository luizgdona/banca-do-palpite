import { FastifyInstance } from 'fastify';
import { RankingsService } from './rankings.service.js';
import { authGuard } from '../../shared/middleware/authGuard.js';

export async function rankingsRoutes(fastify: FastifyInstance) {
  const service = new RankingsService(fastify.prisma);

  fastify.addHook('preHandler', authGuard);

  fastify.get('/pools/:id/ranking', async (request, reply) => {
    const { id } = request.params as { id: string };
    return reply.send(await service.getPoolRanking(id, request.userId));
  });

  fastify.get('/pools/:id/ranking/matches', async (request, reply) => {
    const { id } = request.params as { id: string };
    return reply.send(await service.getMatchBreakdown(id, request.userId));
  });
}
