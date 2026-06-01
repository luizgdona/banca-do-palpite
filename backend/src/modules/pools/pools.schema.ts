import { z } from 'zod';

export const createPoolSchema = z.object({
  name: z.string().min(3, 'Nome deve ter ao menos 3 caracteres').max(80),
  description: z.string().max(300).optional(),
  competitionId: z.string().uuid('ID de competição inválido'),
  matchIds: z.array(z.string().uuid()).min(1, 'Selecione ao menos 1 jogo'),
  scoringExact: z.number().int().min(1).max(10).default(3),
  scoringResult: z.number().int().min(0).max(10).default(1),
  isPublic: z.boolean().default(false),
});

export const updatePoolSchema = z.object({
  name: z.string().min(3).max(80).optional(),
  description: z.string().max(300).optional(),
  scoringExact: z.number().int().min(1).max(10).optional(),
  scoringResult: z.number().int().min(0).max(10).optional(),
  isPublic: z.boolean().optional(),
  status: z.enum(['open', 'closed', 'finished']).optional(),
});

export const addMatchesToPoolSchema = z.object({
  matchIds: z.array(z.string().uuid()).min(1),
});

export type CreatePoolInput = z.infer<typeof createPoolSchema>;
export type UpdatePoolInput = z.infer<typeof updatePoolSchema>;
