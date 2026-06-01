import { env } from './env.js';
import { getRedis } from './redis.js';
import { TTL } from './redis.js';

interface ApiFootballOptions {
  endpoint: string;
  params?: Record<string, string | number | boolean>;
  ttl?: number;
}

export interface ApiFootballFixture {
  fixture: {
    id: number;
    date: string;
    status: { long: string; short: string; elapsed: number | null };
  };
  league: { id: number; name: string; logo: string; season: number; round: string };
  teams: {
    home: { id: number; name: string; logo: string; winner: boolean | null };
    away: { id: number; name: string; logo: string; winner: boolean | null };
  };
  goals: { home: number | null; away: number | null };
}

export interface ApiFootballLeague {
  league: { id: number; name: string; type: string; logo: string };
  country: { name: string; code: string; flag: string };
  seasons: { year: number; current: boolean }[];
}

const STATUS_MAP: Record<string, string> = {
  'Not Started': 'scheduled',
  'First Half': 'live',
  Halftime: 'live',
  'Second Half': 'live',
  'Extra Time': 'live',
  'Break Time': 'live',
  'Penalty In Progress': 'live',
  'Match Suspended': 'live',
  'Match Interrupted': 'live',
  'Match Finished': 'finished',
  'Match Finished After Extra Time': 'finished',
  'Match Finished After Penalty': 'finished',
  'Time to be Defined': 'postponed',
  'Match Postponed': 'postponed',
  'Match Cancelled': 'cancelled',
  'Match Abandoned': 'cancelled',
  'Technical Loss': 'finished',
  'WalkOver': 'finished',
};

export function mapFixtureStatus(longStatus: string): string {
  return STATUS_MAP[longStatus] ?? 'scheduled';
}

export async function callFootballApi<T>(options: ApiFootballOptions): Promise<T | null> {
  if (!env.API_FOOTBALL_KEY) {
    return null;
  }

  const redis = getRedis();
  const cacheKey = `api_football:${options.endpoint}:${JSON.stringify(options.params ?? {})}`;
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached) as T;
  }

  const url = new URL(`${env.API_FOOTBALL_BASE_URL}/${options.endpoint}`);
  if (options.params) {
    Object.entries(options.params).forEach(([k, v]) => url.searchParams.set(k, String(v)));
  }

  const response = await fetch(url.toString(), {
    headers: {
      'x-apisports-key': env.API_FOOTBALL_KEY,
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error(`API-Football error: ${response.status} ${response.statusText}`);
  }

  const json = (await response.json()) as { response: T; errors: unknown };

  if (json.errors && Object.keys(json.errors as object).length > 0) {
    console.error('[API-Football] errors:', json.errors);
    return null;
  }

  const ttl = options.ttl ?? TTL.MATCH_TODAY;
  await redis.setex(cacheKey, ttl, JSON.stringify(json.response));

  return json.response as T;
}
