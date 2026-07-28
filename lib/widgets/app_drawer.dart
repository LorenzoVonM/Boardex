import 'package:flutter/material.dart';
import '../screens/library_screen.dart';
import '../screens/matches_screen.dart';
import '../screens/player_tool_screen.dart';
import '../screens/summary_search_screen.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  int _selectedIndex() {
    switch (currentRoute) {
      case 'library':
        return 0;
      case 'matches':
        return 1;
      case 'summary':
        return 2;
      case 'player_tool':
        return 3;
      default:
        return 0;
    }
  }

  void _onDestinationSelected(BuildContext context, int index) {
    Navigator.pop(context); // Close drawer
    final routes = ['library', 'matches', 'summary', 'player_tool'];
    if (routes[index] == currentRoute) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const LibraryScreen();
        break;
      case 1:
        destination = const MatchesScreen();
        break;
      case 2:
        destination = const SummarySearchScreen();
        break;
      case 3:
        destination = const PlayerToolScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationDrawer(
      selectedIndex: _selectedIndex(),
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Row(
            children: [
              Icon(Icons.casino, size: 32, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Board Game Tracker',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const Divider(indent: 28, endIndent: 28),
        const NavigationDrawerDestination(
          icon: Icon(Icons.library_books_outlined),
          selectedIcon: Icon(Icons.library_books),
          label: Text('Library'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: Text('Matches'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text('Summary'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Divider(),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Player Selection Tool'),
        ),
      ],
    );
  }
}
