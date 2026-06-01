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
  const reset = () => { for (const v of Object.values(p)) { if (v && typeof v === 'object') for (const f of Object.values(v as Record<string, unknown>)) { if (f && typeof (f as { mockReset?: () => void }).mockReset === 'function') (f as { mockReset: () => void }).mockReset(); } } (p.$transaction as ReturnType<typeof vi.fn>).mockImplementation((cb: (t: unknown) => Promise<unknown>) => cb(p)); };
  return { mp: p, reset };
});

vi.mock('@prisma/client', () => ({ PrismaClient: vi.fn(function() { return mp; }) }));
vi.mock('../../src/config/env.js', () => ({ env: { PORT: '3002', NODE_ENV: 'test', FRONTEND_URL: 'http://localhost:4000', DATABASE_URL: 'postgresql://x@x/x', REDIS_URL: 'redis://localhost:6379', JWT_SECRET: 'test-jwt-secret-at-least-32-chars!!', JWT_EXPIRES_IN: '15m', REFRESH_TOKEN_SECRET: 'test-refresh-secret-32chars!!!!!', REFRESH_TOKEN_EXPIRES_IN: '30d', SYNC_ADMIN_KEY: 'k', FIREBASE_PROJECT_ID: '', FIREBASE_PRIVATE_KEY: '', FIREBASE_CLIENT_EMAIL: '', GOOGLE_CLIENT_ID: '' } }));
vi.mock('../../src/config/redis.js', () => ({ getRedis: vi.fn(() => ({ get: vi.fn().mockResolvedValue(null), set: vi.fn(), setex: vi.fn(), del: vi.fn(), keys: vi.fn().mockResolvedValue([]), publish: vi.fn(), quit: vi.fn(), on: vi.fn(), psubscribe: vi.fn() })), closeRedis: vi.fn(), TTL: {} }));
vi.mock('../../src/modules/sync/live-scores.job.js', () => ({ startLiveScoresWorker: vi.fn(), scheduleLiveScoresJob: vi.fn().mockResolvedValue(undefined), stopLiveScoresWorker: vi.fn().mockResolvedValue(undefined) }));
vi.mock('../../src/modules/sync/upcoming-matches.job.js', () => ({ startUpcomingWorker: vi.fn(), scheduleUpcomingJob: vi.fn().mockResolvedValue(undefined), stopUpcomingWorker: vi.fn().mockResolvedValue(undefined) }));
vi.mock('../../src/modules/websocket/redis-subscriber.js', () => ({ startRedisSubscriber: vi.fn(), stopRedisSubscriber: vi.fn().mockResolvedValue(undefined), publishMatchUpdate: vi.fn(), publishRankingUpdate: vi.fn() }));
vi.mock('../../src/modules/notifications/notifications.triggers.js', () => ({ notifyMemberJoined: vi.fn().mockResolvedValue(undefined), notifyMatchStartingSoon: vi.fn(), notifyMatchStarted: vi.fn(), notifyMatchFinished: vi.fn(), notifyExactScore: vi.fn() }));

import { buildApp } from '../../src/app.js';

let app: Awaited<ReturnType<typeof buildApp>>;
const S = 'test-jwt-secret-at-least-32-chars!!';
const auth = (uid = 'u1') => ({ authorization: `Bearer ${jwt.sign({ sub: uid, email: 'u@t.com' }, S, { expiresIn: '1h' })}` });
const P = mp as Record<string, Record<string, ReturnType<typeof vi.fn>>>;
const POOL = { id: 'p1', name: 'Bolão', description: null, ownerId: 'u1', competitionId: '00000000-0000-0000-0000-000000000001', inviteCode: 'ABCD1234', inviteUrl: null, scoringExact: 3, scoringResult: 1, isPublic: false, status: 'open', createdAt: new Date(), owner: { id: 'u1', name: 'R', avatarUrl: null }, competition: { id: 'c1', name: 'L', country: 'BR', logoUrl: null, season: '2024' }, _count: { members: 1, poolMatches: 2 } };

beforeEach(async () => { reset(); if (!app) app = await buildApp(); });
afterAll(async () => { await app?.close(); });

describe('GET /api/pools/join/:code', () => {
  it('200 sem auth', async () => {
    P.pool.findUnique.mockResolvedValue(POOL);
    const res = await app.inject({ method: 'GET', url: '/api/pools/join/ABCD1234' });
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body).inviteCode).toBe('ABCD1234');
  });
  it('404 código inválido', async () => {
    P.pool.findUnique.mockResolvedValue(null);
    const res = await app.inject({ method: 'GET', url: '/api/pools/join/ZZZZZZZZ' });
    expect(res.statusCode).toBe(404);
  });
});

describe('POST /api/pools', () => {
  it('401 sem auth', async () => {
    const res = await app.inject({ method: 'POST', url: '/api/pools', payload: {} });
    expect(res.statusCode).toBe(401);
  });
  it('201 dados válidos', async () => {
    P.match.findMany.mockResolvedValue([{ id: '00000000-0000-0000-0000-000000000001' }, { id: '00000000-0000-0000-0000-000000000002' }]);
    P.pool.create.mockResolvedValue(POOL);
    const res = await app.inject({ method: 'POST', url: '/api/pools', headers: auth(), payload: { name: 'Bolão', competitionId: '00000000-0000-0000-0000-000000000001', matchIds: ['00000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000002'], scoringExact: 3, scoringResult: 1, isPublic: false } });
    expect(res.statusCode).toBe(201);
  });
  it('400 nome curto', async () => {
    const res = await app.inject({ method: 'POST', url: '/api/pools', headers: auth(), payload: { name: 'AB', competitionId: '00000000-0000-0000-0000-000000000001', matchIds: ['m1'], scoringExact: 3, scoringResult: 1 } });
    expect(res.statusCode).toBe(400);
  });
  it('400 sem jogos', async () => {
    const res = await app.inject({ method: 'POST', url: '/api/pools', headers: auth(), payload: { name: 'Bolão', competitionId: '00000000-0000-0000-0000-000000000001', matchIds: [], scoringExact: 3, scoringResult: 1 } });
    expect(res.statusCode).toBe(400);
  });
});

describe('GET /api/pools', () => {
  it('401 sem auth', async () => {
    const res = await app.inject({ method: 'GET', url: '/api/pools' });
    expect(res.statusCode).toBe(401);
  });
  it('200 retorna lista', async () => {
    P.pool.findMany.mockResolvedValue([POOL]);
    const res = await app.inject({ method: 'GET', url: '/api/pools', headers: auth() });
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body)).toHaveLength(1);
  });
});

describe('POST /api/pools/join/:code/confirm', () => {
  it('201 entrou no bolão', async () => {
    P.pool.findUnique.mockResolvedValue({ id: 'p1', status: 'open' });
    P.poolMember.findUnique.mockResolvedValue(null);
    P.poolMember.create.mockResolvedValue({});
    P.user.findUnique.mockResolvedValue({ name: 'Novo' });
    const res = await app.inject({ method: 'POST', url: '/api/pools/join/ABCD1234/confirm', headers: auth('u2') });
    expect(res.statusCode).toBe(201);
    expect(JSON.parse(res.body).poolId).toBe('p1');
  });
  it('409 já é membro', async () => {
    P.pool.findUnique.mockResolvedValue({ id: 'p1', status: 'open' });
    P.poolMember.findUnique.mockResolvedValue({ poolId: 'p1', userId: 'u1' });
    const res = await app.inject({ method: 'POST', url: '/api/pools/join/ABCD1234/confirm', headers: auth('u1') });
    expect(res.statusCode).toBe(409);
  });
});
