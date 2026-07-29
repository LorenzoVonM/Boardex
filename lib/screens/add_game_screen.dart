import 'package:flutter/material.dart';
import '../models/board_game.dart';
import '../constants/game_constants.dart';
import '../repositories/board_game_repository.dart';
import '../repositories/match_repository.dart';
import '../utils/theme_utils.dart';
import '../widgets/photo_capture_section.dart';

class AddGameScreen extends StatefulWidget {
  final BoardGame? gameToEdit;

  const AddGameScreen({super.key, this.gameToEdit});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();

  int _minPlayers = 2;
  int _maxPlayers = 4;
  double _rating = 5.0;
  double _weight = 2.5;
  bool _markForSell = false;
  bool _markForTrade = false;
  String? _photoPath;
  List<String> _gameNameSuggestions = [];
  List<String> _selectedMechanics = [];
  List<String> _selectedCategories = [];

  bool get isEditing => widget.gameToEdit != null;

  @override
  void initState() {
    super.initState();
    _loadGameNameSuggestions();
    if (widget.gameToEdit != null) {
      _nameController.text = widget.gameToEdit!.name;
      _durationController.text = widget.gameToEdit!.duration.toString();
      _minPlayers = widget.gameToEdit!.minPlayers;
      _maxPlayers = widget.gameToEdit!.maxPlayers;
      _rating = (widget.gameToEdit!.rating).clamp(1.0, 10.0);
      _rating = ((_rating * 10).round() / 10);
      _weight = (widget.gameToEdit!.weight).clamp(1.0, 5.0);
      _weight = ((_weight * 10).round() / 10);
      _markForSell = widget.gameToEdit!.markForSell;
      _markForTrade = widget.gameToEdit!.markForTrade;
      _photoPath = widget.gameToEdit!.photoPath;
      _selectedMechanics = List.from(widget.gameToEdit!.mechanics);
      _selectedCategories = List.from(widget.gameToEdit!.categories);
    }
  }

  Future<void> _loadGameNameSuggestions() async {
    final names = await MatchRepository.instance
        .getGameNamesWithMatchesNotInLibrary();
    setState(() => _gameNameSuggestions = names);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveGame() async {
    if (_formKey.currentState!.validate()) {
      final game = BoardGame(
        id: widget.gameToEdit?.id,
        name: _nameController.text.trim(),
        minPlayers: _minPlayers,
        maxPlayers: _maxPlayers,
        rating: _rating,
        duration: int.parse(_durationController.text),
        weight: _weight,
        markForSell: _markForSell,
        markForTrade: _markForTrade,
        photoPath: _photoPath,
        mechanics: _selectedMechanics,
        categories: _selectedCategories,
      );

      try {
        if (isEditing) {
          await BoardGameRepository.instance.update(game);
        } else {
          final exists = await BoardGameRepository.instance.exists(game.name);
          if (exists) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'A game with this name already exists in your library',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
          await BoardGameRepository.instance.insert(game);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Game updated!' : 'Game added!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving game: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Board Game' : 'Add Board Game'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          14,
          12,
          14,
          120 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Game Name
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _gameNameSuggestions.where(
                    (name) => name.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
                  );
                },
                onSelected: (String selection) {
                  _nameController.text = selection;
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      if (isEditing && controller.text.isEmpty) {
                        controller.text = _nameController.text;
                      }
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Game Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.games),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a game name';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _nameController.text = value;
                        },
                      );
                    },
              ),
              const SizedBox(height: 10),

              // Duration
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 1) {
                    return 'Please enter a valid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Number of Players
              _buildSectionCard(
                title: 'Number of Players',
                icon: Icons.people,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPlayerCounter(
                        label: 'Min',
                        icon: Icons.person,
                        value: _minPlayers,
                        onDecrement: _minPlayers > 1
                            ? () => setState(() {
                                _minPlayers--;
                                if (_maxPlayers < _minPlayers) {
                                  _maxPlayers = _minPlayers;
                                }
                              })
                            : null,
                        onIncrement: _minPlayers < 20
                            ? () => setState(() {
                                _minPlayers++;
                                if (_maxPlayers < _minPlayers) {
                                  _maxPlayers = _minPlayers;
                                }
                              })
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPlayerCounter(
                        label: 'Max',
                        icon: Icons.people,
                        value: _maxPlayers,
                        onDecrement: _maxPlayers > _minPlayers
                            ? () => setState(() => _maxPlayers--)
                            : null,
                        onIncrement: _maxPlayers < 50
                            ? () => setState(() => _maxPlayers++)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Rating Slider
              _buildSectionCard(
                title: 'Rating',
                icon: Icons.star_rounded,
                trailing: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: getRatingColor(_rating),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: getRatingColor(_rating),
                      ),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Slider(
                      value: _rating,
                      min: 1.0,
                      max: 10.0,
                      divisions: 90,
                      label: _rating.toStringAsFixed(1),
                      activeColor: getRatingColor(_rating),
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1.0', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text('10.0', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Weight Slider
              _buildSectionCard(
                title: 'Weight (Difficulty)',
                icon: Icons.fitness_center,
                trailing: Row(
                  children: [
                    Icon(Icons.fitness_center, size: 18, color: getWeightColor(_weight)),
                    const SizedBox(width: 4),
                    Text(
                      _weight.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: getWeightColor(_weight),
                      ),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Slider(
                      value: _weight,
                      min: 1.0,
                      max: 5.0,
                      divisions: 40,
                      label: _weight.toStringAsFixed(1),
                      activeColor: getWeightColor(_weight),
                      onChanged: (value) => setState(() => _weight = value),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1.0', style: TextStyle(color: Colors.blue[400], fontSize: 11)),
                        Text(
                          'Light',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'Medium',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          'Heavy',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text('5.0', style: TextStyle(color: Colors.red[400], fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Mechanics
              _buildSectionCard(
                title: 'Mechanics',
                icon: Icons.build,
                subtitle: 'Select all that apply',
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

              // Categories
              _buildSectionCard(
                title: 'Category',
                icon: Icons.category,
                subtitle: 'Select all that apply',
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

              // Mark for Sell / Trade
              _buildSectionCard(
                title: 'Marketplace Status',
                icon: Icons.store,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sell, size: 18, color: AppColors.sellGreen),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Mark for Sell'),
                        ),
                        Switch(
                          value: _markForSell,
                          onChanged: (value) =>
                              setState(() => _markForSell = value),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    Row(
                      children: [
                        const Icon(
                          Icons.swap_horiz,
                          size: 18,
                          color: AppColors.tradeBlue,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Mark for Trade'),
                        ),
                        Switch(
                          value: _markForTrade,
                          onChanged: (value) =>
                              setState(() => _markForTrade = value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Photo Section
              PhotoCaptureSection(
                photoPath: _photoPath,
                filePrefix: 'game',
                onPhotoChanged: (path) => setState(() => _photoPath = path),
              ),
              const SizedBox(height: 12),

              // Save Button
              SafeArea(
                child: FilledButton.icon(
                  onPressed: _saveGame,
                  icon: Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(isEditing ? 'Update Game' : 'Add Game'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable section card with optional title, subtitle, and trailing widget.
  Widget _buildSectionCard({
    String? title,
    IconData? icon,
    String? subtitle,
    Widget? trailing,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 18, color: colorScheme.primary),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (subtitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 1),
                                  child: Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing,
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

  Widget _buildPlayerCounter({
    required String label,
    required IconData icon,
    required int value,
    VoidCallback? onDecrement,
    VoidCallback? onIncrement,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove),
                color: onDecrement != null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add),
                color: onIncrement != null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
