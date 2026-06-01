import { FastifyInstance } from 'fastify';
import { PoolsService } from './pools.service.js';
import {
  createPoolSchema,
  updatePoolSchema,
  addMatchesToPoolSchema,
} from './pools.schema.js';
import { authGuard } from '../../shared/middleware/authGuard.js';
import { env } from '../../config/env.js';

export async function poolsRoutes(fastify: FastifyInstance) {
  const service = new PoolsService(fastify.prisma, env.FRONTEND_URL);

  // Rota pública — registrada em sub-scope separado para não ser afetada pelo authGuard
  await fastify.register(async (pub) => {
    pub.get('/pools/join/:inviteCode', async (request, reply) => {
      const { inviteCode } = request.params as { inviteCode: string };
      return reply.send(await service.getByInviteCode(inviteCode));
    });
  });

  // Rotas autenticadas — sub-scope com authGuard aplicado a todas
  await fastify.register(async (auth) => {
    auth.addHook('preHandler', authGuard);

    auth.post('/pools', async (request, reply) => {
      const input = createPoolSchema.parse(request.body);
      const pool = await service.create(request.userId, input);
      return reply.status(201).send(pool);
    });

    auth.get('/pools', async (request, reply) => {
      return reply.send(await service.listForUser(request.userId));
    });

    auth.get('/pools/:id', async (request, reply) => {
      const { id } = request.params as { id: string };
      return reply.send(await service.getById(id, request.userId));
    });

    auth.put('/pools/:id', async (request, reply) => {
      const { id } = request.params as { id: string };
      const input = updatePoolSchema.parse(request.body);
      return reply.send(await service.update(id, request.userId, input));
    });

    auth.delete('/pools/:id', async (request, reply) => {
      const { id } = request.params as { id: string };
      await service.delete(id, request.userId);
      return reply.status(204).send();
    });

    auth.post('/pools/join/:inviteCode/confirm', async (request, reply) => {
      const { inviteCode } = request.params as { inviteCode: string };
      const result = await service.join(inviteCode, request.userId);
      return reply.status(201).send(result);
    });

    auth.get('/pools/:id/members', async (request, reply) => {
      const { id } = request.params as { id: string };
      return reply.send(await service.getMembers(id, request.userId));
    });

    auth.delete('/pools/:id/members/:userId', async (request, reply) => {
      const { id, userId } = request.params as { id: string; userId: string };
      await service.removeMember(id, request.userId, userId);
      return reply.status(204).send();
    });

    auth.post('/pools/:id/matches', async (request, reply) => {
      const { id } = request.params as { id: string };
      const { matchIds } = addMatchesToPoolSchema.parse(request.body);
      return reply.send(await service.addMatches(id, request.userId, matchIds));
    });

    auth.delete('/pools/:id/matches/:matchId', async (request, reply) => {
      const { id, matchId } = request.params as { id: string; matchId: string };
      await service.removeMatch(id, request.userId, matchId);
      return reply.status(204).send();
    });
  });
}
