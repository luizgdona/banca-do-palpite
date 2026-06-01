import { describe, it, expect, vi, beforeEach, afterAll } from 'vitest';
import jwt from 'jsonwebtoken';

const { mp, reset } = vi.hoisted(() => {
  const fn = () => vi.fn();
  const p: Record<string, unknown> = {
    user: { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), upsert: fn(), delete: fn(), count: fn() },
    refreshToken: { findUnique: fn(), create: fn(), delete: fn(), deleteMany: fn() },
    match: { findUnique: fn(), findFirst: fn(), findMany: fn(), create: fn(), update: fn(), upsert: fn(), count: fn() },
    pool: { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), delete: fn() },
    poolMatch: { findMany: fn(), createMany: fn(), delete: fn() },
    poolMember: { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), delete: fn(), count: fn() },
    prediction: { findUnique: fn(), findMany: fn(), upsert: fn(), count: fn(), groupBy: fn() },
    pointEvent: { findFirst: fn(), findMany: fn(), create: fn(), deleteMany: fn() },
    $disconnect: fn(), $transaction: fn(),
  };
  (p.$transaction as ReturnType<typeof vi.fn>).mockImplementation((cb: (t: unknown) => Promise<unknown>) => cb(p));
  const reset = () => {
    for (const v of Object.values(p)) {
      if (v && typeof v === 'object') for (const f of Object.values(v as Record<string, unknown>)) {
        if (f && typeof (f as { mockReset?: () => void }).mockReset === 'function') (f as { mockReset: () => void }).mockReset();
      }
    }
    (p.$transaction as ReturnType<typeof vi.fn>).mockImplementation((cb: (t: unknown) => Promise<unknown>) => cb(p));
  };
  return { mp: p, reset };
});

vi.mock('@prisma/client', () => ({ PrismaClient: vi.fn(function() { return mp; }) }));
vi.mock('../../src/config/env.js', () => ({ env: { PORT: '3003', NODE_ENV: 'test', FRONTEND_URL: 'http://localhost:4000', DATABASE_URL: 'postgresql://x@x/x', REDIS_URL: 'redis://localhost:6379', JWT_SECRET: 'test-jwt-secret-at-least-32-chars!!', JWT_EXPIRES_IN: '15m', REFRESH_TOKEN_SECRET: 'test-refresh-secret-32chars!!!!!', REFRESH_TOKEN_EXPIRES_IN: '30d', SYNC_ADMIN_KEY: 'k', FIREBASE_PROJECT_ID: '', FIREBASE_PRIVATE_KEY: '', FIREBASE_CLIENT_EMAIL: '', GOOGLE_CLIENT_ID: '' } }));
vi.mock('../../src/config/redis.js', () => ({ getRedis: vi.fn(() => ({ get: vi.fn().mockResolvedValue(null), set: vi.fn(), setex: vi.fn(), del: vi.fn(), keys: vi.fn().mockResolvedValue([]), publish: vi.fn(), quit: vi.fn(), on: vi.fn(), psubscribe: vi.fn() })), closeRedis: vi.fn(), TTL: {} }));
vi.mock('../../src/modules/sync/live-scores.job.js', () => ({ startLiveScoresWorker: vi.fn(), scheduleLiveScoresJob: vi.fn().mockResolvedValue(undefined), stopLiveScoresWorker: vi.fn().mockResolvedValue(undefined) }));
vi.mock('../../src/modules/sync/upcoming-matches.job.js', () => ({ startUpcomingWorker: vi.fn(), scheduleUpcomingJob: vi.fn().mockResolvedValue(undefined), stopUpcomingWorker: vi.fn().mockResolvedValue(undefined) }));
vi.mock('../../src/modules/websocket/redis-subscriber.js', () => ({ startRedisSubscriber: vi.fn(), stopRedisSubscriber: vi.fn().mockResolvedValue(undefined), publishMatchUpdate: vi.fn(), publishRankingUpdate: vi.fn() }));
vi.mock('../../src/modules/notifications/notifications.triggers.js', () => ({ notifyMemberJoined: vi.fn(), notifyMatchStartingSoon: vi.fn(), notifyMatchStarted: vi.fn(), notifyMatchFinished: vi.fn(), notifyExactScore: vi.fn() }));

import { buildApp } from '../../src/app.js';

let app: Awaited<ReturnType<typeof buildApp>>;
const S = 'test-jwt-secret-at-least-32-chars!!';
const auth = (uid = 'u1') => ({ authorization: `Bearer ${jwt.sign({ sub: uid, email: 'u@t.com' }, S, { expiresIn: '1h' })}` });
const P = mp as Record<string, Record<string, ReturnType<typeof vi.fn>>>;
const FUTURE = new Date(Date.now() + 3_600_000);
const PAST = new Date(Date.now() - 3_600_000);
const MID = '00000000-0000-0000-0000-000000000001';

beforeEach(async () => { reset(); if (!app) app = await buildApp(); });
afterAll(async () => { await app?.close(); });

describe('POST /api/pools/:poolId/predictions', () => {
  it('401 sem token', async () => {
    const res = await app.inject({ method: 'POST', url: '/api/pools/p1/predictions', payload: { matchId: MID, homeScore: 1, awayScore: 0 } });
    expect(res.statusCode).toBe(401);
  });

  it('201 palpite em jogo futuro', async () => {
    P.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    P.match.findFirst.mockResolvedValue({ id: MID, scheduledAt: FUTURE, status: 'scheduled' });
    P.prediction.upsert.mockResolvedValue({ id: 'pr1', matchId: MID, homeScore: 1, awayScore: 0, pointsEarned: 0, updatedAt: new Date() });
    const res = await app.inject({ method: 'POST', url: '/api/pools/p1/predictions', headers: auth(), payload: { matchId: MID, homeScore: 1, awayScore: 0 } });
    expect(res.statusCode).toBe(201);
    expect(JSON.parse(res.body).homeScore).toBe(1);
  });

  it('422 jogo já iniciado', async () => {
    P.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    P.match.findFirst.mockResolvedValue({ id: MID, scheduledAt: PAST, status: 'scheduled' });
    const res = await app.inject({ method: 'POST', url: '/api/pools/p1/predictions', headers: auth(), payload: { matchId: MID, homeScore: 1, awayScore: 0 } });
    expect(res.statusCode).toBe(422);
    expect(JSON.parse(res.body).error).toBe('PREDICTION_LOCKED');
  });

  it('400 placar negativo', async () => {
    const res = await app.inject({ method: 'POST', url: '/api/pools/p1/predictions', headers: auth(), payload: { matchId: MID, homeScore: -1, awayScore: 0 } });
    expect(res.statusCode).toBe(400);
  });

  it('400 placar acima de 99', async () => {
    const res = await app.inject({ method: 'POST', url: '/api/pools/p1/predictions', headers: auth(), payload: { matchId: MID, homeScore: 100, awayScore: 0 } });
    expect(res.statusCode).toBe(400);
  });
});

describe('GET /api/pools/:poolId/predictions/me', () => {
  it('200 retorna meus palpites', async () => {
    P.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    P.prediction.findMany.mockResolvedValue([{ id: 'pr1', matchId: 'm1', homeScore: 2, awayScore: 1, pointsEarned: 3, updatedAt: new Date() }]);
    const res = await app.inject({ method: 'GET', url: '/api/pools/p1/predictions/me', headers: auth() });
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body)).toHaveLength(1);
  });

  it('403 não-membro', async () => {
    P.poolMember.findUnique.mockResolvedValue(null);
    const res = await app.inject({ method: 'GET', url: '/api/pools/p1/predictions/me', headers: auth('intruso') });
    expect(res.statusCode).toBe(403);
  });
});
