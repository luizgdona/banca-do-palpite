import { buildApp } from '../../src/app.js';
import type { PrismaMock } from './prisma-mock.js';

// Build a test instance of the Fastify app with a mocked Prisma client.
// Redis, BullMQ workers and the WS Redis subscriber are not started in test mode
// (NODE_ENV=test is already set by vitest).
export async function buildTestApp(prisma: PrismaMock) {
  process.env.NODE_ENV = 'test';
  process.env.JWT_SECRET = 'test-jwt-secret-at-least-32-chars!!';
  process.env.REFRESH_TOKEN_SECRET = 'test-refresh-secret-32chars!!!!!';
  process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/test';
  process.env.REDIS_URL = 'redis://localhost:6379';

  const app = await buildApp();
  // Replace the real Prisma instance injected by buildApp
  (app as unknown as Record<string, unknown>).prisma = prisma;
  return app;
}
