import { describe, it, expect } from 'vitest';

// Invite code format validation
function isValidInviteCode(code: string): boolean {
  return /^[A-Z0-9]{8}$/.test(code);
}

// Score parsing validation
function parseScore(value: string): number | null {
  const n = parseInt(value, 10);
  if (isNaN(n) || n < 0 || n > 99) return null;
  return n;
}

describe('invite code', () => {
  it('código válido — 8 chars maiúsculos/dígitos', () => {
    expect(isValidInviteCode('ABC12345')).toBe(true);
    expect(isValidInviteCode('AAAAAAAA')).toBe(true);
    expect(isValidInviteCode('00000000')).toBe(true);
  });

  it('código inválido — curto', () => {
    expect(isValidInviteCode('ABC123')).toBe(false);
  });

  it('código inválido — minúsculas', () => {
    expect(isValidInviteCode('abc12345')).toBe(false);
  });

  it('código inválido — caracteres especiais', () => {
    expect(isValidInviteCode('ABC-1234')).toBe(false);
  });
});

describe('score input validation', () => {
  it('placar válido', () => {
    expect(parseScore('0')).toBe(0);
    expect(parseScore('3')).toBe(3);
    expect(parseScore('99')).toBe(99);
  });

  it('placar inválido — negativo', () => {
    expect(parseScore('-1')).toBeNull();
  });

  it('placar inválido — acima de 99', () => {
    expect(parseScore('100')).toBeNull();
  });

  it('placar inválido — não numérico', () => {
    expect(parseScore('abc')).toBeNull();
  });
});

describe('ranking order', () => {
  interface Member { name: string; totalPoints: number; exactCount: number; joinedAt: Date }

  function sortRanking(members: Member[]): Member[] {
    return [...members].sort((a, b) => {
      if (b.totalPoints !== a.totalPoints) return b.totalPoints - a.totalPoints;
      if (b.exactCount !== a.exactCount) return b.exactCount - a.exactCount;
      return a.joinedAt.getTime() - b.joinedAt.getTime();
    });
  }

  it('ordena por pontos', () => {
    const members: Member[] = [
      { name: 'C', totalPoints: 5, exactCount: 0, joinedAt: new Date('2024-01-03') },
      { name: 'A', totalPoints: 15, exactCount: 1, joinedAt: new Date('2024-01-01') },
      { name: 'B', totalPoints: 10, exactCount: 2, joinedAt: new Date('2024-01-02') },
    ];
    const sorted = sortRanking(members);
    expect(sorted.map(m => m.name)).toEqual(['A', 'B', 'C']);
  });

  it('desempate por placar exato', () => {
    const members: Member[] = [
      { name: 'B', totalPoints: 10, exactCount: 1, joinedAt: new Date('2024-01-01') },
      { name: 'A', totalPoints: 10, exactCount: 3, joinedAt: new Date('2024-01-02') },
    ];
    const sorted = sortRanking(members);
    expect(sorted[0].name).toBe('A');
  });

  it('desempate por data de entrada (quem entrou primeiro fica na frente)', () => {
    const members: Member[] = [
      { name: 'B', totalPoints: 10, exactCount: 2, joinedAt: new Date('2024-01-02') },
      { name: 'A', totalPoints: 10, exactCount: 2, joinedAt: new Date('2024-01-01') },
    ];
    const sorted = sortRanking(members);
    expect(sorted[0].name).toBe('A');
  });
});
