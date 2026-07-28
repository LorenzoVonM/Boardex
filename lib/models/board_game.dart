class BoardGame {
  final int? id;
  final String name;
  final int minPlayers;
  final int maxPlayers;
  final double rating;
  final int duration; // in minutes
  final double weight; // difficulty 1.0-5.0
  final bool markForSell;
  final bool markForTrade;
  final String? photoPath;
  final List<String> mechanics;
  final List<String> categories;
  final int timesPlayed; // derived from matches table, not stored

  BoardGame({
    this.id,
    required this.name,
    required this.minPlayers,
    required this.maxPlayers,
    required this.rating,
    required this.duration,
    this.weight = 2.5,
    this.markForSell = false,
    this.markForTrade = false,
    this.photoPath,
    this.mechanics = const [],
    this.categories = const [],
    this.timesPlayed = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'minPlayers': minPlayers,
      'maxPlayers': maxPlayers,
      'rating': rating,
      'duration': duration,
      'weight': weight,
      'markForSell': markForSell ? 1 : 0,
      'markForTrade': markForTrade ? 1 : 0,
      'photoPath': photoPath,
      'mechanics': mechanics.join(','),
      'categories': categories.join(','),
    };
  }

  factory BoardGame.fromMap(Map<String, dynamic> map) {
    return BoardGame(
      id: map['id'] as int?,
      name: map['name'] as String,
      minPlayers: map['minPlayers'] as int,
      maxPlayers: map['maxPlayers'] as int,
      rating: (map['rating'] as num).toDouble(),
      duration: map['duration'] as int,
      weight: (map['weight'] as num?)?.toDouble() ?? 2.5,
      markForSell: (map['markForSell'] as int?) == 1,
      markForTrade: (map['markForTrade'] as int?) == 1,
      photoPath: map['photoPath'] as String?,
      mechanics: _parseList(map['mechanics'] as String?),
      categories: _parseList(map['categories'] as String?),
      timesPlayed: (map['timesPlayed'] as int?) ?? 0,
    );
  }

  static List<String> _parseList(String? value) {
    if (value == null || value.isEmpty) return [];
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  BoardGame copyWith({
    int? id,
    String? name,
    int? minPlayers,
    int? maxPlayers,
    double? rating,
    int? duration,
    double? weight,
    bool? markForSell,
    bool? markForTrade,
    String? photoPath,
    List<String>? mechanics,
    List<String>? categories,
    int? timesPlayed,
  }) {
    return BoardGame(
      id: id ?? this.id,
      name: name ?? this.name,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      weight: weight ?? this.weight,
      markForSell: markForSell ?? this.markForSell,
      markForTrade: markForTrade ?? this.markForTrade,
      photoPath: photoPath ?? this.photoPath,
      mechanics: mechanics ?? this.mechanics,
      categories: categories ?? this.categories,
      timesPlayed: timesPlayed ?? this.timesPlayed,
    );
  }

  @override
  String toString() {
    return 'BoardGame{id: $id, name: $name, players: $minPlayers-$maxPlayers, rating: $rating, weight: $weight, sell: $markForSell, trade: $markForTrade, duration: ${duration}min, played: $timesPlayed, mechanics: $mechanics, categories: $categories, photoPath: $photoPath}';
  }
}
