class BoardGame {
  final int? id;
  final String name;
  final int minPlayers;
  final int maxPlayers;
  final double rating;
  final int duration; // in minutes
  final double weight; // difficulty 1.0-5.0
  final bool isOwned;
  final bool markForSell;
  final bool markForTrade;
  final double? sellPrice;
  final String? photoPath;
  final String? thumbnailPath;
  final List<String> mechanics;
  final List<String> categories;
  final int timesPlayed; // derived from matches table, not stored

  String? get displayPhotoPath => thumbnailPath ?? photoPath;

  BoardGame({
    this.id,
    required this.name,
    required this.minPlayers,
    required this.maxPlayers,
    required this.rating,
    required this.duration,
    this.weight = 2.5,
    this.isOwned = false,
    this.markForSell = false,
    this.markForTrade = false,
    this.sellPrice,
    this.photoPath,
    this.thumbnailPath,
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
      'isOwned': isOwned ? 1 : 0,
      'markForSell': markForSell ? 1 : 0,
      'markForTrade': markForTrade ? 1 : 0,
      'sellPrice': sellPrice,
      'photoPath': photoPath,
      'thumbnailPath': thumbnailPath,
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
      isOwned: (map['isOwned'] as int?) == 1,
      markForSell: (map['markForSell'] as int?) == 1,
      markForTrade: (map['markForTrade'] as int?) == 1,
      sellPrice: (map['sellPrice'] as num?)?.toDouble(),
      photoPath: map['photoPath'] as String?,
      thumbnailPath: map['thumbnailPath'] as String?,
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
    bool? isOwned,
    bool? markForSell,
    bool? markForTrade,
    double? sellPrice,
    String? photoPath,
    String? thumbnailPath,
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
      isOwned: isOwned ?? this.isOwned,
      markForSell: markForSell ?? this.markForSell,
      markForTrade: markForTrade ?? this.markForTrade,
      sellPrice: sellPrice ?? this.sellPrice,
      photoPath: photoPath ?? this.photoPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      mechanics: mechanics ?? this.mechanics,
      categories: categories ?? this.categories,
      timesPlayed: timesPlayed ?? this.timesPlayed,
    );
  }

  @override
  String toString() {
    return 'BoardGame{id: $id, name: $name, players: $minPlayers-$maxPlayers, rating: $rating, weight: $weight, owned: $isOwned, sell: $markForSell, trade: $markForTrade, price: $sellPrice, duration: ${duration}min, played: $timesPlayed, mechanics: $mechanics, categories: $categories, photoPath: $photoPath, thumbnailPath: $thumbnailPath}';
  }
}
