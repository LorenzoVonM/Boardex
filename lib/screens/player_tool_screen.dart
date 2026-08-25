import 'package:flutter/material.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';
import 'for_sell_games_screen.dart';
import 'timer_tool_screen.dart';
import 'turn_order_tool_screen.dart';

class PlayerToolScreen extends StatelessWidget {
  const PlayerToolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        title: 'Tools',
        titleColor: Color(0xFFEAB308),
        titleIcon: Icons.grid_view_rounded,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          topPadding,
          16,
          24 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.0,
          children: [
            _ToolMenuSquare(
              title: 'Turn Order',
              icon: Icons.casino_rounded,
              color: AppColors.headerCoral,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TurnOrderToolScreen(),
                  ),
                );
              },
            ),
            _ToolMenuSquare(
              title: 'Marketplace',
              icon: Icons.storefront_rounded,
              color: AppColors.sellGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForSellGamesScreen(),
                  ),
                );
              },
            ),
            _ToolMenuSquare(
              title: 'Timer',
              icon: Icons.timer_rounded,
              color: AppColors.brandTeal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TimerToolScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolMenuSquare extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolMenuSquare({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
