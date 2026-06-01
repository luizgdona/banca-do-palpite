import { PrismaClient } from '@prisma/client';
import {
  callFootballApi,
  mapFixtureStatus,
  type ApiFootballFixture,
} from '../../config/football-api.js';
import { getRedis, TTL } from '../../config/redis.js';
import { NotFoundError } from '../../shared/errors/AppError.js';

export class MatchesService {
  constructor(private prisma: PrismaClient) {}

  async getById(id: string) {
    const match = await this.prisma.match.findUnique({ where: { id } });
    if (!match) throw new NotFoundError('Jogo não encontrado');
    return match;
  }

  async listByCompetition(competitionId: string) {
    return this.prisma.match.findMany({
      where: { competitionId },
      orderBy: { scheduledAt: 'asc' },
    });
  }

  async listLive() {
    const redis = getRedis();
    const cacheKey = 'matches:live';
    const cached = await redis.get(cacheKey);
    if (cached) return JSON.parse(cached);

    const matches = await this.prisma.match.findMany({
      where: { status: 'live' },
      orderBy: { scheduledAt: 'asc' },
    });

    await redis.setex(cacheKey, TTL.MATCH_LIVE, JSON.stringify(matches));
    return matches;
  }

  async syncByCompetition(competitionId: string, season?: string) {
    const competition = await this.prisma.competition.findUnique({
      where: { id: competitionId },
    });
    if (!competition) throw new NotFoundError('Competição não encontrada');

    const fixtures = await callFootballApi<ApiFootballFixture[]>({
      endpoint: 'fixtures',
      params: {
        league: competition.externalId,
        season: season ?? competition.season ?? new Date().getFullYear(),
      },
      ttl: TTL.MATCH_FUTURE,
    });

    if (!fixtures) return { synced: 0 };

    let synced = 0;
    for (const f of fixtures) {
      const status = mapFixtureStatus(f.fixture.status.long);
      await this.prisma.match.upsert({
        where: { externalId: String(f.fixture.id) },
        update: {
          status: status as never,
          homeScore: f.goals.home,
          awayScore: f.goals.away,
          minute: f.fixture.status.elapsed,
          syncedAt: new Date(),
        },
        create: {
          externalId: String(f.fixture.id),
          competitionId,
          homeTeam: { id: f.teams.home.id, name: f.teams.home.name, logo: f.teams.home.logo },
          awayTeam: { id: f.teams.away.id, name: f.teams.away.name, logo: f.teams.away.logo },
          scheduledAt: new Date(f.fixture.date),
          status: status as never,
          homeScore: f.goals.home,
          awayScore: f.goals.away,
          minute: f.fixture.status.elapsed,
          syncedAt: new Date(),
        },
      });
      synced++;
    }

    return { synced };
  }
}
