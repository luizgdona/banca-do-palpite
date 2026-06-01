import { Queue, Worker, Job } from 'bullmq';
import { PrismaClient } from '@prisma/client';
import { env } from '../../config/env.js';
import { getRedis } from '../../config/redis.js';

// BullMQ bundles its own ioredis — pass connection options, not a shared instance
const bullConnection = { url: env.REDIS_URL } as const;
import { callFootballApi, mapFixtureStatus, type ApiFootballFixture } from '../../config/football-api.js';
import { calculatePointsForMatch } from './calculate-points.js';
import { publishMatchUpdate, publishRankingUpdate } from '../websocket/redis-subscriber.js';

const QUEUE_NAME = 'sync-live-scores';

let queue: Queue | null = null;
let worker: Worker | null = null;

export function getLiveScoresQueue(): Queue {
  if (!queue) {
    queue = new Queue(QUEUE_NAME, {
      connection: bullConnection,
      defaultJobOptions: { removeOnComplete: 10, removeOnFail: 20 },
    });
  }
  return queue;
}

export function startLiveScoresWorker(prisma: PrismaClient) {
  if (worker) return;

  worker = new Worker(
    QUEUE_NAME,
    async (job: Job) => {
      await syncLiveScores(prisma, job);
    },
    { connection: bullConnection, concurrency: 1 },
  );

  worker.on('failed', (job, err) => {
    console.error(`[LiveScores] job ${job?.id} failed:`, err.message);
  });

  console.log('[LiveScores] worker started');
}

async function syncLiveScores(prisma: PrismaClient, job: Job) {
  const redis = getRedis();

  const liveFixtures = await callFootballApi<ApiFootballFixture[]>({
    endpoint: 'fixtures',
    params: { live: 'all' },
    ttl: 55, // just under 60s so next poll always fetches fresh
  });

  if (!liveFixtures || liveFixtures.length === 0) {
    await job.updateProgress(100);
    return { updated: 0 };
  }

  let updated = 0;

  for (const fixture of liveFixtures) {
    const externalId = String(fixture.fixture.id);
    const newStatus = mapFixtureStatus(fixture.fixture.status.long);

    const existing = await prisma.match.findUnique({
      where: { externalId },
      select: { id: true, status: true, homeScore: true, awayScore: true },
    });

    if (!existing) continue;

    const prevStatus = existing.status;
    const scoreChanged =
      existing.homeScore !== fixture.goals.home ||
      existing.awayScore !== fixture.goals.away ||
      prevStatus !== newStatus;

    if (!scoreChanged) continue;

    await prisma.match.update({
      where: { externalId },
      data: {
        status: newStatus as never,
        homeScore: fixture.goals.home,
        awayScore: fixture.goals.away,
        minute: fixture.fixture.status.elapsed,
        syncedAt: new Date(),
      },
    });

    // Publish to WebSocket subscribers
    await publishMatchUpdate(redis, existing.id, {
      homeScore: fixture.goals.home ?? 0,
      awayScore: fixture.goals.away ?? 0,
      minute: fixture.fixture.status.elapsed,
      status: newStatus,
      prevStatus,
    });

    // Calculate points and notify ranking if match just finished
    if (newStatus === 'finished' && prevStatus !== 'finished') {
      await calculatePointsForMatch(prisma, existing.id);

      // Find all pools with this match and publish ranking updates
      const poolRows = await prisma.poolMatch.findMany({
        where: { matchId: existing.id },
        select: { poolId: true },
      });
      for (const row of poolRows) {
        await publishRankingUpdate(redis, row.poolId);
      }
    }

    updated++;
  }

  await job.updateProgress(100);
  return { updated, liveCount: liveFixtures.length };
}

// Schedule the repeatable job — runs every 60s
export async function scheduleLiveScoresJob() {
  const q = getLiveScoresQueue();

  // Remove any existing repeatable jobs first to avoid duplicates on restart
  const repeatables = await q.getRepeatableJobs();
  for (const r of repeatables) {
    await q.removeRepeatableByKey(r.key);
  }

  await q.add('sync', {}, { repeat: { every: 60_000 } });
  console.log('[LiveScores] repeatable job scheduled every 60s');
}

export async function stopLiveScoresWorker() {
  if (worker) {
    await worker.close();
    worker = null;
  }
  if (queue) {
    await queue.close();
    queue = null;
  }
}
