import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../repositories/board_game_repository.dart';
import '../repositories/match_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_app_bar.dart';
import 'match_detail_screen.dart';

class MatchSearchScreen extends StatefulWidget {
  const MatchSearchScreen({super.key});

  @override
  State<MatchSearchScreen> createState() => _MatchSearchScreenState();
}

class _MatchSearchScreenState extends State<MatchSearchScreen> {
  final _gameNameController = TextEditingController();
  List<String> _gameNameSuggestions = [];

  String? _selectedGame;
  DateTime? _startDate;
  DateTime? _endDate;
  MatchResult? _selectedResult;

  List<GameMatch> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  final Map<String, String?> _libraryPhotoCache = {};

  @override
  void initState() {
    super.initState();
    _loadGameNames();
  }

  Future<void> _loadGameNames() async {
    final names = await MatchRepository.instance.getDistinctGameNames();
    setState(() => _gameNameSuggestions = names);
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
          if (_endDate != null && _endDate!.isBefore(date)) {
            _endDate = date;
          }
        } else {
          _endDate = date;
          if (_startDate != null && _startDate!.isAfter(date)) {
            _startDate = date;
          }
        }
      });
    }
  }

  Future<void> _search() async {
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await MatchRepository.instance.search(
        gameName: _selectedGame,
        fromDate: _startDate,
        toDate: _endDate != null
            ? DateTime(
                _endDate!.year,
                _endDate!.month,
                _endDate!.day,
                23,
                59,
                59,
              )
            : null,
        result: _selectedResult,
      );

      // Pre-resolve library photos
      final gameNames = results
          .where((m) => m.useLibraryPhoto)
          .map((m) => m.gameName)
          .toSet();
      for (final name in gameNames) {
        if (!_libraryPhotoCache.containsKey(name)) {
          _libraryPhotoCache[name] = await BoardGameRepository.instance
              .getPhotoPath(name);
        }
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _gameNameController.clear();
      _selectedGame = null;
      _startDate = null;
      _endDate = null;
      _selectedResult = null;
      _searchResults.clear();
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Search Matches',
        titleColor: AppColors.brandTeal,
        titleIcon: Icons.sports_esports_rounded,
        actions: [
          if (_selectedGame != null ||
              _startDate != null ||
              _endDate != null ||
              _selectedResult != null)
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all, color: Colors.white),
              tooltip: 'Clear filters',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _gameNameSuggestions;
                    }
                    return _gameNameSuggestions.where(
                      (name) => name.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
                  },
                  onSelected: (String selection) {
                    setState(() => _selectedGame = selection);
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Game Name',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.casino),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            suffixIcon: _selectedGame != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      controller.clear();
                                      setState(() => _selectedGame = null);
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() => _selectedGame = null);
                            } else {
                              setState(() => _selectedGame = value);
                            }
                          },
                        );
                      },
                ),
                const SizedBox(height: 6),

                // Date range section card
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.date_range,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Date Range',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context, true),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'From Date',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today, size: 18),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    _startDate != null
                                        ? dateFormat.format(_startDate!)
                                        : 'Any',
                                    style: TextStyle(
                                      color: _startDate != null
                                          ? null
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context, false),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'To Date',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today, size: 18),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    _endDate != null
                                        ? dateFormat.format(_endDate!)
                                        : 'Any',
                                    style: TextStyle(
                                      color: _endDate != null
                                          ? null
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Result filter section card
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Result',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _ResultChip(
                              label: 'All',
                              icon: Icons.select_all,
                              color: colorScheme.primary,
                              selected: _selectedResult == null,
                              onTap: () => setState(() => _selectedResult = null),
                            ),
                            _ResultChip(
                              label: 'Win',
                              icon: Icons.emoji_events,
                              color: MatchResult.won.color,
                              selected: _selectedResult == MatchResult.won,
                              onTap: () => setState(() => _selectedResult = MatchResult.won),
                            ),
                            _ResultChip(
                              label: 'Draw',
                              icon: Icons.handshake,
                              color: MatchResult.tie.color,
                              selected: _selectedResult == MatchResult.tie,
                              onTap: () => setState(() => _selectedResult = MatchResult.tie),
                            ),
                            _ResultChip(
                              label: 'Loss',
                              icon: Icons.sentiment_dissatisfied,
                              color: MatchResult.lost.color,
                              selected: _selectedResult == MatchResult.lost,
                              onTap: () => setState(() => _selectedResult = MatchResult.lost),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Search button
                FilledButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Matches'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Results section
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                ? const EmptyState(
                    icon: Icons.search,
                    title: 'Set filters and tap Search',
                    iconSize: 64,
                  )
                : _searchResults.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'No matches found',
                    iconSize: 64,
                  )
                : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        130 + MediaQuery.of(context).viewPadding.bottom,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final match = _searchResults[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchDetailScreen(match: match),
                ),
              );
              if (result == true) {
                _search();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Photo thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: () {
                        final resolvedPhoto = match.useLibraryPhoto
                            ? _libraryPhotoCache[match.gameName]
                            : match.photoPath;
                        return resolvedPhoto != null
                            ? Image.file(
                                File(resolvedPhoto),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder(colorScheme);
                                },
                              )
                            : _buildPlaceholder(colorScheme);
                      }(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.gameName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFormat.format(match.playedAt),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (match.winner != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 12,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                match.winner!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.amber[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Result badge
                  buildMatchResultTag(match.result),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.casino, color: colorScheme.onSurfaceVariant, size: 24),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ResultChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: selected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
