import { FastifyInstance } from 'fastify';
import { CompetitionsService } from './competitions.service.js';
import { authGuard } from '../../shared/middleware/authGuard.js';

export async function competitionsRoutes(fastify: FastifyInstance) {
  const service = new CompetitionsService(fastify.prisma);

  fastify.get('/competitions', { preHandler: authGuard }, async (request, reply) => {
    const { search } = request.query as { search?: string };
    return reply.send(await service.list(search));
  });

  fastify.get('/competitions/:id', { preHandler: authGuard }, async (request, reply) => {
    const { id } = request.params as { id: string };
    return reply.send(await service.getById(id));
  });

  // Internal endpoint — only callable server-side or with admin header in dev
  fastify.post('/competitions/sync', async (request, reply) => {
    if (process.env.NODE_ENV === 'production') {
      const adminKey = request.headers['x-admin-key'];
      if (!adminKey || adminKey !== process.env.SYNC_ADMIN_KEY) {
        return reply.status(403).send({ error: 'FORBIDDEN' });
      }
    }
    const result = await service.syncFromApi();
    return reply.send(result);
  });
}
