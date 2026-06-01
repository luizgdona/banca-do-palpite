import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { authGuard } from '../../shared/middleware/authGuard.js';
import { NotFoundError } from '../../shared/errors/AppError.js';

const updateMeSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  avatarUrl: z.string().url().optional(),
});

export async function usersRoutes(fastify: FastifyInstance) {
  fastify.get('/users/me', { preHandler: authGuard }, async (request, reply) => {
    const user = await fastify.prisma.user.findUnique({
      where: { id: request.userId },
      select: { id: true, name: true, email: true, avatarUrl: true, provider: true, createdAt: true },
    });
    if (!user) throw new NotFoundError();
    return reply.send(user);
  });

  fastify.put('/users/me', { preHandler: authGuard }, async (request, reply) => {
    const input = updateMeSchema.parse(request.body);
    const user = await fastify.prisma.user.update({
      where: { id: request.userId },
      data: input,
      select: { id: true, name: true, email: true, avatarUrl: true },
    });
    return reply.send(user);
  });
}
