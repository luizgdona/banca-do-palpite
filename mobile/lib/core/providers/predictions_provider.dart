import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prediction_model.dart';
import 'auth_provider.dart';

// Map de matchId → PredictionModel para o bolão atual
class PredictionsNotifier extends AsyncNotifier<Map<String, PredictionModel>> {
  String? _poolId;

  @override
  Future<Map<String, PredictionModel>> build() async => {};

  Future<void> loadForPool(String poolId) async {
    _poolId = poolId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(apiClientProvider);
      final response = await client.dio.get('/pools/$poolId/predictions/me');
      final list = (response.data as List<dynamic>)
          .map((e) => PredictionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return {for (final p in list) p.matchId: p};
    });
  }

  Future<void> save(String matchId, int homeScore, int awayScore) async {
    final poolId = _poolId;
    if (poolId == null) return;

    final client = ref.read(apiClientProvider);
    final response = await client.dio.post('/pools/$poolId/predictions', data: {
      'matchId': matchId,
      'homeScore': homeScore,
      'awayScore': awayScore,
    });

    final saved = PredictionModel.fromJson(response.data as Map<String, dynamic>);
    final current = Map<String, PredictionModel>.from(state.valueOrNull ?? {});
    current[matchId] = saved;
    state = AsyncValue.data(current);
  }
}

final predictionsProvider =
    AsyncNotifierProvider<PredictionsNotifier, Map<String, PredictionModel>>(
  PredictionsNotifier.new,
);

// Palpites de todos num jogo específico
final matchPredictionsProvider =
    FutureProvider.family<MatchPredictionsResponse, ({String poolId, String matchId})>(
  (ref, args) async {
    final client = ref.read(apiClientProvider);
    final response = await client.dio
        .get('/pools/${args.poolId}/matches/${args.matchId}/predictions');
    return MatchPredictionsResponse.fromJson(response.data as Map<String, dynamic>);
  },
);

// Ranking do bolão
final rankingProvider = FutureProvider.family<List<dynamic>, String>((ref, poolId) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get('/pools/$poolId/ranking');
  return response.data as List<dynamic>;
});
