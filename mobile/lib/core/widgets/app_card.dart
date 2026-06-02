import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Standard dark surface card with optional left accent border.
/// Matches the Stitch design: `bg-surface-container-high` + left green bar.
class AppCard extends StatelessWidget {
  final Widget child;

  /// Left accent color. `null` = no accent bar.
  final Color? accentColor;

  /// Full border color (e.g. live-match red). Mutually exclusive with accentColor.
  final Color? borderColor;
  final double borderWidth;

  final double bottomMargin;
  final bool hoverable;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.accentColor,
    this.borderColor,
    this.borderWidth = 1,
    this.bottomMargin = AppSpacing.sm + 2,
    this.hoverable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppSpacing.tileRadius,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Left accent bar (Stitch pattern)
          if (accentColor != null)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 3, color: accentColor),
            ),
          // Content
          onTap != null
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: AppColors.primary.withAlpha(20),
                    highlightColor: AppColors.primary.withAlpha(10),
                    child: child,
                  ),
                )
              : child,
        ],
      ),
    );
  }
}
