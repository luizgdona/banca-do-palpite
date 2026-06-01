import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/competition_model.dart';
import '../models/match_model.dart';
import 'auth_provider.dart';

final competitionsProvider = FutureProvider.family<List<CompetitionModel>, String?>(
  (ref, search) async {
    final client = ref.read(apiClientProvider);
    final response = await client.dio.get(
      '/competitions',
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );
    return (response.data as List<dynamic>)
        .map((e) => CompetitionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  },
);

final competitionMatchesProvider =
    FutureProvider.family<List<MatchModel>, String>((ref, competitionId) async {
  final client = ref.read(apiClientProvider);
  final response = await client.dio.get('/competitions/$competitionId/matches');
  return (response.data as List<dynamic>)
      .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
      .toList();
});
