import { FastifyInstance } from 'fastify';
import type { SocketStream } from '@fastify/websocket';
import jwt from 'jsonwebtoken';
import { env } from '../../config/env.js';
import { connectionManager } from './connection-manager.js';
import { startRedisSubscriber } from './redis-subscriber.js';
import type { ClientMessage } from './ws.types.js';

interface JwtPayload { sub: string; email: string }

export async function wsRoutes(fastify: FastifyInstance) {
  fastify.addHook('onReady', () => {
    startRedisSubscriber(fastify.prisma);
  });

  fastify.get('/ws', { websocket: true }, (stream: SocketStream, request) => {
    const ws = stream.socket;
    const token = (request.query as Record<string, string>).token;

    let userId: string;
    try {
      const payload = jwt.verify(token, env.JWT_SECRET) as JwtPayload;
      userId = payload.sub;
    } catch {
      ws.send(JSON.stringify({ type: 'error', message: 'Token inválido' }));
      ws.close(4001);
      return;
    }

    const conn = { stream, userId, poolIds: new Set<string>() };
    connectionManager.add(conn);

    fastify.log.info(
      `[WS] connected user=${userId} total=${connectionManager.connectionCount}`,
    );

    // Server-side heartbeat — keeps proxies from closing idle connections
    const pingInterval = setInterval(() => {
      if (ws.readyState === ws.OPEN) {
        ws.send(JSON.stringify({ type: 'pong' }));
      }
    }, 30_000);

    ws.on('message', (raw: Buffer) => {
      let msg: ClientMessage;
      try {
        msg = JSON.parse(raw.toString()) as ClientMessage;
      } catch {
        return;
      }

      switch (msg.type) {
        case 'subscribe':
          // Validate membership before subscribing — never trust the client
          fastify.prisma.poolMember
            .findMany({
              where: { userId, poolId: { in: msg.poolIds } },
              select: { poolId: true },
            })
            .then((rows) => {
              const allowed = rows.map((r) => r.poolId);
              connectionManager.subscribe(conn, allowed);
            })
            .catch(() => {});
          break;

        case 'unsubscribe':
          connectionManager.unsubscribe(conn, msg.poolIds);
          break;

        case 'ping':
          ws.send(JSON.stringify({ type: 'pong' }));
          break;
      }
    });

    ws.on('close', () => {
      clearInterval(pingInterval);
      connectionManager.remove(conn);
      fastify.log.info(
        `[WS] disconnected user=${userId} total=${connectionManager.connectionCount}`,
      );
    });

    ws.on('error', (err: Error) => {
      fastify.log.error(`[WS] error user=${userId}: ${err.message}`);
    });
  });
}
