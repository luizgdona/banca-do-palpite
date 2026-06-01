# TDD — Guia de Desenvolvimento

## Regra de ouro

**Nenhum código de produção sem um teste que o justifique.**

Ordem obrigatória:
1. Escrever o teste (falha)
2. Escrever o mínimo de código para passar
3. Refatorar mantendo os testes verdes

---

## Estrutura de testes

### Backend (`backend/test/`)

```
test/
  helpers/
    setup.ts          — silencia logs, setup global
    prisma-mock.ts    — factory de mock tipado do PrismaClient
    app-factory.ts    — buildTestApp() com Prisma mockado
  unit/
    auth-utils.test.ts        — tokens, validações puras
    pools-utils.test.ts       — invite code, score parsing, ranking sort
    calculate-points.test.ts  — lógica de pontuação (exato/resultado/zero)
    auth.service.test.ts      — AuthService com Prisma mockado
    pools.service.test.ts     — PoolsService com Prisma mockado
    predictions.service.test.ts — validação temporal, revelação, batch
    rankings.service.test.ts  — ordenação, isMe, exactCount
    notifications.service.test.ts — graceful no-op sem Firebase
    ws-connection-manager.test.ts — subscribe, broadcast, sockets fechados
  integration/
    auth.routes.test.ts       — POST /register, /login, GET /me via inject
    pools.routes.test.ts      — CRUD pools, join, validação de inputs
    predictions.routes.test.ts — palpites via HTTP, validação de tempo
```

**Rodar:**
```bash
cd backend
npm test                   # todos
npm test -- unit           # só unitários
npm test -- integration    # só integração
npm run test:coverage      # com cobertura
```

### Flutter (`mobile/test/`)

```
test/
  models/
    user_model_test.dart
    match_model_test.dart
    prediction_model_test.dart
    ranking_model_test.dart
  websocket/
    ws_message_test.dart    — parsing de todos os tipos de mensagem
    ws_manager_test.dart    — backoff, validação de código, lógica pura
  widgets/
    login_screen_test.dart  — validações de formulário, toggle de senha
    home_screen_test.dart   — estados vazio/com bolões, diálogos
```

**Rodar:**
```bash
cd mobile
flutter test                              # todos
flutter test test/models/                # só models
flutter test test/widgets/               # só widgets
flutter test --coverage                  # com cobertura
```

---

## Como criar um novo feature com TDD

### Backend — exemplo: novo endpoint `GET /users/:id/stats`

```typescript
// 1. Escrever o teste PRIMEIRO (test/unit/users.service.test.ts)
it('retorna estatísticas do usuário', async () => {
  prisma.poolMember.findMany.mockResolvedValue([...]);
  prisma.prediction.count.mockResolvedValue(15);

  const stats = await service.getStats('user-1');

  expect(stats.poolsJoined).toBe(3);
  expect(stats.totalPredictions).toBe(15);
});

// 2. Rodar → teste FALHA (UsersService.getStats não existe)
// npm test -- unit/users

// 3. Implementar o mínimo em users.service.ts
async getStats(userId: string) {
  const [members, predictions] = await Promise.all([
    this.prisma.poolMember.findMany({ where: { userId } }),
    this.prisma.prediction.count({ where: { userId } }),
  ]);
  return { poolsJoined: members.length, totalPredictions: predictions };
}

// 4. Rodar → teste PASSA
// 5. Refatorar se necessário
```

### Flutter — exemplo: novo widget `PredictionStatusBadge`

```dart
// 1. Escrever o teste PRIMEIRO (test/widgets/prediction_status_badge_test.dart)
testWidgets('exibe "+3 pts" em dourado para placar exato', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: PredictionStatusBadge(points: 3, scoringExact: 3)),
  );

  expect(find.text('+3 pts 🎯'), findsOneWidget);
  // verifica a cor...
});

// 2. Rodar → FALHA (widget não existe)
// flutter test test/widgets/prediction_status_badge_test.dart

// 3. Criar o widget mínimo
// 4. PASSA → refatorar
```

---

## Regras de mocking

### O que mockar
- `PrismaClient` — sempre, em todos os testes de serviço
- `Redis` — sempre nos testes de integração (mock de ioredis)
- `BullMQ` workers — sempre (não iniciar workers reais)
- `firebase-admin` — não precisa mockar, o service já faz no-op sem credenciais
- `Dio` no Flutter — usar `DioMock` ou `ProviderScope.overrides`

### O que NÃO mockar
- Lógica de negócio pura (`calcPoints`, validações de formato, parsing de JSON)
- `AppTheme`, `AppColors` — são constantes, não precisam de mock
- `GoRouter` nos widget tests — criar uma instância real simplificada

---

## Mocks reutilizáveis

```typescript
// backend/test/helpers/prisma-mock.ts
const prisma = createPrismaMock();
// Reseta entre testes:
beforeEach(() => resetPrismaMock(prisma));
```

```dart
// Flutter: sobrescrever providers no ProviderScope
ProviderScope(
  overrides: [
    authProvider.overrideWith(() => FakeAuthNotifier(user)),
    poolsProvider.overrideWith(() => FakePoolsNotifier(pools)),
  ],
  child: MaterialApp.router(...),
)
```

---

## Cobertura mínima esperada

| Camada | Meta |
|---|---|
| Lógica de negócio pura | 100% |
| Services (com mock Prisma) | ≥ 90% |
| Rotas HTTP (via inject) | ≥ 80% |
| Models Flutter | 100% |
| Providers Flutter | ≥ 80% |
| Widgets críticos | ≥ 70% |

---

## Checklist antes de abrir PR

- [ ] Novos testes escritos **antes** do código
- [ ] `npm test` passa sem erros
- [ ] `flutter test` passa sem erros
- [ ] Nenhum `console.log` / `debugPrint` deixado acidentalmente
- [ ] Nenhum dado sensível em fixtures ou snapshots de teste
- [ ] Casos de erro testados (não só o happy path)
