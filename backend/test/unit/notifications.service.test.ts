import { describe, it, expect, vi, beforeEach } from 'vitest';

vi.mock('../../src/config/env.js', () => ({
  env: {
    FIREBASE_PROJECT_ID: '',
    FIREBASE_PRIVATE_KEY: '',
    FIREBASE_CLIENT_EMAIL: '',
    NODE_ENV: 'test',
  },
}));

const { sendPushToUser, sendPushToMany } = await import(
  '../../src/modules/notifications/notifications.service.js'
);

beforeEach(() => vi.clearAllMocks());

describe('sendPushToUser', () => {
  it('retorna false e não lança sem credenciais Firebase', async () => {
    const result = await sendPushToUser('fcm-token', {
      title: 'Teste',
      body: 'Mensagem',
    });
    expect(result).toBe(false);
  });
});

describe('sendPushToMany', () => {
  it('não lança para array vazio', async () => {
    await expect(
      sendPushToMany([], { title: 'T', body: 'B' }),
    ).resolves.toBeUndefined();
  });

  it('processa múltiplos tokens silenciosamente sem Firebase', async () => {
    await expect(
      sendPushToMany(['t1', 't2', 't3'], { title: 'T', body: 'B' }),
    ).resolves.toBeUndefined();
  });
});
