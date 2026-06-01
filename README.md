# banca-do-palpite

**Friends' prediction pool. Live scores.**

Sports prediction pool app with match guesses, live scoring via WebSocket, and real-time rankings. Runs as a PWA and native Android/iOS app built with Flutter.

---

## Structure

```
banca-do-palpite/
  backend/    — Node.js + Fastify + TypeScript + Prisma + PostgreSQL + Redis + BullMQ
  mobile/     — Flutter (Web + Android + iOS) + Riverpod + go_router
```

---

## Quick start

### 1. Database (Docker)

```bash
cd backend
docker-compose up -d
```

Starts PostgreSQL 16 on port 5432 and Redis 7 on port 6379.

### 2. Backend

```bash
cd backend
cp .env.example .env      # fill in required variables (see below)
npm install
npx prisma migrate dev --name init
npm run dev
```

Server at `http://localhost:3000` — health check: `GET /health`

WebSocket at `ws://localhost:3000/ws?token=<jwt>`

### 3. Flutter

```bash
cd mobile
flutter pub get
flutter run -d chrome         # web
flutter run -d <device-id>    # Android / iOS
```

---

## Environment variables

Copy `backend/.env.example` to `backend/.env` and fill in:

| Variable | Required | Description |
|---|---|---|
| `JWT_SECRET` | ✅ | Long random string (`openssl rand -hex 32`) |
| `REFRESH_TOKEN_SECRET` | ✅ | Same — use a different value |
| `DATABASE_URL` | ✅ | Pre-filled for local Docker |
| `REDIS_URL` | ✅ | Pre-filled for local Docker |
| `API_FOOTBALL_KEY` | ⚠️ | Get at [api-football.com](https://api-football.com) — free tier: 100 req/day |
| `SYNC_ADMIN_KEY` | ⚠️ | Protects `/sync/*` endpoints in production |
| `FIREBASE_*` | 🔜 | Push notifications (see setup below) |
| `GOOGLE_CLIENT_*` | 🔜 | Google OAuth |
| `RESEND_API_KEY` | 🔜 | Transactional email |

> **Never commit `.env`.** It is already listed in `.gitignore`.

---

## Enabling push notifications (Firebase)

1. Create a project in [Firebase Console](https://console.firebase.google.com)
2. **Android:** download `google-services.json` → place in `mobile/android/app/`
   (template at `mobile/android/app/google-services.json.example`)
3. **iOS:** download `GoogleService-Info.plist` → place in `mobile/ios/Runner/`
   (template at `mobile/ios/Runner/GoogleService-Info.plist.example`)
4. In `backend/.env`, fill in:
   ```
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@project.iam.gserviceaccount.com
   ```
5. In `mobile/pubspec.yaml`, uncomment `firebase_core` and `firebase_messaging`
6. In `lib/core/providers/firebase_provider.dart`, replace the stubs with real code

> Without Firebase configured, the app runs normally — notifications are silently ignored.

## Enabling deep links (Android)

In `android/app/src/main/AndroidManifest.xml`, add inside `<activity>`:
```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="https" android:host="bancadopalpite.app"/>
</intent-filter>
```

---

## API — Main endpoints

```
POST /api/auth/register          Create account
POST /api/auth/login             Login
POST /api/auth/refresh           Refresh access token (via httpOnly cookie)
POST /api/auth/logout
POST /api/auth/google            Google OAuth login
POST /api/auth/fcm-token         Register FCM device token

GET  /api/competitions           List competitions (auth required)
GET  /api/competitions/:id/matches

POST /api/pools                  Create pool
GET  /api/pools                  My pools
GET  /api/pools/:id              Pool details + matches
GET  /api/pools/join/:code       Public invite preview (no auth)
POST /api/pools/join/:code/confirm  Join pool

POST /api/pools/:id/predictions         Save prediction
POST /api/pools/:id/predictions/batch   Save multiple predictions
GET  /api/pools/:id/predictions/me      My predictions
GET  /api/pools/:id/matches/:mid/predictions  Revealed predictions (after kick-off)

GET  /api/pools/:id/ranking             Overall ranking
GET  /api/pools/:id/ranking/matches     Points breakdown per match

WS   /ws?token=<jwt>            Real-time WebSocket
```

---

## Real-time architecture

```
API-Football (60s poll) → BullMQ Worker
    → prisma.match.update()
    → Redis PUBLISH match:updated:{matchId}
    → Redis Subscriber → ConnectionManager
    → WebSocket broadcast to pool subscribers
    → Flutter WsManager stream
    → LiveMatchesNotifier reactive patch
    → UI updates without setState
```

When a match finishes: `calculate-points` runs atomically, points are credited, ranking is invalidated, and a `pool:ranking_updated` broadcast is sent.

---

## Running tests

```bash
# Backend (vitest) — no database required
cd backend
npm test

# Flutter
cd mobile
flutter test
```

---

## Development phases

- [x] **Phase 1** — Foundation: Docker, Fastify, full Prisma schema, Auth (register/login/refresh/logout), Flutter theme + auth screens
- [x] **Phase 2** — Pool core: competitions + API-Football sync, CRUD pools, invite code, Flutter screens (pool stepper, details, QR invite)
- [x] **Phase 3** — Predictions & Ranking: server-side time validation, atomic idempotent calculate-points, tiebreaker ranking, inline Flutter predictions with debounce
- [x] **Phase 4** — Real-time: authenticated WebSocket, Redis pub/sub, BullMQ live-scores job, exponential backoff reconnection in Flutter
- [x] **Phase 5** — Polish: Firebase push notifications (lazy init), Google OAuth, deep links, profile screen, notification settings, PWA manifest
- [x] **TDD test coverage** — 102 backend tests (12 files: unit + integration) + 50 Flutter tests (models, websocket, widgets) = **152 tests, 0 failures**

---

## Stack

| Layer | Technology |
|---|---|
| Backend | Node.js, Fastify 4, TypeScript, Prisma 5 |
| Database | PostgreSQL 16, Redis 7 |
| Jobs | BullMQ, ioredis |
| Auth | JWT (15 min) + Refresh token httpOnly cookie (30 days) |
| Sports API | API-Football v3 (aggressive Redis caching) |
| Mobile/Web | Flutter, Riverpod 2, go_router 13, Dio |
| Real-time | WebSocket (@fastify/websocket + web_socket_channel) |
| Local infra | Docker Compose |
| Testing | Vitest (backend), flutter_test (Flutter) |
