import { describe, it, expect, vi, beforeEach } from 'vitest';

// Extract the pure calculation logic for isolated testing
function calcPoints(
  predHome: number,
  predAway: number,
  realHome: number,
  realAway: number,
  scoringExact: number,
  scoringResult: number,
): { points: number; reason: string } {
  if (predHome === realHome && predAway === realAway) {
    return { points: scoringExact, reason: 'exact_score' };
  }
  const predResult = Math.sign(predHome - predAway);
  const realResult = Math.sign(realHome - realAway);
  if (predResult === realResult) {
    return { points: scoringResult, reason: 'correct_result' };
  }
  return { points: 0, reason: 'no_points' };
}

describe('calcPoints', () => {
  const exact = 3;
  const result = 1;

  it('placar exato', () => {
    expect(calcPoints(2, 1, 2, 1, exact, result)).toEqual({ points: 3, reason: 'exact_score' });
  });

  it('placar exato empate', () => {
    expect(calcPoints(0, 0, 0, 0, exact, result)).toEqual({ points: 3, reason: 'exact_score' });
  });

  it('resultado certo — vitória mesmo time, placar diferente', () => {
    expect(calcPoints(2, 1, 3, 0, exact, result)).toEqual({ points: 1, reason: 'correct_result' });
  });

  it('resultado certo — empate com placar diferente', () => {
    expect(calcPoints(1, 1, 2, 2, exact, result)).toEqual({ points: 1, reason: 'correct_result' });
  });

  it('errou — resultado oposto', () => {
    expect(calcPoints(2, 1, 0, 1, exact, result)).toEqual({ points: 0, reason: 'no_points' });
  });

  it('errou — apostou empate mas houve resultado', () => {
    expect(calcPoints(1, 1, 2, 0, exact, result)).toEqual({ points: 0, reason: 'no_points' });
  });

  it('errou — apostou vitória mas houve empate', () => {
    expect(calcPoints(2, 0, 1, 1, exact, result)).toEqual({ points: 0, reason: 'no_points' });
  });

  it('pontuação customizada', () => {
    expect(calcPoints(1, 0, 1, 0, 5, 2)).toEqual({ points: 5, reason: 'exact_score' });
    expect(calcPoints(2, 0, 3, 0, 5, 2)).toEqual({ points: 2, reason: 'correct_result' });
  });

  it('scoringResult = 0 não dá ponto por resultado', () => {
    expect(calcPoints(2, 0, 3, 0, 3, 0)).toEqual({ points: 0, reason: 'correct_result' });
  });
});
