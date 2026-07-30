import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../repositories/match_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';
import 'summary_results_screen.dart';

class SummarySearchScreen extends StatefulWidget {
  const SummarySearchScreen({super.key});

  @override
  State<SummarySearchScreen> createState() => _SummarySearchScreenState();
}

class _SummarySearchScreenState extends State<SummarySearchScreen> {
  late DateTime _fromDate;
  late DateTime _toDate;
  MatchResult? _resultFilter;
  final List<String> _selectedPlayers = [];
  List<String> _allPlayers = [];
  bool _isLoadingPlayers = true;

  final _dateFormat = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = now;
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await MatchRepository.instance.getDistinctPlayers();
    if (mounted) {
      setState(() {
        _allPlayers = players;
        _isLoadingPlayers = false;
      });
    }
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final initial = isFrom ? _fromDate : _toDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_fromDate.isAfter(_toDate)) {
            _toDate = _fromDate;
          }
        } else {
          _toDate = picked;
          if (_toDate.isBefore(_fromDate)) {
            _fromDate = _toDate;
          }
        }
      });
    }
  }

  void _search() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryResultsScreen(
          fromDate: _fromDate,
          toDate: _toDate,
          resultFilter: _resultFilter,
          players: _selectedPlayers.isNotEmpty ? _selectedPlayers : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 10;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        title: 'Summary',
        titleColor: Color(0xFF7C3AED),
        titleIcon: Icons.insights_rounded,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          12,
          topPadding,
          12,
          140 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Find Matches',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Filter and group your matches by game',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),

            // Date Range Section Card
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
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _DatePickerField(
                            label: 'From',
                            date: _fromDate,
                            dateFormat: _dateFormat,
                            onTap: () => _pickDate(context, true),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Expanded(
                          child: _DatePickerField(
                            label: 'To',
                            date: _toDate,
                            dateFormat: _dateFormat,
                            onTap: () => _pickDate(context, false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Result Filter Section Card
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
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
                          selected: _resultFilter == null,
                          onTap: () => setState(() => _resultFilter = null),
                        ),
                        _ResultChip(
                          label: 'Win',
                          icon: Icons.emoji_events,
                          color: MatchResult.won.color,
                          selected: _resultFilter == MatchResult.won,
                          onTap: () => setState(() => _resultFilter = MatchResult.won),
                        ),
                        _ResultChip(
                          label: 'Draw',
                          icon: Icons.handshake,
                          color: MatchResult.tie.color,
                          selected: _resultFilter == MatchResult.tie,
                          onTap: () => setState(() => _resultFilter = MatchResult.tie),
                        ),
                        _ResultChip(
                          label: 'Loss',
                          icon: Icons.sentiment_dissatisfied,
                          color: MatchResult.lost.color,
                          selected: _resultFilter == MatchResult.lost,
                          onTap: () => setState(() => _resultFilter = MatchResult.lost),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Players Section Card
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
                          Icons.people,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Players',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Leave empty to include all players',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _isLoadingPlayers
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _allPlayers.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'No players found in matches',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildPlayerAutocomplete(),

                    // Selected players chips
                    if (_selectedPlayers.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _selectedPlayers.map((player) {
                          return InputChip(
                            label: Text(player, style: const TextStyle(fontSize: 12)),
                            avatar: CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                player[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            onDeleted: () {
                              setState(() => _selectedPlayers.remove(player));
                            },
                            deleteIconColor: colorScheme.onSurfaceVariant,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Search button
            FilledButton.icon(
              onPressed: _search,
              icon: const Icon(Icons.bar_chart),
              label: const Text('View Summary'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerAutocomplete() {
    // Filter out already selected players
    final availablePlayers = _allPlayers
        .where((p) => !_selectedPlayers.contains(p))
        .toList();

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return availablePlayers;
        }
        return availablePlayers.where(
          (p) => p.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      onSelected: (String selection) {
        setState(() {
          if (!_selectedPlayers.contains(selection)) {
            _selectedPlayers.add(selection);
          }
        });
        // Clear the text field after selection
        // We rebuild the autocomplete by using a key trick via setState
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Type to search players...',
            prefixIcon: const Icon(Icons.person_search),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onSubmitted: (value) {
            // If exact match add it
            if (availablePlayers.any(
              (p) => p.toLowerCase() == value.toLowerCase(),
            )) {
              final match = availablePlayers.firstWhere(
                (p) => p.toLowerCase() == value.toLowerCase(),
              );
              setState(() {
                if (!_selectedPlayers.contains(match)) {
                  _selectedPlayers.add(match);
                }
              });
              controller.clear();
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final colorScheme = Theme.of(context).colorScheme;
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 200,
                maxWidth: MediaQuery.of(context).size.width - 32,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        option[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 18),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          dateFormat.format(date),
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
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
