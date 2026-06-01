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
import { getRedis, closeRedis } from './config/redis.js';

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

  await fastify.register(rateLimit, {
    max: 100,
    timeWindow: '1 minute',
  });

  // Prisma
  const prisma = new PrismaClient();
  fastify.decorate('prisma', prisma);
  fastify.addHook('onClose', async () => {
    await prisma.$disconnect();
    await closeRedis();
  });

  // Initialize Redis connection eagerly
  getRedis();

  // Error handler
  fastify.setErrorHandler(errorHandler);

  // Routes
  await fastify.register(authRoutes, { prefix: '/api' });
  await fastify.register(usersRoutes, { prefix: '/api' });
  await fastify.register(competitionsRoutes, { prefix: '/api' });
  await fastify.register(matchesRoutes, { prefix: '/api' });
  await fastify.register(poolsRoutes, { prefix: '/api' });

  // Health check
  fastify.get('/health', async () => ({ status: 'ok', timestamp: new Date().toISOString() }));

  return fastify;
}
