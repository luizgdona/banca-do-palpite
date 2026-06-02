import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_loading.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState?.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        title: const Text('PERFIL'),
      ),
      body: user == null
          ? const AppLoadingIndicator()
          : ListView(
              children: [
                _ProfileHeader(user: user),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.edit_outlined,
                  label: 'Editar perfil',
                  onTap: () => _showEditDialog(context, ref, user),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.logout,
                  label: 'Sair',
                  color: AppColors.error,
                  onTap: () => _confirmLogout(context, ref),
                ),
                AppSpacing.gapXxl,
                Center(
                  child: Text(
                    'Banca do Palpite',
                    style: AppTextStyles.caption.copyWith(letterSpacing: 1),
                  ),
                ),
                AppSpacing.gapSm,
              ],
            ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) async {
    final nameCtrl = TextEditingController(text: user.name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          'EDITAR PERFIL',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 20,
            color: AppColors.secondary,
          ),
        ),
        content: TextField(
          controller: nameCtrl,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            labelText: 'Nome',
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: const OutlineInputBorder(
              borderRadius: AppSpacing.inputRadius,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppSpacing.inputRadius,
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCELAR', style: AppTextStyles.caption),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    if (result == null || result.length < 2) return;

    try {
      final client = ref.read(apiClientProvider);
      await client.dio.put('/users/me', data: {'name': result});
      await ref.read(authProvider.notifier).login(
            email: user.email,
            password: '',
          );
    } catch (_) {}
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          'SAIR',
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 20,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Tem certeza que deseja sair?',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCELAR', style: AppTextStyles.caption),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('SAIR'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go('/onboarding');
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxl, horizontal: AppSpacing.xl),
      child: Row(
        children: [
          AppAvatar(
            name: user.name,
            radius: 36,
            backgroundColor: AppColors.secondary,
            textColor: AppColors.background,
          ),
          AppSpacing.gapLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.screenTitle.copyWith(
                    fontSize: 26,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(user.email, style: AppTextStyles.bodySm),
                if (user.provider != 'email')
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xs / 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(30),
                        borderRadius: AppSpacing.badgeRadius,
                        border: Border.all(
                            color: AppColors.secondary.withAlpha(80)),
                      ),
                      child: Text(
                        user.provider.toUpperCase(),
                        style: AppTextStyles.badgeLabel.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.onSurface;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(
        label,
        style: AppTextStyles.bodyMd.copyWith(
          fontWeight: FontWeight.w500,
          color: c,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
