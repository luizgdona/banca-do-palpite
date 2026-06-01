// Mensagens enviadas do servidor para o cliente
export type ServerMessage =
  | { type: 'match:score_update'; matchId: string; homeScore: number; awayScore: number; minute: number | null; status: string }
  | { type: 'match:finished';     matchId: string; homeScore: number; awayScore: number }
  | { type: 'pool:ranking_updated'; poolId: string }
  | { type: 'prediction:revealed'; poolId: string; matchId: string }
  | { type: 'pong' };

// Mensagens enviadas do cliente para o servidor
export type ClientMessage =
  | { type: 'subscribe';   poolIds: string[] }
  | { type: 'unsubscribe'; poolIds: string[] }
  | { type: 'ping' };

// Canais Redis pub/sub
export const REDIS_CHANNELS = {
  matchUpdated: (matchId: string) => `match:updated:${matchId}`,
  poolRanking:  (poolId: string)  => `pool:ranking:${poolId}`,
} as const;
