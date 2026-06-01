import Redis from 'ioredis';
import { env } from '../../config/env.js';
import { connectionManager } from './connection-manager.js';
import { REDIS_CHANNELS, type ServerMessage } from './ws.types.js';

let subscriber: Redis | null = null;

export function startRedisSubscriber(prisma: {
  poolMatch: { findMany: (args: { where: { matchId: string } }) => Promise<{ poolId: string }[]> };
}) {
  if (subscriber) return;

  subscriber = new Redis(env.REDIS_URL, {
    maxRetriesPerRequest: null,
    enableReadyCheck: false,
  });

  subscriber.on('error', (err) => {
    console.error('[WS Redis subscriber] error:', err.message);
  });

  // Subscribe to pattern match:updated:*
  subscriber.psubscribe('match:updated:*', 'pool:ranking:*', (err) => {
    if (err) console.error('[WS Redis subscriber] psubscribe error:', err.message);
    else console.log('[WS] Redis pub/sub subscriber ready');
  });

  subscriber.on('pmessage', async (_pattern, channel, message) => {
    try {
      const data = JSON.parse(message) as Record<string, unknown>;

      if (channel.startsWith('match:updated:')) {
        const matchId = channel.replace('match:updated:', '');
        const poolRows = await prisma.poolMatch.findMany({
          where: { matchId },
        });

        const msg: ServerMessage = data.status === 'finished'
          ? {
              type: 'match:finished',
              matchId,
              homeScore: data.homeScore as number,
              awayScore: data.awayScore as number,
            }
          : {
              type: 'match:score_update',
              matchId,
              homeScore: data.homeScore as number,
              awayScore: data.awayScore as number,
              minute: data.minute as number | null,
              status: data.status as string,
            };

        for (const row of poolRows) {
          connectionManager.broadcastToPool(row.poolId, msg);
        }

        // Reveal predictions when match starts
        if (data.status === 'live' && data.prevStatus === 'scheduled') {
          for (const row of poolRows) {
            connectionManager.broadcastToPool(row.poolId, {
              type: 'prediction:revealed',
              poolId: row.poolId,
              matchId,
            });
          }
        }
      }

      if (channel.startsWith('pool:ranking:')) {
        const poolId = channel.replace('pool:ranking:', '');
        connectionManager.broadcastToPool(poolId, {
          type: 'pool:ranking_updated',
          poolId,
        });
      }
    } catch (err) {
      console.error('[WS Redis subscriber] message handler error:', err);
    }
  });
}

export async function stopRedisSubscriber() {
  if (subscriber) {
    await subscriber.quit();
    subscriber = null;
  }
}

export function publishMatchUpdate(
  publisher: Redis,
  matchId: string,
  data: {
    homeScore: number | null;
    awayScore: number | null;
    minute: number | null;
    status: string;
    prevStatus?: string;
  },
) {
  return publisher.publish(REDIS_CHANNELS.matchUpdated(matchId), JSON.stringify(data));
}

export function publishRankingUpdate(publisher: Redis, poolId: string) {
  return publisher.publish(REDIS_CHANNELS.poolRanking(poolId), JSON.stringify({ poolId }));
}
