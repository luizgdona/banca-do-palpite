import { describe, it, expect, vi, beforeEach, afterAll } from 'vitest';
import jwt from 'jsonwebtoken';

const { mp, reset } = vi.hoisted(() => {
  const fn = () => vi.fn();
  const p: Record<string, unknown> = {
    user:         { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), upsert: fn(), delete: fn(), count: fn() },
    refreshToken: { findUnique: fn(), create: fn(), delete: fn(), deleteMany: fn() },
    competition:  { findUnique: fn(), findMany: fn(), count: fn() },
    match:        { findUnique: fn(), findFirst: fn(), findMany: fn(), create: fn(), update: fn(), upsert: fn(), count: fn() },
    pool:         { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), delete: fn() },
    poolMatch:    { findMany: fn(), createMany: fn(), delete: fn() },
    poolMember:   { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), delete: fn(), count: fn() },
    prediction:   { findUnique: fn(), findMany: fn(), upsert: fn(), count: fn(), groupBy: fn() },
    pointEvent:   { findFirst: fn(), findMany: fn(), create: fn(), deleteMany: fn() },
    $disconnect:  fn(),
    $transaction: fn(),
  };
  (p.$transaction as ReturnType<typeof vi.fn>).mockImplementation((cb: (t: unknown) => Promise<unknown>) => cb(p));
  const reset = () => {
    for (const v of Object.values(p)) {
      if (v && typeof v === 'object') {
        for (const f of Object.values(v as Record<string, unknown>)) {
          if (f && typeof (f as { mockReset?: () => void }).mockReset === 'function') (f as { mockReset: () => void }).mockReset();
        }
      }
    }
    (p.$transaction as ReturnType<typeof vi.fn>).mockImplementation((cb: (t: unknown) => Promise<unknown>) => cb(p));
  };
  return { mp: p, reset };
});

vi.mock('@prisma/client', () => ({ PrismaClient: vi.fn(function() { return mp; }) }));
vi.mock('../../src/config/env.js', () => ({ env: { PORT: '3001', NODE_ENV: 'test', FRONTEND_URL: 'http://localhost:4000', DATABASE_URL: 'postgresql://x@x/x', REDIS_URL: 'redis://localhost:6379', JWT_SECRET: 'test-jwt-secret-at-least-32-chars!!', JWT_EXPIRES_IN: '15m', REFRESH_TOKEN_SECRET: 'test-refresh-secret-32chars!!!!!', REFRESH_TOKEN_EXPIRES_IN: '30d', SYNC_ADMIN_KEY: 'k', FIREBASE_PROJECT_ID: '', FIREBASE_PRIVATE_KEY: '', FIREBASE_CLIENT_EMAIL: '', GOOGLE_CLIENT_ID: '' } }));
vi.mock('../../src/config/redis.js', () => ({ getRedis: vi.fn(() => ({ get: vi.fn().mockResolvedValue(null), set: vi.fn(), setex: vi.fn(), del: vi.fn(), keys: vi.fn().mockResolvedValue([]), publish: vi.fn(), quit: vi.fn(), on: vi.fn(), psubscribe: vi.fn() })), closeRedis: vi.fn(), TTL: {} }));
vi.mock('../../src/modules/sync/live-scores.job.js', () => ({ startLiveScoresWorker: vi.fn(), scheduleLiveScoresJob: vi.fn().mockResolvedValue(undefined), stopLiveScoresWorker: vi.fn().mockResolvedValue(undefined) }));
vi.mock('../../src/modules/sync/upcoming-matches.job.js', () => ({ startUpcomingWorker: vi.fn(), scheduleUpcomingJob: vi.fn().mockResolvedValue(undefined), stopUpcomingWorker: vi.fn().mockResolvedValue(undefined) }));
vi.mock('../../src/modules/websocket/redis-subscriber.js', () => ({ startRedisSubscriber: vi.fn(), stopRedisSubscriber: vi.fn().mockResolvedValue(undefined), publishMatchUpdate: vi.fn(), publishRankingUpdate: vi.fn() }));

import bcrypt from 'bcryptjs';
import { buildApp } from '../../src/app.js';

let app: Awaited<ReturnType<typeof buildApp>>;
beforeEach(async () => { reset(); if (!app) app = await buildApp(); });
afterAll(async () => { await app?.close(); });

const P = mp as Record<string, Record<string, ReturnType<typeof vi.fn>>>;

describe('POST /api/auth/register', () => {
  it('201 dados válidos', async () => {
    P.user.findUnique.mockResolvedValue(null);
    P.user.create.mockResolvedValue({ id: 'u1', name: 'Rafael', email: 'r@t.com', passwordHash: 'h', avatarUrl: null, createdAt: new Date() });
    P.refreshToken.create.mockResolvedValue({});
    const res = await app.inject({ method: 'POST', url: '/api/auth/register', payload: { name: 'Rafael', email: 'r@t.com', password: 'senha123' } });
    expect(res.statusCode).toBe(201);
    expect(JSON.parse(res.body).accessToken).toBeTruthy();
  });
  it('409 email duplicado', async () => {
    P.user.findUnique.mockResolvedValue({ id: 'u1' });
    const res = await app.inject({ method: 'POST', url: '/api/auth/register', payload: { name: 'Rafael', email: 'r@t.com', password: 'senha123' } });
    expect(res.statusCode).toBe(409);
  });
  it('400 senha curta', async () => {
    const res = await app.inject({ method: 'POST', url: '/api/auth/register', payload: { name: 'X', email: 'x@t.com', password: '123' } });
    expect(res.statusCode).toBe(400);
  });
  it('400 email inválido', async () => {
    const res = await app.inject({ method: 'POST', url: '/api/auth/register', payload: { name: 'X', email: 'invalido', password: 'senha123' } });
    expect(res.statusCode).toBe(400);
  });
});

describe('POST /api/auth/login', () => {
  it('200 credenciais válidas', async () => {
    const hash = await bcrypt.hash('senha123', 1);
    P.user.findUnique.mockResolvedValue({ id: 'u1', name: 'X', email: 'r@t.com', passwordHash: hash, avatarUrl: null });
    P.refreshToken.create.mockResolvedValue({});
    const res = await app.inject({ method: 'POST', url: '/api/auth/login', payload: { email: 'r@t.com', password: 'senha123' } });
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body).accessToken).toBeTruthy();
  });
  it('401 senha errada', async () => {
    const hash = await bcrypt.hash('correta', 1);
    P.user.findUnique.mockResolvedValue({ id: 'u1', email: 'r@t.com', passwordHash: hash, avatarUrl: null, name: 'X' });
    const res = await app.inject({ method: 'POST', url: '/api/auth/login', payload: { email: 'r@t.com', password: 'errada' } });
    expect(res.statusCode).toBe(401);
  });
  it('401 usuário inexistente', async () => {
    P.user.findUnique.mockResolvedValue(null);
    const res = await app.inject({ method: 'POST', url: '/api/auth/login', payload: { email: 'n@n.com', password: 'q' } });
    expect(res.statusCode).toBe(401);
  });
});

describe('GET /api/auth/me', () => {
  it('401 sem token', async () => {
    const res = await app.inject({ method: 'GET', url: '/api/auth/me' });
    expect(res.statusCode).toBe(401);
  });
  it('401 token malformado', async () => {
    const res = await app.inject({ method: 'GET', url: '/api/auth/me', headers: { authorization: 'Bearer invalido' } });
    expect(res.statusCode).toBe(401);
  });
  it('200 token válido', async () => {
    const token = jwt.sign({ sub: 'u1', email: 'r@t.com' }, 'test-jwt-secret-at-least-32-chars!!', { expiresIn: '1h' });
    P.user.findUnique.mockResolvedValue({ id: 'u1', name: 'Rafael', email: 'r@t.com', avatarUrl: null, provider: 'email', createdAt: new Date() });
    const res = await app.inject({ method: 'GET', url: '/api/auth/me', headers: { authorization: `Bearer ${token}` } });
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body).email).toBe('r@t.com');
  });
});

describe('GET /health', () => {
  it('200', async () => {
    const res = await app.inject({ method: 'GET', url: '/health' });
    expect(res.statusCode).toBe(200);
    expect(JSON.parse(res.body)).toHaveProperty('timestamp');
  });
});
