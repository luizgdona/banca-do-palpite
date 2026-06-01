import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_model.dart';
import '../websocket/ws_manager.dart';
import '../websocket/ws_message.dart';
import 'pools_provider.dart';
import 'predictions_provider.dart';

// Mapa reativo de matchId → MatchModel para um bolão
// Atualizado em tempo real via WebSocket
class LiveMatchesNotifier extends AsyncNotifier<Map<String, MatchModel>> {
  StreamSubscription<WsMessage>? _sub;
  String? _poolId;

  @override
  Future<Map<String, MatchModel>> build() async {
    ref.onDispose(_cleanup);
    return {};
  }

  void initForPool(String poolId, List<MatchModel> initialMatches) {
    _cleanup(); // cancel previous subscription if pool changed
    _poolId = poolId;

    // Seed com os dados iniciais do bolão
    final map = {for (final m in initialMatches) m.id: m};
    state = AsyncValue.data(map);

    // Subscribes to pool updates via WS
    final manager = ref.read(wsManagerProvider);
    manager.subscribe([poolId]);

    // Listen to WS messages and patch the local match state
    _sub?.cancel();
    _sub = manager.messages.listen((msg) {
      if (msg is WsScoreUpdate) {
        _patchMatch(msg.matchId, msg.homeScore, msg.awayScore, msg.minute, msg.status);
      } else if (msg is WsMatchFinished) {
        _patchMatch(msg.matchId, msg.homeScore, msg.awayScore, null, 'finished');
        // Invalidate ranking so it refetches
        ref.invalidate(rankingProvider(poolId));
      } else if (msg is WsPredictionRevealed) {
        // Invalidate the predictions so the UI shows other users' picks
        ref.invalidate(matchPredictionsProvider(
          (poolId: msg.poolId, matchId: msg.matchId),
        ));
      } else if (msg is WsRankingUpdated && msg.poolId == poolId) {
        ref.invalidate(rankingProvider(poolId));
      }
    });
  }

  void _patchMatch(
    String matchId,
    int homeScore,
    int awayScore,
    int? minute,
    String statusStr,
  ) {
    final current = Map<String, MatchModel>.from(state.valueOrNull ?? {});
    final existing = current[matchId];
    if (existing == null) return;

    current[matchId] = MatchModel(
      id: existing.id,
      homeTeam: existing.homeTeam,
      awayTeam: existing.awayTeam,
      scheduledAt: existing.scheduledAt,
      status: matchStatusFromString(statusStr),
      homeScore: homeScore,
      awayScore: awayScore,
      minute: minute,
      period: existing.period,
    );
    state = AsyncValue.data(current);
  }

  // Clean up subscription when the notifier is disposed
  void _cleanup() {
    _sub?.cancel();
    if (_poolId != null) {
      ref.read(wsManagerProvider).unsubscribe([_poolId!]);
    }
  }
}

final liveMatchesProvider =
    AsyncNotifierProvider<LiveMatchesNotifier, Map<String, MatchModel>>(
  LiveMatchesNotifier.new,
);
