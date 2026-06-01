import { FastifyInstance } from 'fastify';
import { MatchesService } from './matches.service.js';
import { authGuard } from '../../shared/middleware/authGuard.js';

export async function matchesRoutes(fastify: FastifyInstance) {
  const service = new MatchesService(fastify.prisma);

  fastify.get('/matches/live', { preHandler: authGuard }, async (_request, reply) => {
    return reply.send(await service.listLive());
  });

  fastify.get('/matches/:id', { preHandler: authGuard }, async (request, reply) => {
    const { id } = request.params as { id: string };
    return reply.send(await service.getById(id));
  });

  fastify.get('/competitions/:id/matches', { preHandler: authGuard }, async (request, reply) => {
    const { id } = request.params as { id: string };
    return reply.send(await service.listByCompetition(id));
  });

  // Sync endpoint — protected in production
  fastify.post('/competitions/:id/matches/sync', async (request, reply) => {
    if (process.env.NODE_ENV === 'production') {
      const adminKey = request.headers['x-admin-key'];
      if (!adminKey || adminKey !== process.env.SYNC_ADMIN_KEY) {
        return reply.status(403).send({ error: 'FORBIDDEN' });
      }
    }
    const { id } = request.params as { id: string };
    const result = await service.syncByCompetition(id);
    return reply.send(result);
  });
}
