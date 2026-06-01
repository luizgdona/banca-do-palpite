# Banca do Palpite

**Bolão de amigos. Placar em tempo real.**

App de bolão esportivo com palpites, ranking e atualizações ao vivo via WebSocket. Funciona como web app (PWA) e app Android/iOS via Flutter.

---

## Estrutura

```
banca_do_palpite/
  backend/    — Node.js + Fastify + TypeScript + Prisma + PostgreSQL + Redis + BullMQ
  mobile/     — Flutter (Web + Android + iOS) + Riverpod + go_router
```

---

## Início rápido

### 1. Banco de dados (Docker)

```bash
cd backend
docker-compose up -d
```

Sobe PostgreSQL 16 na porta 5432 e Redis 7 na porta 6379.

### 2. Backend

```bash
cd backend
cp .env.example .env      # preencha as variáveis obrigatórias (ver abaixo)
npm install
npx prisma migrate dev --name init
npm run dev
```

Servidor em `http://localhost:3000` — health check: `GET /health`

WebSocket em `ws://localhost:3000/ws?token=<jwt>`

### 3. Flutter

```bash
cd mobile
flutter pub get
flutter run -d chrome         # web
flutter run -d <device-id>    # Android / iOS
```

---

## Variáveis de ambiente

Copie `backend/.env.example` para `backend/.env` e preencha:

| Variável | Obrigatória | Descrição |
|---|---|---|
| `JWT_SECRET` | ✅ | String longa e aleatória (`openssl rand -hex 32`) |
| `REFRESH_TOKEN_SECRET` | ✅ | Idem, valor diferente do anterior |
| `DATABASE_URL` | ✅ | Já preenchida para o Docker local |
| `REDIS_URL` | ✅ | Já preenchida para o Docker local |
| `API_FOOTBALL_KEY` | ⚠️ | Obtenha em [api-football.com](https://api-football.com) — gratuito: 100 req/dia |
| `SYNC_ADMIN_KEY` | ⚠️ | Protege endpoints `/sync/*` em produção |
| `FIREBASE_*` | 🔜 | Fase 5 — push notifications |
| `GOOGLE_CLIENT_*` | 🔜 | Fase 5 — OAuth Google |
| `RESEND_API_KEY` | 🔜 | Fase 5 — emails |

> **Nunca commite o arquivo `.env`.** Ele já está no `.gitignore`.

---

## Ativar push notifications (Firebase)

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com)
2. **Android:** baixe `google-services.json` → coloque em `mobile/android/app/`
   (template em `mobile/android/app/google-services.json.example`)
3. **iOS:** baixe `GoogleService-Info.plist` → coloque em `mobile/ios/Runner/`
   (template em `mobile/ios/Runner/GoogleService-Info.plist.example`)
4. No backend, preencha no `.env`:
   ```
   FIREBASE_PROJECT_ID=seu-project-id
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@projeto.iam.gserviceaccount.com
   ```
5. No `mobile/pubspec.yaml`, descomente `firebase_core` e `firebase_messaging`
6. Em `lib/core/providers/firebase_provider.dart`, substitua os stubs pelo código real

> Sem Firebase configurado, o app funciona normalmente — notificações são ignoradas silenciosamente.

## Ativar deep links (Android)

Em `android/app/src/main/AndroidManifest.xml`, adicione dentro de `<activity>`:
```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="https" android:host="bancadopalpite.app"/>
</intent-filter>
```

---

## API — Endpoints principais

```
POST /api/auth/register          Criar conta
POST /api/auth/login             Login
POST /api/auth/refresh           Renovar access token (via cookie)
POST /api/auth/logout

GET  /api/competitions           Listar competições (auth)
GET  /api/competitions/:id/matches

POST /api/pools                  Criar bolão
GET  /api/pools                  Meus bolões
GET  /api/pools/:id              Detalhes + jogos
GET  /api/pools/join/:code       Preview público de convite (sem auth)
POST /api/pools/join/:code/confirm  Entrar no bolão

POST /api/pools/:id/predictions         Salvar palpite
POST /api/pools/:id/predictions/batch   Salvar múltiplos
GET  /api/pools/:id/predictions/me      Meus palpites
GET  /api/pools/:id/matches/:mid/predictions  Palpites revelados

GET  /api/pools/:id/ranking             Ranking geral
GET  /api/pools/:id/ranking/matches     Breakdown por jogo

WS   /ws?token=<jwt>            WebSocket tempo real
```

---

## Arquitetura de tempo real

```
API-Football (60s) → BullMQ Worker
    → prisma.match.update()
    → Redis PUBLISH match:updated:{matchId}
    → Redis Subscriber → ConnectionManager
    → WebSocket broadcast para clientes do bolão
    → Flutter WsManager stream
    → LiveMatchesNotifier patch reativo
    → UI atualiza sem setState
```

Quando o jogo termina: `calculate-points` executa, pontos são creditados, ranking é invalidado e broadcast via `pool:ranking_updated`.

---

## Fases de desenvolvimento

- [x] **Fase 1** — Base: Docker, Fastify, Prisma schema completo, Auth (register/login/refresh/logout), Flutter tema + telas de auth
- [x] **Fase 2** — Core do Bolão: competitions + sync API-Football, CRUD pools, invite code, telas Flutter (criar bolão stepper, detalhes, convite QR)
- [x] **Fase 3** — Palpites e Ranking: predictions com validação temporal server-side, calculate-points atômico e idempotente, ranking com tiebreaker, telas Flutter inline com debounce
- [x] **Fase 4** — Tempo Real: WebSocket autenticado, Redis pub/sub, BullMQ live-scores job, reconexão exponential backoff no Flutter
- [x] **Fase 5** — Polimento: push notifications Firebase (lazy init), OAuth Google, deep links, perfil, configurações de notificação, PWA manifest, 28 testes unitários

---

## Stack

| Camada | Tecnologia |
|---|---|
| Backend | Node.js, Fastify 4, TypeScript, Prisma 5 |
| Banco | PostgreSQL 16, Redis 7 |
| Jobs | BullMQ, ioredis |
| Auth | JWT (15min) + Refresh token httpOnly cookie (30d) |
| API esportiva | API-Football v3 (cache Redis agressivo) |
| Mobile/Web | Flutter, Riverpod 2, go_router 13, Dio |
| Tempo real | WebSocket (@fastify/websocket + web_socket_channel) |
| Infra local | Docker Compose |
