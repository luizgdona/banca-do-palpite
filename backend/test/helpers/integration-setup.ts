// Helper para testes de integração.
// Cada test file deve criar seu próprio mock com vi.hoisted() e chamar
// makePrismaMockFactory() para obter a função de reset.
import { vi } from 'vitest';

export function makeRedisMock() {
  return {
    get: vi.fn().mockResolvedValue(null),
    set: vi.fn(), setex: vi.fn(), del: vi.fn(),
    keys: vi.fn().mockResolvedValue([]),
    publish: vi.fn(), quit: vi.fn(), on: vi.fn(), psubscribe: vi.fn(),
  };
}

export function createPrismaMockInline() {
  const fn = () => vi.fn();
  const p = {
    user:         { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), upsert: fn(), delete: fn(), count: fn() },
    refreshToken: { findUnique: fn(), create: fn(), delete: fn(), deleteMany: fn() },
    competition:  { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), upsert: fn(), count: fn() },
    match:        { findUnique: fn(), findFirst: fn(), findMany: fn(), create: fn(), update: fn(), updateMany: fn(), upsert: fn(), count: fn() },
    pool:         { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), delete: fn(), count: fn() },
    poolMatch:    { findFirst: fn(), findMany: fn(), createMany: fn(), delete: fn() },
    poolMember:   { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), updateMany: fn(), delete: fn(), count: fn() },
    prediction:   { findUnique: fn(), findMany: fn(), create: fn(), update: fn(), updateMany: fn(), upsert: fn(), count: fn(), groupBy: fn() },
    pointEvent:   { findFirst: fn(), findMany: fn(), create: fn(), createMany: fn(), deleteMany: fn() },
    $disconnect: fn(),
    $transaction: fn(),
  };
  (p.$transaction as ReturnType<typeof vi.fn>).mockImplementation(
    (cb: (tx: unknown) => Promise<unknown>) => cb(p),
  );
  return p;
}

export type InlinePrismaMock = ReturnType<typeof createPrismaMockInline>;

export function resetInlineMock(p: InlinePrismaMock) {
  for (const model of Object.values(p)) {
    if (typeof model === 'object' && model !== null) {
      for (const fn of Object.values(model as Record<string, unknown>)) {
        if (fn && typeof (fn as ReturnType<typeof vi.fn>).mockReset === 'function') {
          (fn as ReturnType<typeof vi.fn>).mockReset();
        }
      }
    }
  }
  (p.$transaction as ReturnType<typeof vi.fn>).mockImplementation(
    (cb: (tx: unknown) => Promise<unknown>) => cb(p),
  );
}
