import { PrismaClient } from '@prisma/client';

interface PointsResult {
  matchId: string;
  processed: number;
  skipped: number;
}

function calcPoints(
  predHome: number,
  predAway: number,
  realHome: number,
  realAway: number,
  scoringExact: number,
  scoringResult: number,
): { points: number; reason: 'exact_score' | 'correct_result' | 'no_points' } {
  if (predHome === realHome && predAway === realAway) {
    return { points: scoringExact, reason: 'exact_score' };
  }

  const predResult = Math.sign(predHome - predAway);
  const realResult = Math.sign(realHome - realAway);

  if (predResult === realResult) {
    return { points: scoringResult, reason: 'correct_result' };
  }

  return { points: 0, reason: 'no_points' };
}

export async function calculatePointsForMatch(
  prisma: PrismaClient,
  matchId: string,
): Promise<PointsResult> {
  const match = await prisma.match.findUnique({
    where: { id: matchId },
    select: { id: true, status: true, homeScore: true, awayScore: true },
  });

  if (!match || match.status !== 'finished') {
    return { matchId, processed: 0, skipped: 0 };
  }

  if (match.homeScore === null || match.awayScore === null) {
    return { matchId, processed: 0, skipped: 0 };
  }

  // Find all pools that have this match
  const poolMatches = await prisma.poolMatch.findMany({
    where: { matchId },
    select: {
      poolId: true,
      pool: { select: { scoringExact: true, scoringResult: true } },
    },
  });

  let processed = 0;
  let skipped = 0;

  for (const pm of poolMatches) {
    // Skip if already processed
    const alreadyDone = await prisma.pointEvent.findFirst({
      where: { poolId: pm.poolId, matchId },
    });
    if (alreadyDone) {
      skipped++;
      continue;
    }

    const predictions = await prisma.prediction.findMany({
      where: { poolId: pm.poolId, matchId },
      select: { id: true, userId: true, homeScore: true, awayScore: true },
    });

    // Process all predictions in a transaction
    await prisma.$transaction(async (tx) => {
      for (const pred of predictions) {
        const { points, reason } = calcPoints(
          pred.homeScore,
          pred.awayScore,
          match.homeScore!,
          match.awayScore!,
          pm.pool.scoringExact,
          pm.pool.scoringResult,
        );

        await tx.prediction.update({
          where: { id: pred.id },
          data: { pointsEarned: points },
        });

        await tx.pointEvent.create({
          data: {
            poolId: pm.poolId,
            matchId,
            userId: pred.userId,
            points,
            reason,
          },
        });

        if (points > 0) {
          await tx.poolMember.update({
            where: { poolId_userId: { poolId: pm.poolId, userId: pred.userId } },
            data: { totalPoints: { increment: points } },
          });
        }
      }
    });

    processed++;
  }

  return { matchId, processed, skipped };
}
