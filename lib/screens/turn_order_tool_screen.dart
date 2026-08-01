import 'package:flutter/material.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';
import 'single_player_selection_screen.dart';
import 'team_selection_screen.dart';

class TurnOrderToolScreen extends StatelessWidget {
  const TurnOrderToolScreen({super.key});

  void _showTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('How many teams?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.groups, color: colorScheme.primary),
                title: const Text('2 Teams'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const TeamSelectionScreen(teamCount: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: Icon(Icons.groups_3, color: colorScheme.primary),
                title: const Text('3 Teams'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const TeamSelectionScreen(teamCount: 3),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        title: 'Turn Order',
        titleColor: Color(0xFFEAB308),
        titleIcon: Icons.casino_rounded,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            32,
            topPadding,
            32,
            24 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMenuButton(
                context,
                icon: Icons.person,
                label: 'Competitive',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SinglePlayerSelectionScreen(),
                    ),
                  );
                },
                isPrimary: true,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context,
                icon: Icons.groups,
                label: 'Teams',
                onPressed: () => _showTeamDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      height: 64,
      child: isPrimary
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 28),
              label: Text(label, style: const TextStyle(fontSize: 18)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.headerCoral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 28),
              label: Text(label, style: const TextStyle(fontSize: 18)),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
    );
  }
}
