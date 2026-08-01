import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../repositories/board_game_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Search filters
  final _searchNameController = TextEditingController();
  final _minPlayersController = TextEditingController();
  final _maxPlayersController = TextEditingController();
  final _minRatingController = TextEditingController();
  final _maxRatingController = TextEditingController();
  final _minDurationController = TextEditingController();
  final _maxDurationController = TextEditingController();
  final _minWeightController = TextEditingController();
  final _maxWeightController = TextEditingController();
  bool _filterMarkForSell = false;
  bool _filterMarkForTrade = false;
  bool _filterIsOwned = false;
  List<String> _selectedMechanics = [];
  List<String> _selectedCategories = [];

  @override
  void dispose() {
    _searchNameController.dispose();
    _minPlayersController.dispose();
    _maxPlayersController.dispose();
    _minRatingController.dispose();
    _maxRatingController.dispose();
    _minDurationController.dispose();
    _maxDurationController.dispose();
    _minWeightController.dispose();
    _maxWeightController.dispose();
    super.dispose();
  }

  Future<void> _searchGames() async {
    final games = await BoardGameRepository.instance.search(
      name: _searchNameController.text.isEmpty
          ? null
          : _searchNameController.text,
      minPlayers: int.tryParse(_minPlayersController.text),
      maxPlayers: int.tryParse(_maxPlayersController.text),
      minRating: double.tryParse(_minRatingController.text),
      maxRating: double.tryParse(_maxRatingController.text),
      minDuration: int.tryParse(_minDurationController.text),
      maxDuration: int.tryParse(_maxDurationController.text),
      minWeight: double.tryParse(_minWeightController.text),
      maxWeight: double.tryParse(_maxWeightController.text),
      markForSell: _filterMarkForSell ? true : null,
      markForTrade: _filterMarkForTrade ? true : null,
      isOwned: _filterIsOwned ? true : null,
      mechanics: _selectedMechanics.isNotEmpty ? _selectedMechanics : null,
      categories: _selectedCategories.isNotEmpty ? _selectedCategories : null,
    );
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(games: games),
        ),
      );
    }
  }

  void _clearFilters() {
    _searchNameController.clear();
    _minPlayersController.clear();
    _maxPlayersController.clear();
    _minRatingController.clear();
    _maxRatingController.clear();
    _minDurationController.clear();
    _maxDurationController.clear();
    _minWeightController.clear();
    _maxWeightController.clear();
    setState(() {
      _filterMarkForSell = false;
      _filterMarkForTrade = false;
      _filterIsOwned = false;
      _selectedMechanics = [];
      _selectedCategories = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 10;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        title: 'Search Games',
        titleColor: AppColors.headerCoral,
        titleIcon: Icons.grid_view_rounded,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          0,
          topPadding,
          0,
          24 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: _buildFilterPanel(),
      ),
    );
  }

  Widget _buildFilterPanel() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Game Name
          TextField(
            controller: _searchNameController,
            decoration: const InputDecoration(
              labelText: 'Game Name',
              prefixIcon: Icon(Icons.casino),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Number of Players
          _buildSectionCard(
            title: 'Number of Players',
            icon: Icons.people,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPlayersController,
                    decoration: const InputDecoration(
                      labelText: 'Min',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxPlayersController,
                    decoration: const InputDecoration(
                      labelText: 'Max',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Duration
          _buildSectionCard(
            title: 'Duration (minutes)',
            icon: Icons.timer,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minDurationController,
                    decoration: const InputDecoration(
                      labelText: 'Min',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxDurationController,
                    decoration: const InputDecoration(
                      labelText: 'Max',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Rating
          _buildSectionCard(
            title: 'Rating',
            icon: Icons.star_rounded,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minRatingController,
                        decoration: const InputDecoration(
                          labelText: 'Min',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _maxRatingController,
                        decoration: const InputDecoration(
                          labelText: 'Max',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1.0',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '10.0',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Weight
          _buildSectionCard(
            title: 'Weight (Difficulty)',
            icon: Icons.fitness_center,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minWeightController,
                        decoration: const InputDecoration(
                          labelText: 'Min',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _maxWeightController,
                        decoration: const InputDecoration(
                          labelText: 'Max',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1.0 Light',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.blue[400]),
                    ),
                    Text(
                      '5.0 Heavy',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.red[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Mechanics filter
          _buildSectionCard(
            title: 'Mechanics',
            icon: Icons.build,
            subtitle: 'Select to filter',
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              children: gameMechanics.map((mechanic) {
                final isSelected = _selectedMechanics.contains(mechanic);
                return FilterChip(
                  label: Text(mechanic, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMechanics.add(mechanic);
                      } else {
                        _selectedMechanics.remove(mechanic);
                      }
                    });
                  },
                  selectedColor: colorScheme.primaryContainer,
                  checkmarkColor: colorScheme.onPrimaryContainer,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Categories filter
          _buildSectionCard(
            title: 'Category',
            icon: Icons.category,
            subtitle: 'Select to filter',
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              children: gameCategories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  selectedColor: colorScheme.secondaryContainer,
                  checkmarkColor: colorScheme.onSecondaryContainer,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Ownership Status
          _buildSectionCard(
            title: 'Ownership Status',
            icon: Icons.inventory_2_rounded,
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppColors.ownedTeal,
                ),
                const SizedBox(width: 10),
                const Expanded(child: Text('I own this game')),
                Switch(
                  value: _filterIsOwned,
                  onChanged: (value) => setState(() => _filterIsOwned = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Mark for Sell / Trade
          _buildSectionCard(
            title: 'Marketplace Status',
            icon: Icons.store,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.sell, size: 18, color: Colors.green[700]),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Marked for Sell')),
                    Switch(
                      value: _filterMarkForSell,
                      onChanged: (value) =>
                          setState(() => _filterMarkForSell = value),
                    ),
                  ],
                ),
                const Divider(height: 1),
                Row(
                  children: [
                    Icon(Icons.swap_horiz, size: 18, color: Colors.blue[700]),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Marked for Trade')),
                    Switch(
                      value: _filterMarkForTrade,
                      onChanged: (value) =>
                          setState(() => _filterMarkForTrade = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _searchGames,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Games'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable section card matching the pattern used in AddGameScreen.
  Widget _buildSectionCard({
    String? title,
    IconData? icon,
    Color? iconColor,
    String? subtitle,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 18,
                      color: iconColor ?? colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
