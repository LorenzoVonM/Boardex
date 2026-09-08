import 'dart:io';

import 'package:flutter/material.dart';

import '../models/match.dart';
import '../repositories/board_game_repository.dart';
import '../repositories/match_repository.dart';
import '../utils/image_utils.dart';
import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/photo_capture_section.dart';

class AddMatchScreen extends StatefulWidget {
  final GameMatch? matchToEdit;

  const AddMatchScreen({super.key, this.matchToEdit});

  @override
  State<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _PlayerDialogResult {
  const _PlayerDialogResult.remove()
    : remove = true,
      name = null,
      score = null,
      color = null;

  const _PlayerDialogResult.save({
    required this.name,
    required this.score,
    required this.color,
  }) : remove = false;

  final bool remove;
  final String? name;
  final int? score;
  final int? color;
}

class _PlayerDialog extends StatefulWidget {
  const _PlayerDialog({
    required this.existingPlayers,
    required this.availableColors,
    this.editingName,
    this.initialScore,
    this.initialColor,
  });

  final String? editingName;
  final Iterable<String> existingPlayers;
  final List<Color> availableColors;
  final int? initialScore;
  final int? initialColor;

  @override
  State<_PlayerDialog> createState() => _PlayerDialogState();
}

class _PlayerDialogState extends State<_PlayerDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _scoreCtrl;
  int? _selectedColor;
  String? _nameError;

  Future<void> _dismiss([_PlayerDialogResult? result]) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.editingName ?? '');
    _scoreCtrl = TextEditingController(
      text: widget.initialScore?.toString() ?? '',
    );
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _nameCtrl.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _nameError = 'Name is required');
      return;
    }
    if (trimmed != widget.editingName &&
        widget.existingPlayers.contains(trimmed)) {
      setState(() => _nameError = 'Player already added');
      return;
    }

    _dismiss(
      _PlayerDialogResult.save(
        name: trimmed,
        score: int.tryParse(_scoreCtrl.text.trim()),
        color: _selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editingName != null ? 'Edit Player' : 'Add Player'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              autofocus: widget.editingName == null,
              decoration: InputDecoration(
                labelText: 'Name',
                border: const OutlineInputBorder(),
                errorText: _nameError,
              ),
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            Text(
              'Color (optional)',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.availableColors.map((color) {
                final colorValue = color.toARGB32();
                final isSelected = _selectedColor == colorValue;
                return GestureDetector(
                  onTap: () => setState(
                    () => _selectedColor = isSelected ? null : colorValue,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _scoreCtrl,
              decoration: const InputDecoration(
                labelText: 'Score (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.editingName != null)
          TextButton(
            onPressed: () {
              _dismiss(const _PlayerDialogResult.remove());
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () {
            _dismiss();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.editingName != null ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gameNameController = TextEditingController();
  final _durationController = TextEditingController();

  MatchResult _result = MatchResult.won;
  String? _winner;
  List<String> _players = [];
  Map<String, int> _playerScores = {};
  Map<String, int> _playerColors = {};
  String? _photoPath;
  String? _originalPhotoPath;
  String? _originalThumbnailPath;
  int _matchCount = 0;
  List<String> _gameNameSuggestions = [];
  late DateTime _playedDate;
  late TimeOfDay _playedTime;

  List<_PhotoOption> _carouselItems = [];
  int? _selectedCarouselIndex;
  bool _gameInLibrary = false;

  bool get isEditing => widget.matchToEdit != null;

  @override
  void initState() {
    super.initState();
    _loadGameNames();

    final now = DateTime.now();
    _playedDate = DateTime(now.year, now.month, now.day);
    _playedTime = TimeOfDay(hour: now.hour, minute: now.minute);

    final match = widget.matchToEdit;
    if (match != null) {
      _gameNameController.text = match.gameName;
      _durationController.text = match.duration.toString();
      _result = match.result;
      _winner = match.winner;
      _players = List.from(match.players);
      _playerScores = Map.from(match.playerScores);
      _playerColors = Map.from(match.playerColors);
      _photoPath = match.photoPath;
      _originalPhotoPath = match.photoPath;
      _originalThumbnailPath = match.thumbnailPath;
      _playedDate = DateTime(
        match.playedAt.year,
        match.playedAt.month,
        match.playedAt.day,
      );
      _playedTime = TimeOfDay(
        hour: match.playedAt.hour,
        minute: match.playedAt.minute,
      );
      _refreshGameContext(match.gameName, preserveCurrentSelection: true);
    }
  }

  @override
  void dispose() {
    _gameNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadGameNames() async {
    final names = await MatchRepository.instance.getDistinctGameNames();
    if (mounted) {
      setState(() => _gameNameSuggestions = names);
    }
  }

  Future<_GameLookupSnapshot> _lookupGameContext(String gameName) async {
    if (gameName.isEmpty) {
      return const _GameLookupSnapshot(matchCount: 0, inLibrary: false);
    }

    final matchCount = await MatchRepository.instance.getMatchCountByGame(
      gameName,
    );
    final inLibrary = await BoardGameRepository.instance.exists(gameName);
    final libraryPhotoPath = inLibrary
        ? await BoardGameRepository.instance.getPhotoPath(gameName)
        : null;
    final recentMatchPhotos = await MatchRepository.instance
        .getRecentMatchPhotosForGame(gameName);

    return _GameLookupSnapshot(
      matchCount: matchCount,
      inLibrary: inLibrary,
      libraryPhotoPath: libraryPhotoPath,
      recentMatchPhotos: recentMatchPhotos,
    );
  }

  Future<void> _refreshGameContext(
    String gameName, {
    bool preserveCurrentSelection = false,
  }) async {
    final snapshot = await _lookupGameContext(gameName.trim());
    if (!mounted) return;

    setState(() {
      _matchCount = snapshot.matchCount;
      _gameInLibrary = snapshot.inLibrary;

      // Build carousel: library photo first, then recent match photos.
      final items = <_PhotoOption>[];
      if (snapshot.libraryPhotoPath != null) {
        items.add(_PhotoOption.library(thumbPath: snapshot.libraryPhotoPath));
      }
      for (final p in snapshot.recentMatchPhotos) {
        items.add(
          _PhotoOption.match(savePath: p.savePath, thumbPath: p.thumbPath),
        );
      }
      _carouselItems = items;

      if (preserveCurrentSelection) {
        // Edit mode: map the match's existing photo to a carousel index.
        if (widget.matchToEdit?.useLibraryPhoto == true) {
          final idx = items.indexWhere((i) => i.isLibrary);
          _selectedCarouselIndex = idx >= 0 ? idx : null;
        } else if (_photoPath != null) {
          final idx = items.indexWhere(
            (i) => !i.isLibrary && i.photoPath == _photoPath,
          );
          _selectedCarouselIndex = idx >= 0 ? idx : null;
          // If not in carousel, _photoPath stays as a standalone custom upload.
        } else {
          _selectedCarouselIndex = null;
        }
      } else {
        // New match or game name changed: auto-select the first carousel item.
        if (items.isNotEmpty) {
          _selectedCarouselIndex = 0;
        } else {
          _selectedCarouselIndex = null;
        }
      }
    });
  }

  static const _playerDialogColors = AppColors.playerPalette;

  void _removePlayer(String name) {
    setState(() {
      _players = _players.where((p) => p != name).toList();
      _playerScores.remove(name);
      _playerColors.remove(name);
      if (_winner == name) _winner = null;
    });
  }

  Future<void> _showPlayerDialog({String? editingName}) async {
    FocusScope.of(context).unfocus();

    final result = await showDialog<_PlayerDialogResult>(
      context: context,
      builder: (_) => _PlayerDialog(
        editingName: editingName,
        existingPlayers: _players,
        availableColors: _playerDialogColors,
        initialScore: editingName != null ? _playerScores[editingName] : null,
        initialColor: editingName != null ? _playerColors[editingName] : null,
      ),
    );

    if (!mounted || result == null) return;

    if (result.remove && editingName != null) {
      _removePlayer(editingName);
      return;
    }

    final name = result.name!;
    setState(() {
      if (editingName != null && editingName != name) {
        final idx = _players.indexOf(editingName);
        _players = List.from(_players)..[idx] = name;
        final oldScore = _playerScores.remove(editingName);
        if (oldScore != null) _playerScores[name] = oldScore;
        final oldColor = _playerColors.remove(editingName);
        if (oldColor != null) _playerColors[name] = oldColor;
        if (_winner == editingName) _winner = name;
      } else if (editingName == null) {
        _players = [..._players, name];
      }
      if (result.score != null) {
        _playerScores[name] = result.score!;
      } else {
        _playerScores.remove(name);
      }
      if (result.color != null) {
        _playerColors[name] = result.color!;
      } else {
        _playerColors.remove(name);
      }
    });
  }

  Future<void> _saveMatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final playedAt = DateTime(
      _playedDate.year,
      _playedDate.month,
      _playedDate.day,
      _playedTime.hour,
      _playedTime.minute,
    );

    final String? effectivePhotoPath;
    final bool useLibraryPhoto;

    if (_selectedCarouselIndex != null &&
        _selectedCarouselIndex! < _carouselItems.length) {
      final item = _carouselItems[_selectedCarouselIndex!];
      useLibraryPhoto = item.isLibrary;
      effectivePhotoPath = item.photoPath;
    } else {
      useLibraryPhoto = false;
      effectivePhotoPath = _photoPath;
    }

    // Only delete the original file if the user uploaded a fresh custom photo
    // (not a carousel reference that might be shared by other matches).
    if (isEditing &&
        _selectedCarouselIndex == null &&
        effectivePhotoPath != _originalPhotoPath &&
        _originalPhotoPath != null) {
      await ImageUtils.deletePhotoFiles(
        _originalPhotoPath,
        _originalThumbnailPath,
      );
    }
    final thumbPath = effectivePhotoPath != null
        ? await ImageUtils.generateThumbnail(effectivePhotoPath)
        : null;

    final match = GameMatch(
      id: widget.matchToEdit?.id,
      gameName: _gameNameController.text.trim(),
      duration: int.parse(_durationController.text),
      result: _result,
      winner: _winner,
      playerScores: _playerScores,
      playerColors: _playerColors,
      photoPath: effectivePhotoPath,
      thumbnailPath: thumbPath,
      useLibraryPhoto: useLibraryPhoto,
      playedAt: playedAt,
      players: _players,
    );

    try {
      if (isEditing) {
        await MatchRepository.instance.update(match);
      } else {
        await MatchRepository.instance.insert(match);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Match updated!' : 'Match registered!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving match: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 12;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: isEditing ? 'Edit Match' : 'Register Match',
        titleColor: AppColors.brandTeal,
        titleIcon: Icons.sports_esports_rounded,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          14,
          topPadding,
          14,
          120 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGameSection(),
              const SizedBox(height: 10),
              _buildDateTimeSection(),
              const SizedBox(height: 10),
              _buildResultSection(),
              const SizedBox(height: 10),
              _buildPlayersSection(),
              if (_players.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildWinnerSection(),
              ],
              const SizedBox(height: 10),
              _buildPhotoSection(),
              const SizedBox(height: 16),
              SafeArea(
                child: FilledButton.icon(
                  onPressed: _saveMatch,
                  icon: Icon(isEditing ? Icons.save : Icons.check),
                  label: Text(isEditing ? 'Update Match' : 'Register Match'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildSectionCard(
      title: 'Game',
      leading: Icon(Icons.casino, size: 18, color: colorScheme.primary),
      child: Column(
        children: [
          Autocomplete<String>(
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return _gameNameSuggestions.where(
                (name) => name.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            onSelected: (selection) {
              _gameNameController.text = selection;
              _refreshGameContext(selection);
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  if (isEditing && controller.text.isEmpty) {
                    controller.text = _gameNameController.text;
                  }

                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Game Name',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.casino),
                      suffixIcon: _matchCount > 0
                          ? Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_matchCount matches',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            )
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a game name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _gameNameController.text = value;
                      _refreshGameContext(value);
                    },
                  );
                },
          ),
          const SizedBox(height: 10),
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
                return 'Please enter match duration';
              }
              final duration = int.tryParse(value);
              if (duration == null || duration < 1) {
                return 'Please enter a valid duration';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildSectionCard(
      title: 'Date & Time',
      leading: Icon(Icons.date_range, size: 18, color: colorScheme.primary),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _playedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _playedDate = picked);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today, size: 18),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  '${_playedDate.month}/${_playedDate.day}/${_playedDate.year}',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _playedTime,
                );
                if (picked != null) {
                  setState(() => _playedTime = picked);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.access_time, size: 18),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                child: Text(_playedTime.format(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildSectionCard(
      title: 'Match Result',
      leading: Icon(Icons.emoji_events, size: 18, color: colorScheme.primary),
      child: Center(
        child: SegmentedButton<MatchResult>(
          segments: const [
            ButtonSegment<MatchResult>(
              value: MatchResult.won,
              label: Text('Win'),
              icon: Icon(Icons.emoji_events),
            ),
            ButtonSegment<MatchResult>(
              value: MatchResult.tie,
              label: Text('Draw'),
              icon: Icon(Icons.handshake),
            ),
            ButtonSegment<MatchResult>(
              value: MatchResult.lost,
              label: Text('Loss'),
              icon: Icon(Icons.sentiment_dissatisfied),
            ),
          ],
          selected: {_result},
          onSelectionChanged: (newSelection) {
            setState(() => _result = newSelection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => states.contains(WidgetState.selected)
                  ? _result.color.withValues(alpha: 0.2)
                  : null,
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) =>
                  states.contains(WidgetState.selected) ? _result.color : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildSectionCard(
      title: 'Players (optional)',
      leading: Icon(Icons.people, size: 18, color: colorScheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_players.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'No players yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ..._players.map((name) {
            final colorVal = _playerColors[name];
            final nameColor = colorVal != null
                ? Color(colorVal)
                : Theme.of(context).colorScheme.onSurface;
            final score = _playerScores[name];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: colorVal != null
                          ? Color(colorVal)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: colorVal == null
                          ? Border.all(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1.5,
                            )
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: nameColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (score != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        score.toString(),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _showPlayerDialog(editingName: name),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Edit player',
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: _showPlayerDialog,
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Add Player'),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerSection() {
    return _buildSectionCard(
      title: 'Winner',
      leading: const Icon(
        Icons.emoji_events,
        size: 18,
        color: AppColors.winnerGold,
      ),
      child: DropdownButtonFormField<String?>(
        initialValue: _winner,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Select winner (optional)',
        ),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('No winner selected'),
          ),
          ..._players.map((player) {
            return DropdownMenuItem<String>(value: player, child: Text(player));
          }),
        ],
        onChanged: (value) {
          setState(() => _winner = value);
        },
      ),
    );
  }

  Widget _buildPhotoSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasCarousel = _carouselItems.isNotEmpty;
    final carouselItemSelected = _selectedCarouselIndex != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasCarousel)
          _buildSectionCard(
            title: 'Select a Photo',
            leading: Icon(
              Icons.collections,
              size: 18,
              color: colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _carouselItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) =>
                        _buildCarouselItem(index, colorScheme, textTheme),
                  ),
                ),
                if (carouselItemSelected) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _carouselItems[_selectedCarouselIndex!].isLibrary
                          ? 'Using library photo'
                          : 'Using photo from a previous match',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 10),
        PhotoCaptureSection(
          // Show the uploaded photo only when no carousel item is selected.
          photoPath: carouselItemSelected ? null : _photoPath,
          filePrefix: 'match',
          onPhotoChanged: (path) => setState(() {
            _photoPath = path;
            _selectedCarouselIndex = null;
          }),
        ),
        if (!hasCarousel &&
            !_gameInLibrary &&
            _gameNameController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Game not in library — no previous photos to reuse',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCarouselItem(
    int index,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final item = _carouselItems[index];
    final isSelected = _selectedCarouselIndex == index;
    final displayPath = item.thumbPath ?? item.photoPath;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedCarouselIndex = isSelected ? null : index;
      }),
      child: SizedBox(
        width: 80,
        height: 90,
        child: Column(
          children: [
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.25),
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isSelected ? 7 : 9),
                    child: displayPath != null
                        ? Image.file(
                            File(displayPath),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, __, ___) => Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                if (item.isLibrary)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandTeal.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Library',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.surface,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    String? title,
    Widget? leading,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  if (leading != null) ...[leading, const SizedBox(width: 8)],
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _GameLookupSnapshot {
  final int matchCount;
  final bool inLibrary;
  final String? libraryPhotoPath;
  final List<({String savePath, String? thumbPath})> recentMatchPhotos;

  const _GameLookupSnapshot({
    required this.matchCount,
    required this.inLibrary,
    this.libraryPhotoPath,
    this.recentMatchPhotos = const [],
  });
}

class _PhotoOption {
  final String? thumbPath;
  final String? photoPath; // null for library references
  final bool isLibrary;

  const _PhotoOption.library({this.thumbPath})
    : photoPath = null,
      isLibrary = true;

  const _PhotoOption.match({required String savePath, this.thumbPath})
    : photoPath = savePath,
      isLibrary = false;
}
