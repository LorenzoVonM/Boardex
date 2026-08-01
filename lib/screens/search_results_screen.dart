import 'package:flutter/material.dart';
import '../models/board_game.dart';
import '../utils/theme_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/game_card.dart';
import '../widgets/glass_app_bar.dart';
import 'game_detail_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final List<BoardGame> games;

  const SearchResultsScreen({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 8;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: 'Results (${games.length})',
        titleColor: AppColors.headerCoral,
        titleIcon: Icons.grid_view_rounded,
      ),
      body: games.isEmpty
          ? Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  topPadding,
                  16,
                  130 + MediaQuery.of(context).viewPadding.bottom,
                ),
                child: const EmptyState(
                  icon: Icons.search_off,
                  title: 'No games found',
                  subtitle: 'Try different search criteria',
                ),
              ),
            )
          : _buildGameGrid(context, topPadding),
    );
  }

  Widget _buildGameGrid(BuildContext context, double topPadding) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        8,
        topPadding,
        8,
        130 + MediaQuery.of(context).viewPadding.bottom,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return GameCard(
          game: game,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameDetailScreen(game: game),
              ),
            );
          },
        );
      },
    );
  }
}
