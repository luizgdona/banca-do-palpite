import { z } from 'zod';

export const upsertPredictionSchema = z.object({
  matchId: z.string().uuid(),
  homeScore: z.number().int().min(0).max(99),
  awayScore: z.number().int().min(0).max(99),
});

export const batchUpsertSchema = z.object({
  predictions: z.array(upsertPredictionSchema).min(1).max(50),
});

export type UpsertPredictionInput = z.infer<typeof upsertPredictionSchema>;
export type BatchUpsertInput = z.infer<typeof batchUpsertSchema>;
