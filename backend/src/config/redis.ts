import Redis from 'ioredis';
import { env } from './env.js';

let redisInstance: Redis | null = null;

export function getRedis(): Redis {
  if (!redisInstance) {
    redisInstance = new Redis(env.REDIS_URL, {
      maxRetriesPerRequest: null,
      enableReadyCheck: false,
    });
    redisInstance.on('error', (err) => {
      console.error('[Redis] connection error:', err.message);
    });
  }
  return redisInstance;
}

export async function closeRedis() {
  if (redisInstance) {
    await redisInstance.quit();
    redisInstance = null;
  }
}

// Cache TTL constants (seconds)
export const TTL = {
  COMPETITION: 24 * 60 * 60,    // 24h
  MATCH_FUTURE: 60 * 60,         // 1h
  MATCH_TODAY: 5 * 60,           // 5min
  MATCH_LIVE: 60,                 // 60s
} as const;
