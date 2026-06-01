import { FastifyInstance } from 'fastify';
import { PredictionsService } from './predictions.service.js';
import { upsertPredictionSchema, batchUpsertSchema } from './predictions.schema.js';
import { authGuard } from '../../shared/middleware/authGuard.js';

export async function predictionsRoutes(fastify: FastifyInstance) {
  const service = new PredictionsService(fastify.prisma);

  fastify.addHook('preHandler', authGuard);

  // Salvar palpite único
  fastify.post('/pools/:poolId/predictions', async (request, reply) => {
    const { poolId } = request.params as { poolId: string };
    const input = upsertPredictionSchema.parse(request.body);
    const result = await service.upsert(poolId, request.userId, input);
    return reply.status(201).send(result);
  });

  // Salvar múltiplos palpites de uma vez (debounce no cliente)
  fastify.post('/pools/:poolId/predictions/batch', async (request, reply) => {
    const { poolId } = request.params as { poolId: string };
    const input = batchUpsertSchema.parse(request.body);
    const result = await service.batchUpsert(poolId, request.userId, input);
    return reply.send(result);
  });

  // Meus palpites no bolão
  fastify.get('/pools/:poolId/predictions/me', async (request, reply) => {
    const { poolId } = request.params as { poolId: string };
    return reply.send(await service.getMyPredictions(poolId, request.userId));
  });

  // Palpites de todos num jogo (revelados após scheduled_at)
  fastify.get('/pools/:poolId/matches/:matchId/predictions', async (request, reply) => {
    const { poolId, matchId } = request.params as { poolId: string; matchId: string };
    return reply.send(
      await service.getMatchPredictions(poolId, matchId, request.userId),
    );
  });
}
