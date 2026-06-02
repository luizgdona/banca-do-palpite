import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/bdp_logo.dart';

/// Shell that wraps all authenticated screens with:
/// - Sidebar navigation on desktop (≥ 768px)  — always visible
/// - Top app bar + Bottom nav bar on mobile  (<  768px)
/// - Content is constrained to 1100px max-width on very large screens
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const double _breakpoint = 768;
  static const double _maxContentWidth = 1100;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= _breakpoint;
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── Mobile top bar (logo + actions) ─────────────────────────────────────
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.surfaceContainerLow,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const BdpLogoCompact(fontSize: 20),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.primary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined,
                      color: AppColors.primary),
                  onPressed: () => GoRouter.of(context).push('/profile'),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Desktop sidebar ──────────────────────────────────────────────────
          if (isDesktop) _Sidebar(location: location),
          // ── Main content with max-width on very large screens ────────────────
          Expanded(
            child: isDesktop
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: _maxContentWidth),
                      child: child,
                    ),
                  )
                : child,
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _BottomNav(location: location),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final String location;
  const _Sidebar({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Brand ───────────────────────────────────────────────────────────
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md,
            ),
            child: const BdpLogoCompact(fontSize: 20),
          ),
          const SizedBox(height: AppSpacing.base),
          // ── Pool label ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Text(
              'MEU BOLÃO',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // ── Nav items ───────────────────────────────────────────────────────
          _NavItem(
            icon: Icons.dashboard_outlined,
            iconFilled: Icons.dashboard,
            label: 'Dashboard',
            route: '/home',
            location: location,
          ),
          _NavItem(
            icon: Icons.leaderboard_outlined,
            iconFilled: Icons.leaderboard,
            label: 'Ranking',
            route: '/ranking',
            location: location,
          ),
          _NavItem(
            icon: Icons.group_outlined,
            iconFilled: Icons.group,
            label: 'Participantes',
            route: '/participants',
            location: location,
          ),
          _NavItem(
            icon: Icons.sports_soccer_outlined,
            iconFilled: Icons.sports_soccer,
            label: 'Palpites',
            route: '/pool',
            location: location,
          ),
          _NavItem(
            icon: Icons.query_stats_outlined,
            iconFilled: Icons.query_stats,
            label: 'Resultados',
            route: '/results',
            location: location,
          ),
          const Spacer(),
          // ── User actions ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              children: [
                const Icon(Icons.account_circle_outlined,
                    color: AppColors.onSurfaceVariant, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Meu perfil',
                    style: GoogleFonts.workSans(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppColors.onSurfaceVariant, size: 18),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          // ── CTA ─────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: _GradientButton(
              label: 'Novo Palpite',
              icon: Icons.add,
              onTap: () => GoRouter.of(context).push('/pool/create'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconFilled;
  final String label;
  final String route;
  final String location;

  const _NavItem({
    required this.icon,
    required this.iconFilled,
    required this.label,
    required this.route,
    required this.location,
  });

  bool get _active => location.startsWith(route);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: _active ? AppColors.surfaceContainerHighest : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: _active ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          _active ? iconFilled : icon,
          color: _active ? AppColors.primary : AppColors.onSurfaceVariant,
          size: 20,
        ),
        title: Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 13,
            fontWeight: _active ? FontWeight.w600 : FontWeight.w400,
            color: _active ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: 2,
        ),
        onTap: () => GoRouter.of(context).go(route),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ── Bottom Navigation (mobile) ────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final String location;
  const _BottomNav({required this.location});

  @override
  Widget build(BuildContext context) {
    final items = [
      _BNItem(Icons.dashboard_outlined, Icons.dashboard, 'DASH', '/home'),
      _BNItem(Icons.leaderboard_outlined, Icons.leaderboard, 'RANK', '/ranking'),
      _BNItem(Icons.sports_soccer_outlined, Icons.sports_soccer, 'BETS', '/pool'),
      _BNItem(Icons.account_circle_outlined, Icons.account_circle, 'MIM', '/profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: items
              .map((item) => Expanded(
                    child: _BottomNavItem(
                      item: item,
                      active: location.startsWith(item.route),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _BNItem {
  final IconData icon, iconFilled;
  final String label, route;
  const _BNItem(this.icon, this.iconFilled, this.label, this.route);
}

class _BottomNavItem extends StatelessWidget {
  final _BNItem item;
  final bool active;

  const _BottomNavItem({required this.item, required this.active});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => GoRouter.of(context).go(item.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? item.iconFilled : item.icon,
              color: active ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? AppColors.primary : AppColors.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient CTA Button ───────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.base,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusBase),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.onPrimary, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: GoogleFonts.workSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
