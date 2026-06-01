import { Queue, Worker } from 'bullmq';
import { PrismaClient } from '@prisma/client';
import { env } from '../../config/env.js';
import { notifyMatchStartingSoon } from '../notifications/notifications.triggers.js';

const QUEUE_NAME = 'check-upcoming-matches';
const bullConnection = { url: env.REDIS_URL } as const;

let queue: Queue | null = null;
let worker: Worker | null = null;

export function getUpcomingQueue(): Queue {
  if (!queue) {
    queue = new Queue(QUEUE_NAME, {
      connection: bullConnection,
      defaultJobOptions: { removeOnComplete: 5, removeOnFail: 10 },
    });
  }
  return queue;
}

export function startUpcomingWorker(prisma: PrismaClient) {
  if (worker) return;

  worker = new Worker(
    QUEUE_NAME,
    async () => {
      const in1h = new Date(Date.now() + 60 * 60 * 1000);
      const in65min = new Date(Date.now() + 65 * 60 * 1000);

      // Matches starting in ~1h that haven't been notified yet
      const matches = await prisma.match.findMany({
        where: {
          status: 'scheduled',
          scheduledAt: { gte: in1h, lte: in65min },
        },
        select: { id: true },
      });

      await Promise.allSettled(
        matches.map((m) => notifyMatchStartingSoon(prisma, m.id)),
      );
    },
    { connection: bullConnection, concurrency: 1 },
  );

  worker.on('failed', (job, err) => {
    console.error(`[Upcoming] job ${job?.id} failed:`, err.message);
  });
}

export async function scheduleUpcomingJob() {
  const q = getUpcomingQueue();
  const repeatables = await q.getRepeatableJobs();
  for (const r of repeatables) await q.removeRepeatableByKey(r.key);
  // Check every 5 minutes
  await q.add('check', {}, { repeat: { every: 5 * 60 * 1000 } });
  console.log('[Upcoming] repeatable job scheduled every 5min');
}

export async function stopUpcomingWorker() {
  if (worker) { await worker.close(); worker = null; }
  if (queue)  { await queue.close();  queue  = null; }
}
