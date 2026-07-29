import 'package:flutter_test/flutter_test.dart';
import 'package:bg_app2/models/board_game.dart';

void main() {
  group('BoardGame Model Tests', () {
    test('toMap and fromMap roundtrip with mechanics and categories', () {
      final game = BoardGame(
        id: 10,
        name: 'Ticket to Ride',
        minPlayers: 2,
        maxPlayers: 5,
        rating: 8.0,
        duration: 60,
        weight: 1.9,
        markForSell: true,
        markForTrade: false,
        sellPrice: 45.50,
        photoPath: '/path/to/cover.jpg',
        mechanics: ['Network and Route Building', 'Set Collection'],
        categories: ['Trains', 'Family'],
        timesPlayed: 5,
      );

      final map = game.toMap();

      expect(map['id'], 10);
      expect(map['name'], 'Ticket to Ride');
      expect(map['minPlayers'], 2);
      expect(map['maxPlayers'], 5);
      expect(map['rating'], 8.0);
      expect(map['duration'], 60);
      expect(map['weight'], 1.9);
      expect(map['markForSell'], 1);
      expect(map['markForTrade'], 0);
      expect(map['sellPrice'], 45.50);
      expect(map['photoPath'], '/path/to/cover.jpg');
      expect(map['mechanics'], 'Network and Route Building,Set Collection');
      expect(map['categories'], 'Trains,Family');

      final restored = BoardGame.fromMap(map);

      expect(restored.id, game.id);
      expect(restored.name, game.name);
      expect(restored.minPlayers, game.minPlayers);
      expect(restored.maxPlayers, game.maxPlayers);
      expect(restored.rating, game.rating);
      expect(restored.duration, game.duration);
      expect(restored.weight, game.weight);
      expect(restored.markForSell, true);
      expect(restored.markForTrade, false);
      expect(restored.sellPrice, 45.50);
      expect(restored.photoPath, game.photoPath);
      expect(restored.mechanics, ['Network and Route Building', 'Set Collection']);
      expect(restored.categories, ['Trains', 'Family']);
    });

    test('fromMap parses empty or null comma-separated lists correctly', () {
      final map = <String, dynamic>{
        'id': 11,
        'name': 'Simple Game',
        'minPlayers': 1,
        'maxPlayers': 2,
        'rating': 7.0,
        'duration': 15,
        'weight': 1.0,
        'markForSell': 0,
        'markForTrade': 0,
        'photoPath': null,
        'mechanics': null,
        'categories': '',
      };

      final game = BoardGame.fromMap(map);

      expect(game.mechanics, isEmpty);
      expect(game.categories, isEmpty);
    });

    test('copyWith updates properties properly', () {
      final initial = BoardGame(
        name: 'Gloomhaven',
        minPlayers: 1,
        maxPlayers: 4,
        rating: 9.0,
        duration: 120,
      );

      final updated = initial.copyWith(
        rating: 9.5,
        markForSell: true,
      );

      expect(updated.name, 'Gloomhaven');
      expect(updated.rating, 9.5);
      expect(updated.markForSell, true);
      expect(updated.minPlayers, 1);
    });
  });
}
