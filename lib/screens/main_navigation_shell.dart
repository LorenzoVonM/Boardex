import 'package:flutter/material.dart';
import '../widgets/floating_bottom_nav_bar.dart';
import 'library_screen.dart';
import 'matches_screen.dart';
import 'player_tool_screen.dart';
import 'summary_search_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          LibraryScreen(),
          MatchesScreen(),
          SummarySearchScreen(),
          PlayerToolScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: FloatingBottomNavBar(
          selectedIndex: _currentIndex,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}
