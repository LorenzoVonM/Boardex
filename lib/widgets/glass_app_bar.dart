import 'dart:ui';
import 'package:flutter/material.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color titleColor;
  final IconData? titleIcon;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double elevation;

  const GlassAppBar({
    super.key,
    required this.title,
    required this.titleColor,
    this.titleIcon,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tintedSurface = Color.alphaBlend(
      titleColor.withValues(alpha: 0.14),
      colorScheme.surface,
    ).withValues(alpha: 0.78);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
        child: Container(
          decoration: BoxDecoration(
            color: tintedSurface,
            border: Border(
              bottom: BorderSide(
                color: titleColor.withValues(alpha: 0.24),
                width: 1.0,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: automaticallyImplyLeading,
            leading: leading,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (titleIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: titleColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(titleIcon, color: titleColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            actions: actions,
          ),
        ),
      ),
    );
  }
}
