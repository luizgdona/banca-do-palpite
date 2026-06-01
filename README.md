# Banca do Palpite

Bolão de amigos. Placar em tempo real.

## Estrutura

```
banca_do_palpite/
  backend/    — Node.js + Fastify + Prisma + PostgreSQL + Redis
  mobile/     — Flutter (Web + Android + iOS)
```

## Início rápido

### 1. Banco de dados (Docker)

```bash
cd backend
docker-compose up -d
```

### 2. Backend

```bash
cd backend
cp .env.example .env   # já copiado
npm install
npx prisma migrate dev --name init
npm run dev
```

Servidor sobe em `http://localhost:3000`. Health check: `GET /health`

### 3. Flutter

```bash
cd mobile
flutter pub get
flutter run
```

Para web: `flutter run -d chrome`
Para Android: `flutter run -d <device-id>`

## Variáveis de ambiente obrigatórias

Edite `backend/.env`:

- `JWT_SECRET` — troque por uma string longa e aleatória
- `REFRESH_TOKEN_SECRET` — idem
- `API_FOOTBALL_KEY` — obtenha em api-football.com (gratuito: 100 req/dia)

## Fases de desenvolvimento

- [x] **Fase 1** — Base: Docker, Fastify, Prisma, Auth, Flutter theme + telas de auth
- [ ] **Fase 2** — Core do Bolão: competitions, pools, convites
- [ ] **Fase 3** — Palpites e Ranking
- [ ] **Fase 4** — Tempo Real (WebSocket)
- [ ] **Fase 5** — Polimento (Push, QR code, PWA)
