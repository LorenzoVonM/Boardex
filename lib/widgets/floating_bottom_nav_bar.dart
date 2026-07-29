import 'package:flutter/material.dart';
import '../utils/theme_utils.dart';

class FloatingNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color activeColor;

  const FloatingNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.activeColor,
  });
}

class FloatingBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const FloatingBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static const List<FloatingNavItem> navItems = [
    FloatingNavItem(
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
      label: 'Library',
      activeColor: AppColors.headerCoral,
    ),
    FloatingNavItem(
      icon: Icons.sports_esports_outlined,
      selectedIcon: Icons.sports_esports,
      label: 'Matches',
      activeColor: AppColors.brandTeal,
    ),
    FloatingNavItem(
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Summary',
      activeColor: Color(0xFF7C3AED),
    ),
    FloatingNavItem(
      icon: Icons.casino_outlined,
      selectedIcon: Icons.casino,
      label: 'Tools',
      activeColor: Color(0xFFEAB308),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.headerCoral.withValues(alpha: 0.12),
            blurRadius: 30,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final isSelected = selectedIndex == index;
              final item = navItems[index];
              final activeColor = item.activeColor;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabSelected(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            color: isSelected
                                ? activeColor
                                : colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? activeColor
                                : colorScheme.onSurfaceVariant,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
