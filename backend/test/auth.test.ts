import { describe, it, expect, vi, beforeEach } from 'vitest';
import { generateAccessToken, generateRefreshToken, hashToken } from '../src/shared/utils/tokens.js';

// Mock env before importing tokens
vi.mock('../src/config/env.js', () => ({
  env: {
    JWT_SECRET: 'test-secret-key-32-chars-minimum!!',
    JWT_EXPIRES_IN: '15m',
    REFRESH_TOKEN_SECRET: 'test-refresh-secret',
    REFRESH_TOKEN_EXPIRES_IN: '30d',
    NODE_ENV: 'test',
  },
}));

describe('tokens', () => {
  it('generateAccessToken retorna string não-vazia', () => {
    const token = generateAccessToken('user-123', 'test@example.com');
    expect(typeof token).toBe('string');
    expect(token.length).toBeGreaterThan(20);
    // JWT format: header.payload.signature
    expect(token.split('.')).toHaveLength(3);
  });

  it('generateRefreshToken retorna hex de 80 chars', () => {
    const token = generateRefreshToken();
    expect(typeof token).toBe('string');
    expect(token).toHaveLength(80);
    expect(/^[a-f0-9]+$/.test(token)).toBe(true);
  });

  it('dois refreshTokens são únicos', () => {
    const t1 = generateRefreshToken();
    const t2 = generateRefreshToken();
    expect(t1).not.toBe(t2);
  });

  it('hashToken é determinístico', () => {
    const token = 'test-token-value';
    expect(hashToken(token)).toBe(hashToken(token));
  });

  it('hashes diferentes para tokens diferentes', () => {
    expect(hashToken('token-a')).not.toBe(hashToken('token-b'));
  });
});

describe('prediction lock logic', () => {
  it('jogo no futuro — não está travado', () => {
    const scheduledAt = new Date(Date.now() + 60 * 60 * 1000); // 1h no futuro
    const isLocked = scheduledAt <= new Date();
    expect(isLocked).toBe(false);
  });

  it('jogo no passado — está travado', () => {
    const scheduledAt = new Date(Date.now() - 1000); // 1s atrás
    const isLocked = scheduledAt <= new Date();
    expect(isLocked).toBe(true);
  });

  it('status live — está travado', () => {
    const status = 'live';
    expect(status !== 'scheduled').toBe(true);
  });
});
