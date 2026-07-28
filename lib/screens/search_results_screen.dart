import 'package:flutter/material.dart';
import '../models/board_game.dart';
import '../widgets/empty_state.dart';
import '../widgets/game_card.dart';
import 'game_detail_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final List<BoardGame> games;

  const SearchResultsScreen({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Results (${games.length})')),
      body: games.isEmpty
          ? const EmptyState(
              icon: Icons.search_off,
              title: 'No games found',
              subtitle: 'Try different search criteria',
            )
          : _buildGameGrid(context),
    );
  }

  Widget _buildGameGrid(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        8 + MediaQuery.of(context).viewPadding.bottom,
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
