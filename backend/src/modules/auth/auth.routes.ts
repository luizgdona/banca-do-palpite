import { FastifyInstance } from 'fastify';
import { AuthService } from './auth.service.js';
import { registerSchema, loginSchema } from './auth.schema.js';
import { z } from 'zod';
import { authGuard } from '../../shared/middleware/authGuard.js';

const REFRESH_COOKIE = 'refresh_token';
const COOKIE_OPTS = {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'lax' as const,
  path: '/',
  maxAge: 30 * 24 * 60 * 60,
};

export async function authRoutes(fastify: FastifyInstance) {
  const service = new AuthService(fastify.prisma);

  fastify.post('/auth/register', async (request, reply) => {
    const input = registerSchema.parse(request.body);
    const { user, accessToken, refreshToken } = await service.register(input);
    reply.setCookie(REFRESH_COOKIE, refreshToken, COOKIE_OPTS);
    return reply.status(201).send({ user, accessToken });
  });

  fastify.post('/auth/login', async (request, reply) => {
    const input = loginSchema.parse(request.body);
    const { user, accessToken, refreshToken } = await service.login(input);
    reply.setCookie(REFRESH_COOKIE, refreshToken, COOKIE_OPTS);
    return reply.send({ user, accessToken });
  });

  fastify.post('/auth/refresh', async (request, reply) => {
    const rawToken = request.cookies[REFRESH_COOKIE];
    if (!rawToken) {
      return reply.status(401).send({ error: 'UNAUTHORIZED', message: 'Sem refresh token' });
    }
    const { accessToken, refreshToken } = await service.refresh(rawToken);
    reply.setCookie(REFRESH_COOKIE, refreshToken, COOKIE_OPTS);
    return reply.send({ accessToken });
  });

  fastify.post('/auth/logout', async (request, reply) => {
    const rawToken = request.cookies[REFRESH_COOKIE];
    if (rawToken) await service.logout(rawToken);
    reply.clearCookie(REFRESH_COOKIE, { path: '/' });
    return reply.send({ message: 'Logout realizado' });
  });

  fastify.get('/auth/me', { preHandler: authGuard }, async (request, reply) => {
    const user = await service.getMe(request.userId);
    return reply.send(user);
  });

  // OAuth Google — recebe o idToken do cliente Flutter
  fastify.post('/auth/google', async (request, reply) => {
    const { idToken } = z.object({ idToken: z.string().min(1) }).parse(request.body);
    const { user, accessToken, refreshToken } = await service.loginWithGoogle(idToken);
    reply.setCookie(REFRESH_COOKIE, refreshToken, COOKIE_OPTS);
    return reply.send({ user, accessToken });
  });

  // Registrar/atualizar token FCM do dispositivo
  fastify.post('/auth/fcm-token', { preHandler: authGuard }, async (request, reply) => {
    const { token } = z.object({ token: z.string().min(1) }).parse(request.body);
    await service.updateFcmToken(request.userId, token);
    return reply.send({ ok: true });
  });
}
