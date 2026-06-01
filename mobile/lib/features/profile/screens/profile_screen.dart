import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).valueOrNull;
    final user = authState?.user;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: const Text('PERFIL'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
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
                  color: AppColors.liveBadge,
                  onTap: () => _confirmLogout(context, ref),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Banca do Palpite',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 14,
                      color: AppColors.mutedDark,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
        backgroundColor: AppColors.green,
        title: Text(
          'EDITAR PERFIL',
          style: GoogleFonts.barlowCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.amber,
          ),
        ),
        content: TextField(
          controller: nameCtrl,
          style: GoogleFonts.dmSans(color: AppColors.offWhite),
          decoration: InputDecoration(
            labelText: 'Nome',
            filled: true,
            fillColor: AppColors.greenMid,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCELAR',
                style: GoogleFonts.dmSans(color: AppColors.mutedText)),
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
      // Refresh auth state
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
        backgroundColor: AppColors.green,
        title: Text(
          'SAIR',
          style: GoogleFonts.barlowCondensed(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.liveBadge,
          ),
        ),
        content: Text(
          'Tem certeza que deseja sair?',
          style: GoogleFonts.dmSans(color: AppColors.offWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCELAR',
                style: GoogleFonts.dmSans(color: AppColors.mutedText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.liveBadge),
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
      color: AppColors.green,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.amber,
            child: Text(
              user.name[0].toUpperCase(),
              style: GoogleFonts.barlowCondensed(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.offWhite,
                  ),
                ),
                Text(
                  user.email,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.mutedText,
                  ),
                ),
                if (user.provider != 'email')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.amber.withAlpha(80)),
                      ),
                      child: Text(
                        user.provider.toUpperCase(),
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 11,
                          color: AppColors.amber,
                          letterSpacing: 1,
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
    final c = color ?? AppColors.darkText;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(
        label,
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w500,
          color: c,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.mutedDark),
      onTap: onTap,
    );
  }
}
