import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';

const _prefKeyFcmSent = 'fcm_token_sent';

// Armazena preferências de notificação localmente
class NotificationPrefs {
  final bool matchStartingSoon;
  final bool matchStarted;
  final bool matchFinished;
  final bool memberJoined;
  final bool exactScore;

  const NotificationPrefs({
    this.matchStartingSoon = true,
    this.matchStarted = true,
    this.matchFinished = true,
    this.memberJoined = true,
    this.exactScore = true,
  });

  NotificationPrefs copyWith({
    bool? matchStartingSoon,
    bool? matchStarted,
    bool? matchFinished,
    bool? memberJoined,
    bool? exactScore,
  }) =>
      NotificationPrefs(
        matchStartingSoon: matchStartingSoon ?? this.matchStartingSoon,
        matchStarted: matchStarted ?? this.matchStarted,
        matchFinished: matchFinished ?? this.matchFinished,
        memberJoined: memberJoined ?? this.memberJoined,
        exactScore: exactScore ?? this.exactScore,
      );
}

class NotificationPrefsNotifier extends AsyncNotifier<NotificationPrefs> {
  @override
  Future<NotificationPrefs> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPrefs(
      matchStartingSoon: prefs.getBool('notif_starting_soon') ?? true,
      matchStarted: prefs.getBool('notif_started') ?? true,
      matchFinished: prefs.getBool('notif_finished') ?? true,
      memberJoined: prefs.getBool('notif_member_joined') ?? true,
      exactScore: prefs.getBool('notif_exact_score') ?? true,
    );
  }

  Future<void> toggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    final current = state.valueOrNull ?? const NotificationPrefs();
    state = AsyncValue.data(switch (key) {
      'notif_starting_soon' => current.copyWith(matchStartingSoon: value),
      'notif_started' => current.copyWith(matchStarted: value),
      'notif_finished' => current.copyWith(matchFinished: value),
      'notif_member_joined' => current.copyWith(memberJoined: value),
      'notif_exact_score' => current.copyWith(exactScore: value),
      _ => current,
    });
  }
}

final notificationPrefsProvider =
    AsyncNotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
  NotificationPrefsNotifier.new,
);

// Registra o FCM token no backend uma vez por sessão
Future<void> registerFcmToken(WidgetRef ref, String token) async {
  final prefs = await SharedPreferences.getInstance();
  final lastSent = prefs.getString(_prefKeyFcmSent);
  if (lastSent == token) return; // já enviado este token

  try {
    final client = ref.read(apiClientProvider);
    await client.dio.post('/auth/fcm-token', data: {'token': token});
    await prefs.setString(_prefKeyFcmSent, token);
  } catch (_) {
    // Silently fail — will retry on next launch
  }
}
