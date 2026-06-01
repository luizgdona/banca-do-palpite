import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pool_model.dart';
import 'auth_provider.dart';

// Lista de bolões do usuário
class PoolsNotifier extends AsyncNotifier<List<PoolModel>> {
  @override
  Future<List<PoolModel>> build() => _fetch();

  Future<List<PoolModel>> _fetch() async {
    final client = ref.read(apiClientProvider);
    final response = await client.dio.get('/pools');
    return (response.data as List<dynamic>)
        .map((e) => PoolModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<PoolModel> create({
    required String name,
    String? description,
    required String competitionId,
    required List<String> matchIds,
    int scoringExact = 3,
    int scoringResult = 1,
    bool isPublic = false,
  }) async {
    final client = ref.read(apiClientProvider);
    final response = await client.dio.post('/pools', data: {
      'name': name,
      'description': description,
      'competitionId': competitionId,
      'matchIds': matchIds,
      'scoringExact': scoringExact,
      'scoringResult': scoringResult,
      'isPublic': isPublic,
    });
    final pool = PoolModel.fromJson(response.data as Map<String, dynamic>);
    state = AsyncValue.data([pool, ...state.valueOrNull ?? []]);
    return pool;
  }
}

final poolsProvider = AsyncNotifierProvider<PoolsNotifier, List<PoolModel>>(PoolsNotifier.new);

// Detalhes de um bolão específico
final poolDetailProvider = FutureProvider.family<PoolModel, String>((ref, poolId) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get('/pools/$poolId');
  return PoolModel.fromJson(response.data as Map<String, dynamic>);
});

// Preview público de convite
final poolPreviewProvider = FutureProvider.family<PoolPreview, String>((ref, inviteCode) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get('/pools/join/$inviteCode');
  return PoolPreview.fromJson(response.data as Map<String, dynamic>);
});
