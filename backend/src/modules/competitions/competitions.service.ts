import { PrismaClient } from '@prisma/client';
import { callFootballApi, type ApiFootballLeague } from '../../config/football-api.js';
import { TTL } from '../../config/redis.js';
import { getRedis } from '../../config/redis.js';
import { NotFoundError } from '../../shared/errors/AppError.js';

export class CompetitionsService {
  constructor(private prisma: PrismaClient) {}

  async list(search?: string) {
    const redis = getRedis();
    const cacheKey = `competitions:list:${search ?? ''}`;
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const competitions = await this.prisma.competition.findMany({
      where: {
        isActive: true,
        ...(search
          ? { name: { contains: search, mode: 'insensitive' } }
          : {}),
      },
      orderBy: [{ country: 'asc' }, { name: 'asc' }],
      select: {
        id: true,
        externalId: true,
        name: true,
        country: true,
        logoUrl: true,
        season: true,
        type: true,
      },
    });

    await redis.setex(cacheKey, 300, JSON.stringify(competitions));
    return competitions;
  }

  async getById(id: string) {
    const competition = await this.prisma.competition.findUnique({
      where: { id },
      include: {
        matches: {
          orderBy: { scheduledAt: 'asc' },
          select: {
            id: true,
            externalId: true,
            homeTeam: true,
            awayTeam: true,
            scheduledAt: true,
            status: true,
            homeScore: true,
            awayScore: true,
            minute: true,
            period: true,
          },
        },
      },
    });
    if (!competition) throw new NotFoundError('Competição não encontrada');
    return competition;
  }

  async syncFromApi() {
    const data = await callFootballApi<ApiFootballLeague[]>({
      endpoint: 'leagues',
      params: { current: true, type: 'league' },
      ttl: TTL.COMPETITION,
    });

    if (!data) return { synced: 0 };

    let synced = 0;
    for (const item of data) {
      const currentSeason = item.seasons.find((s) => s.current);
      if (!currentSeason) continue;

      await this.prisma.competition.upsert({
        where: { externalId: String(item.league.id) },
        update: {
          name: item.league.name,
          country: item.country.name,
          logoUrl: item.league.logo,
          season: String(currentSeason.year),
          isActive: true,
          syncedAt: new Date(),
        },
        create: {
          externalId: String(item.league.id),
          name: item.league.name,
          country: item.country.name,
          logoUrl: item.league.logo,
          season: String(currentSeason.year),
          type: 'league',
          syncedAt: new Date(),
        },
      });
      synced++;
    }

    // Invalidate list cache
    const redis = getRedis();
    const keys = await redis.keys('competitions:list:*');
    if (keys.length) await redis.del(...keys);

    return { synced };
  }
}
