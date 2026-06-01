import Fastify from 'fastify';
import cors from '@fastify/cors';
import cookie from '@fastify/cookie';
import rateLimit from '@fastify/rate-limit';
import { PrismaClient } from '@prisma/client';
import { env } from './config/env.js';
import { errorHandler } from './shared/middleware/errorHandler.js';
import { authRoutes } from './modules/auth/auth.routes.js';
import { usersRoutes } from './modules/users/users.routes.js';
import { competitionsRoutes } from './modules/competitions/competitions.routes.js';
import { matchesRoutes } from './modules/matches/matches.routes.js';
import { poolsRoutes } from './modules/pools/pools.routes.js';
import { predictionsRoutes } from './modules/predictions/predictions.routes.js';
import { rankingsRoutes } from './modules/rankings/rankings.routes.js';
import { syncRoutes } from './modules/sync/sync.routes.js';
import { wsRoutes } from './modules/websocket/ws.routes.js';
import { startLiveScoresWorker, scheduleLiveScoresJob, stopLiveScoresWorker } from './modules/sync/live-scores.job.js';
import { startUpcomingWorker, scheduleUpcomingJob, stopUpcomingWorker } from './modules/sync/upcoming-matches.job.js';
import { stopRedisSubscriber } from './modules/websocket/redis-subscriber.js';
import { getRedis, closeRedis } from './config/redis.js';
import websocketPlugin from '@fastify/websocket';

declare module 'fastify' {
  interface FastifyInstance {
    prisma: PrismaClient;
  }
}

export async function buildApp() {
  const fastify = Fastify({
    logger: {
      level: env.NODE_ENV === 'production' ? 'warn' : 'info',
      transport:
        env.NODE_ENV !== 'production'
          ? { target: 'pino-pretty', options: { colorize: true } }
          : undefined,
    },
  });

  // Plugins
  await fastify.register(cors, {
    origin: env.FRONTEND_URL,
    credentials: true,
  });

  await fastify.register(cookie);
  await fastify.register(websocketPlugin);

  await fastify.register(rateLimit, {
    max: 100,
    timeWindow: '1 minute',
  });

  // Prisma
  const prisma = new PrismaClient();
  fastify.decorate('prisma', prisma);
  fastify.addHook('onClose', async () => {
    await stopLiveScoresWorker();
    await stopUpcomingWorker();
    await stopRedisSubscriber();
    await prisma.$disconnect();
    await closeRedis();
  });

  // Initialize Redis connection eagerly
  getRedis();

  // Start BullMQ live-scores worker and schedule repeatable job
  if (env.NODE_ENV !== 'test') {
    startLiveScoresWorker(prisma);
    startUpcomingWorker(prisma);
    scheduleLiveScoresJob().catch((err) =>
      fastify.log.error('[LiveScores] schedule error:', err),
    );
    scheduleUpcomingJob().catch((err) =>
      fastify.log.error('[Upcoming] schedule error:', err),
    );
  }

  // Error handler
  fastify.setErrorHandler(errorHandler);

  // Routes
  await fastify.register(authRoutes, { prefix: '/api' });
  await fastify.register(usersRoutes, { prefix: '/api' });
  await fastify.register(competitionsRoutes, { prefix: '/api' });
  await fastify.register(matchesRoutes, { prefix: '/api' });
  await fastify.register(poolsRoutes, { prefix: '/api' });
  await fastify.register(predictionsRoutes, { prefix: '/api' });
  await fastify.register(rankingsRoutes, { prefix: '/api' });
  await fastify.register(syncRoutes, { prefix: '/api' });
  await fastify.register(wsRoutes);  // WebSocket — sem prefix, rota é /ws

  // Health check
  fastify.get('/health', async () => ({ status: 'ok', timestamp: new Date().toISOString() }));

  return fastify;
}
