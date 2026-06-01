import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/notifications_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_loading.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: const Text('NOTIFICAÇÕES'),
      ),
      body: prefsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (prefs) => ListView(
          children: [
            _SectionHeader('JOGOS'),
            _NotifTile(
              icon: '⏰',
              label: 'Jogo começa em 1 hora',
              subtitle: 'Aviso quando você não apostou ainda',
              value: prefs.matchStartingSoon,
              prefKey: 'notif_starting_soon',
              ref: ref,
            ),
            _NotifTile(
              icon: '🟢',
              label: 'Jogo iniciou',
              subtitle: 'Palpites revelados para todos',
              value: prefs.matchStarted,
              prefKey: 'notif_started',
              ref: ref,
            ),
            _NotifTile(
              icon: '🏁',
              label: 'Fim de jogo',
              subtitle: 'Pontuação calculada e ranking atualizado',
              value: prefs.matchFinished,
              prefKey: 'notif_finished',
              ref: ref,
            ),
            _SectionHeader('BOLÃO'),
            _NotifTile(
              icon: '🎯',
              label: 'Placar exato',
              subtitle: 'Quando você acerta o placar certinho',
              value: prefs.exactScore,
              prefKey: 'notif_exact_score',
              ref: ref,
            ),
            _NotifTile(
              icon: '🙋',
              label: 'Novo participante',
              subtitle: 'Quando alguém entra no seu bolão',
              value: prefs.memberJoined,
              prefKey: 'notif_member_joined',
              ref: ref,
            ),
            AppSpacing.gapXl,
            Padding(
              padding: AppSpacing.pagePadding,
              child: Text(
                'As preferências são salvas localmente. '
                'O servidor ainda enviará a notificação; '
                'ela será filtrada no dispositivo.',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xs + 2),
      child: Text(
        title,
        style: AppTextStyles.micro.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: AppColors.mutedDark,
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final bool value;
  final String prefKey;
  final WidgetRef ref;

  const _NotifTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.prefKey,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      value: value,
      activeColor: AppColors.amber,
      activeTrackColor: AppColors.amber.withAlpha(80),
      onChanged: (v) =>
          ref.read(notificationPrefsProvider.notifier).toggle(prefKey, v),
    );
  }
}
