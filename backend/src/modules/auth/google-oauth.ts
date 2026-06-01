import { env } from '../../config/env.js';

interface GoogleTokenInfo {
  sub: string;
  email: string;
  name: string;
  picture?: string;
  email_verified: boolean;
}

// Raw response from Google has email_verified as string "true"/"false"
interface RawTokenInfo {
  sub: string;
  email: string;
  name: string;
  picture?: string;
  email_verified: string;
  aud: string;
}

export async function verifyGoogleIdToken(idToken: string): Promise<GoogleTokenInfo> {
  const res = await fetch(
    `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`,
  );

  if (!res.ok) {
    throw new Error('Google token inválido');
  }

  const data = (await res.json()) as RawTokenInfo;

  if (env.GOOGLE_CLIENT_ID && data.aud !== env.GOOGLE_CLIENT_ID) {
    throw new Error('Google token audience inválido');
  }

  if (data.email_verified !== 'true') {
    throw new Error('Email Google não verificado');
  }

  return {
    sub: data.sub,
    email: data.email,
    name: data.name,
    picture: data.picture,
    email_verified: true,
  };
}
