import { PrismaClient } from '@prisma/client';
import { sendPushToMany, type PushPayload } from './notifications.service.js';

async function getPoolMemberTokens(prisma: PrismaClient, poolId: string): Promise<string[]> {
  const members = await prisma.poolMember.findMany({
    where: { poolId },
    include: { user: { select: { fcmToken: true } } },
  });
  return members
    .map((m) => m.user.fcmToken)
    .filter((t): t is string => !!t);
}

export async function notifyMatchStartingSoon(
  prisma: PrismaClient,
  matchId: string,
) {
  const match = await prisma.match.findUnique({
    where: { id: matchId },
    include: { poolMatches: { select: { poolId: true } } },
  });
  if (!match) return;

  const home = (match.homeTeam as { name: string }).name;
  const away = (match.awayTeam as { name: string }).name;

  for (const { poolId } of match.poolMatches) {
    const payload: PushPayload = {
      title: '⚽ Vai começar em 1 hora!',
      body: `${home} × ${away} — você ainda não apostou.`,
      data: { matchId, type: 'match_starting_soon' },
    };

    // Only members who haven't predicted yet
    const unpredicted = await prisma.poolMember.findMany({
      where: {
        poolId,
        NOT: { user: { predictions: { some: { matchId, poolId } } } },
        user: { fcmToken: { not: null } },
      },
      include: { user: { select: { fcmToken: true } } },
    });
    const tokens = unpredicted.map((m) => m.user.fcmToken).filter((t): t is string => !!t);
    await sendPushToMany(tokens, payload);
  }
}

export async function notifyMatchStarted(
  prisma: PrismaClient,
  matchId: string,
) {
  const match = await prisma.match.findUnique({
    where: { id: matchId },
    include: {
      poolMatches: {
        include: { pool: { select: { name: true, id: true } } },
      },
    },
  });
  if (!match) return;

  const home = (match.homeTeam as { name: string }).name;
  const away = (match.awayTeam as { name: string }).name;

  for (const pm of match.poolMatches) {
    const payload: PushPayload = {
      title: '🟢 O jogo começou!',
      body: `${home} × ${away} — veja os palpites do ${pm.pool.name}.`,
      data: { matchId, poolId: pm.pool.id, type: 'match_started' },
    };
    const tokens = await getPoolMemberTokens(prisma, pm.pool.id);
    await sendPushToMany(tokens, payload);
  }
}

export async function notifyMatchFinished(
  prisma: PrismaClient,
  matchId: string,
) {
  const match = await prisma.match.findUnique({
    where: { id: matchId },
    include: {
      poolMatches: {
        include: { pool: { select: { name: true, id: true } } },
      },
    },
  });
  if (!match) return;

  for (const pm of match.poolMatches) {
    const payload: PushPayload = {
      title: '🏁 Fim de jogo!',
      body: `Confira sua pontuação em ${pm.pool.name}.`,
      data: { matchId, poolId: pm.pool.id, type: 'match_finished' },
    };
    const tokens = await getPoolMemberTokens(prisma, pm.pool.id);
    await sendPushToMany(tokens, payload);
  }
}

export async function notifyExactScore(
  prisma: PrismaClient,
  userId: string,
  poolId: string,
  points: number,
) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { fcmToken: true },
  });
  if (!user?.fcmToken) return;

  const pool = await prisma.pool.findUnique({
    where: { id: poolId },
    select: { name: true },
  });

  const payload: PushPayload = {
    title: '🎯 Placar exato!',
    body: `+${points} pontos em ${pool?.name ?? 'seu bolão'}. Você é o craque!`,
    data: { poolId, type: 'exact_score' },
  };
  await sendPushToMany([user.fcmToken], payload);
}

export async function notifyMemberJoined(
  prisma: PrismaClient,
  poolId: string,
  newMemberName: string,
) {
  const pool = await prisma.pool.findUnique({
    where: { id: poolId },
    include: { owner: { select: { fcmToken: true } } },
  });
  if (!pool?.owner.fcmToken) return;

  const payload: PushPayload = {
    title: `🙋 ${newMemberName} entrou!`,
    body: `Novo participante em ${pool.name}.`,
    data: { poolId, type: 'member_joined' },
  };
  await sendPushToMany([pool.owner.fcmToken], payload);
}
