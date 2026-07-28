import 'dart:convert';

enum MatchResult {
  won,
  tie,
  lost;

  static MatchResult fromStorage(String value) {
    return MatchResult.values.firstWhere(
      (result) => result.name == value,
      orElse: () => MatchResult.tie,
    );
  }
}

class GameMatch {
  final int? id;
  final String gameName;
  final int duration; // in minutes
  final MatchResult result;
  final String? winner; // player who won
  final Map<String, int> playerScores; // player name -> score
  final Map<String, int> playerColors; // player name -> color ARGB value
  final String? photoPath;
  final bool useLibraryPhoto; // true = use photo from library game
  final DateTime playedAt;
  final List<String> players;

  GameMatch({
    this.id,
    required this.gameName,
    required this.duration,
    required this.result,
    this.winner,
    this.playerScores = const {},
    this.playerColors = const {},
    this.photoPath,
    this.useLibraryPhoto = false,
    required this.playedAt,
    this.players = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameName': gameName,
      'duration': duration,
      'result': result.name,
      'winner': winner,
      'playerScores': playerScores.isNotEmpty ? jsonEncode(playerScores) : null,
      'playerColors': playerColors.isNotEmpty ? jsonEncode(playerColors) : null,
      'photoPath': photoPath,
      'useLibraryPhoto': useLibraryPhoto ? 1 : 0,
      'playedAt': playedAt.toIso8601String(),
      'players': players.isNotEmpty ? jsonEncode(players) : null,
    };
  }

  factory GameMatch.fromMap(Map<String, dynamic> map) {
    final playersStr = map['players'] as String?;
    final scoresStr = map['playerScores'] as String?;

    Map<String, int> scores = {};
    if (scoresStr != null && scoresStr.isNotEmpty) {
      final decoded = jsonDecode(scoresStr) as Map<String, dynamic>;
      scores = decoded.map((k, v) => MapEntry(k, v as int));
    }

    final colorsStr = map['playerColors'] as String?;
    Map<String, int> colors = {};
    if (colorsStr != null && colorsStr.isNotEmpty) {
      final decoded = jsonDecode(colorsStr) as Map<String, dynamic>;
      colors = decoded.map((k, v) => MapEntry(k, v as int));
    }

    List<String> players = [];
    if (playersStr != null && playersStr.isNotEmpty) {
      final decoded = jsonDecode(playersStr) as List<dynamic>;
      players = decoded.cast<String>();
    }

    return GameMatch(
      id: map['id'] as int?,
      gameName: map['gameName'] as String,
      duration: map['duration'] as int,
      result: MatchResult.fromStorage(map['result'] as String),
      winner: map['winner'] as String?,
      playerScores: scores,
      playerColors: colors,
      photoPath: map['photoPath'] as String?,
      useLibraryPhoto: (map['useLibraryPhoto'] as int?) == 1,
      playedAt: DateTime.parse(map['playedAt'] as String),
      players: players,
    );
  }

  GameMatch copyWith({
    int? id,
    String? gameName,
    int? duration,
    MatchResult? result,
    String? winner,
    Map<String, int>? playerScores,
    Map<String, int>? playerColors,
    String? photoPath,
    bool? useLibraryPhoto,
    DateTime? playedAt,
    List<String>? players,
  }) {
    return GameMatch(
      id: id ?? this.id,
      gameName: gameName ?? this.gameName,
      duration: duration ?? this.duration,
      result: result ?? this.result,
      winner: winner ?? this.winner,
      playerScores: playerScores ?? this.playerScores,
      playerColors: playerColors ?? this.playerColors,
      photoPath: photoPath ?? this.photoPath,
      useLibraryPhoto: useLibraryPhoto ?? this.useLibraryPhoto,
      playedAt: playedAt ?? this.playedAt,
      players: players ?? this.players,
    );
  }

  @override
  String toString() {
    return 'GameMatch{id: $id, gameName: $gameName, duration: ${duration}min, result: $result, winner: $winner, useLibraryPhoto: $useLibraryPhoto, playedAt: $playedAt, players: ${players.length}}';
  }
}
