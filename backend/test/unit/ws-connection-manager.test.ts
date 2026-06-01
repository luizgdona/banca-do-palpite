import { describe, it, expect, vi, beforeEach } from 'vitest';

// Import the singleton directly — it has no external dependencies
const { connectionManager } = await import('../../src/modules/websocket/connection-manager.js');

function makeMockStream(open = true) {
  const ws = {
    readyState: open ? 1 : 3,
    OPEN: 1,
    send: vi.fn(),
  };
  return { socket: ws };
}

beforeEach(() => {
  // Reset internal state by removing all connections through public API
});

describe('ConnectionManager', () => {
  it('adiciona e remove conexão', () => {
    const stream = makeMockStream() as never;
    const conn = { stream, userId: 'u1', poolIds: new Set<string>() };

    connectionManager.add(conn);
    expect(connectionManager.connectionCount).toBeGreaterThanOrEqual(1);

    connectionManager.remove(conn);
  });

  it('subscribe valida e registra pools', () => {
    const stream = makeMockStream() as never;
    const conn = { stream, userId: 'u1', poolIds: new Set<string>() };
    connectionManager.add(conn);

    connectionManager.subscribe(conn, ['pool-1', 'pool-2']);
    expect(conn.poolIds.has('pool-1')).toBe(true);
    expect(conn.poolIds.has('pool-2')).toBe(true);

    connectionManager.remove(conn);
  });

  it('unsubscribe remove pool específico', () => {
    const stream = makeMockStream() as never;
    const conn = { stream, userId: 'u1', poolIds: new Set<string>() };
    connectionManager.add(conn);
    connectionManager.subscribe(conn, ['pool-1', 'pool-2']);

    connectionManager.unsubscribe(conn, ['pool-1']);
    expect(conn.poolIds.has('pool-1')).toBe(false);
    expect(conn.poolIds.has('pool-2')).toBe(true);

    connectionManager.remove(conn);
  });

  it('broadcast envia mensagem para conexões subscribed', () => {
    const stream = makeMockStream() as never;
    const conn = { stream, userId: 'u1', poolIds: new Set<string>() };
    connectionManager.add(conn);
    connectionManager.subscribe(conn, ['pool-broadcast']);

    connectionManager.broadcastToPool('pool-broadcast', {
      type: 'pool:ranking_updated',
      poolId: 'pool-broadcast',
    });

    expect((stream as { socket: { send: ReturnType<typeof vi.fn> } }).socket.send).toHaveBeenCalledOnce();

    connectionManager.remove(conn);
  });

  it('broadcast não envia para socket fechado', () => {
    const stream = makeMockStream(false) as never;
    const conn = { stream, userId: 'u2', poolIds: new Set<string>() };
    connectionManager.add(conn);
    connectionManager.subscribe(conn, ['pool-closed']);

    connectionManager.broadcastToPool('pool-closed', {
      type: 'pool:ranking_updated',
      poolId: 'pool-closed',
    });

    expect((stream as { socket: { send: ReturnType<typeof vi.fn> } }).socket.send).not.toHaveBeenCalled();

    connectionManager.remove(conn);
  });

  it('broadcast para pool sem subscribers não lança', () => {
    expect(() => {
      connectionManager.broadcastToPool('pool-vazio', { type: 'pong' });
    }).not.toThrow();
  });
});
