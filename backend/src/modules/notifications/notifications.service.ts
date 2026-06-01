import { env } from '../../config/env.js';

// Firebase Admin é inicializado de forma lazy somente se as credenciais estiverem presentes.
// Em desenvolvimento sem credenciais, as notificações são logadas e ignoradas silenciosamente.

let _app: unknown = null;

async function getFirebaseApp() {
  if (_app) return _app;

  if (!env.FIREBASE_PROJECT_ID || !env.FIREBASE_PRIVATE_KEY || !env.FIREBASE_CLIENT_EMAIL) {
    return null;
  }

  const admin = await import('firebase-admin');
  _app = admin.default.initializeApp({
    credential: admin.default.credential.cert({
      projectId: env.FIREBASE_PROJECT_ID,
      // Private key vem como string com \n literal — restaura quebras de linha
      privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      clientEmail: env.FIREBASE_CLIENT_EMAIL,
    }),
  });
  return _app;
}

export interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

export async function sendPushToUser(fcmToken: string, payload: PushPayload): Promise<boolean> {
  const app = await getFirebaseApp();
  if (!app) {
    console.debug('[Push] Firebase não configurado — notificação ignorada:', payload.title);
    return false;
  }

  try {
    const admin = await import('firebase-admin');
    await admin.default.messaging().send({
      token: fcmToken,
      notification: { title: payload.title, body: payload.body },
      data: payload.data ?? {},
      android: {
        priority: 'high',
        notification: { sound: 'default', channelId: 'bolao_channel' },
      },
      apns: {
        payload: { aps: { sound: 'default', badge: 1 } },
      },
    });
    return true;
  } catch (err: unknown) {
    // Token inválido/expirado — logar mas não explodir
    const message = err instanceof Error ? err.message : String(err);
    console.warn('[Push] falha ao enviar para token:', message);
    return false;
  }
}

export async function sendPushToMany(fcmTokens: string[], payload: PushPayload): Promise<void> {
  if (fcmTokens.length === 0) return;
  await Promise.allSettled(fcmTokens.map((t) => sendPushToUser(t, payload)));
}
