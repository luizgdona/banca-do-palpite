import type { SocketStream } from '@fastify/websocket';
import type { ServerMessage } from './ws.types.js';

interface Connection {
  stream: SocketStream;
  userId: string;
  poolIds: Set<string>;
}

class ConnectionManager {
  private byUser = new Map<string, Set<Connection>>();
  private byPool = new Map<string, Set<Connection>>();

  add(conn: Connection) {
    if (!this.byUser.has(conn.userId)) {
      this.byUser.set(conn.userId, new Set());
    }
    this.byUser.get(conn.userId)!.add(conn);
  }

  remove(conn: Connection) {
    this.byUser.get(conn.userId)?.delete(conn);
    if (this.byUser.get(conn.userId)?.size === 0) {
      this.byUser.delete(conn.userId);
    }
    for (const poolId of conn.poolIds) {
      this.byPool.get(poolId)?.delete(conn);
      if (this.byPool.get(poolId)?.size === 0) {
        this.byPool.delete(poolId);
      }
    }
  }

  subscribe(conn: Connection, poolIds: string[]) {
    for (const poolId of poolIds) {
      conn.poolIds.add(poolId);
      if (!this.byPool.has(poolId)) {
        this.byPool.set(poolId, new Set());
      }
      this.byPool.get(poolId)!.add(conn);
    }
  }

  unsubscribe(conn: Connection, poolIds: string[]) {
    for (const poolId of poolIds) {
      conn.poolIds.delete(poolId);
      this.byPool.get(poolId)?.delete(conn);
      if (this.byPool.get(poolId)?.size === 0) {
        this.byPool.delete(poolId);
      }
    }
  }

  broadcastToPool(poolId: string, message: ServerMessage) {
    const conns = this.byPool.get(poolId);
    if (!conns) return;
    const payload = JSON.stringify(message);
    for (const conn of conns) {
      this.sendRaw(conn, payload);
    }
  }

  private sendRaw(conn: Connection, payload: string) {
    try {
      const ws = conn.stream.socket;
      if (ws.readyState === ws.OPEN) {
        ws.send(payload);
      }
    } catch {
      // Socket closed mid-send — safe to ignore
    }
  }

  get connectionCount() {
    let total = 0;
    for (const s of this.byUser.values()) total += s.size;
    return total;
  }
}

export const connectionManager = new ConnectionManager();
export type { Connection };
