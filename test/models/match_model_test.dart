import 'package:flutter_test/flutter_test.dart';
import 'package:bg_app2/models/match.dart';

void main() {
  group('MatchResult Enum Tests', () {
    test('fromStorage returns correct enum value', () {
      expect(MatchResult.fromStorage('won'), MatchResult.won);
      expect(MatchResult.fromStorage('tie'), MatchResult.tie);
      expect(MatchResult.fromStorage('lost'), MatchResult.lost);
    });

    test('fromStorage defaults to tie on unknown string', () {
      expect(MatchResult.fromStorage('unknown'), MatchResult.tie);
    });
  });

  group('GameMatch Model Tests', () {
    final now = DateTime.parse('2026-07-28 14:30:00');

    test('toMap and fromMap serialization roundtrip with players and scores', () {
      final match = GameMatch(
        id: 1,
        gameName: 'Catan',
        duration: 45,
        result: MatchResult.won,
        winner: 'Alice',
        playerScores: {'Alice': 10, 'Bob': 8},
        playerColors: {'Alice': 4294901760, 'Bob': 4278190080},
        photoPath: '/path/to/photo.jpg',
        useLibraryPhoto: false,
        playedAt: now,
        players: ['Alice', 'Bob'],
      );

      final map = match.toMap();

      expect(map['id'], 1);
      expect(map['gameName'], 'Catan');
      expect(map['duration'], 45);
      expect(map['result'], 'won');
      expect(map['winner'], 'Alice');
      expect(map['useLibraryPhoto'], 0);
      expect(map['photoPath'], '/path/to/photo.jpg');
      expect(map['playedAt'], now.toIso8601String());

      final restoredMatch = GameMatch.fromMap(map);

      expect(restoredMatch.id, match.id);
      expect(restoredMatch.gameName, match.gameName);
      expect(restoredMatch.duration, match.duration);
      expect(restoredMatch.result, MatchResult.won);
      expect(restoredMatch.winner, match.winner);
      expect(restoredMatch.players, ['Alice', 'Bob']);
      expect(restoredMatch.playerScores, {'Alice': 10, 'Bob': 8});
      expect(restoredMatch.playerColors, {'Alice': 4294901760, 'Bob': 4278190080});
      expect(restoredMatch.useLibraryPhoto, false);
      expect(restoredMatch.photoPath, match.photoPath);
      expect(restoredMatch.playedAt, now);
    });

    test('fromMap handles null optional fields gracefully', () {
      final map = <String, dynamic>{
        'id': 2,
        'gameName': 'Carcassonne',
        'duration': 30,
        'result': 'lost',
        'winner': null,
        'playerScores': null,
        'playerColors': null,
        'photoPath': null,
        'useLibraryPhoto': 1,
        'playedAt': now.toIso8601String(),
        'players': null,
      };

      final match = GameMatch.fromMap(map);

      expect(match.id, 2);
      expect(match.gameName, 'Carcassonne');
      expect(match.result, MatchResult.lost);
      expect(match.winner, isNull);
      expect(match.playerScores, isEmpty);
      expect(match.playerColors, isEmpty);
      expect(match.players, isEmpty);
      expect(match.useLibraryPhoto, true);
    });

    test('copyWith creates a modified copy', () {
      final initial = GameMatch(
        id: 1,
        gameName: 'Wingspan',
        duration: 60,
        result: MatchResult.tie,
        playedAt: now,
      );

      final updated = initial.copyWith(
        duration: 75,
        result: MatchResult.won,
        winner: 'Charlie',
      );

      expect(updated.id, initial.id);
      expect(updated.gameName, 'Wingspan');
      expect(updated.duration, 75);
      expect(updated.result, MatchResult.won);
      expect(updated.winner, 'Charlie');
      expect(updated.playedAt, now);
    });
  });
}
