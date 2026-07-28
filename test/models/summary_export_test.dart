import 'package:flutter_test/flutter_test.dart';
import 'package:bg_app2/models/match.dart';
import 'package:bg_app2/models/summary_export.dart';

void main() {
  group('SummaryGameSummary Tests', () {
    final now = DateTime.now();

    test('fromMatches tallies wins, ties, and losses correctly', () {
      final matches = [
        GameMatch(gameName: 'Catan', duration: 45, result: MatchResult.won, playedAt: now),
        GameMatch(gameName: 'Catan', duration: 45, result: MatchResult.won, playedAt: now),
        GameMatch(gameName: 'Catan', duration: 45, result: MatchResult.tie, playedAt: now),
        GameMatch(gameName: 'Catan', duration: 45, result: MatchResult.lost, playedAt: now),
      ];

      final summary = SummaryGameSummary.fromMatches(
        gameName: 'Catan',
        matches: matches,
        timesPlayed: 4,
        rating: 8.5,
      );

      expect(summary.gameName, 'Catan');
      expect(summary.timesPlayed, 4);
      expect(summary.wins, 2);
      expect(summary.ties, 1);
      expect(summary.losses, 1);
      expect(summary.dominantResult, MatchResult.won);
    });

    test('dominantResult resolves tie and loss dominant states', () {
      final lossMatches = [
        GameMatch(gameName: 'Azul', duration: 30, result: MatchResult.lost, playedAt: now),
        GameMatch(gameName: 'Azul', duration: 30, result: MatchResult.lost, playedAt: now),
        GameMatch(gameName: 'Azul', duration: 30, result: MatchResult.won, playedAt: now),
      ];
      final lossSummary = SummaryGameSummary.fromMatches(
        gameName: 'Azul',
        matches: lossMatches,
        timesPlayed: 3,
      );
      expect(lossSummary.dominantResult, MatchResult.lost);

      final tieMatches = [
        GameMatch(gameName: 'Chess', duration: 20, result: MatchResult.tie, playedAt: now),
      ];
      final tieSummary = SummaryGameSummary.fromMatches(
        gameName: 'Chess',
        matches: tieMatches,
        timesPlayed: 1,
      );
      expect(tieSummary.dominantResult, MatchResult.tie);
    });
  });

  group('SummaryExportData Tests', () {
    final fromDate = DateTime(2026, 1, 1);
    final toDate = DateTime(2026, 1, 31);
    final now = DateTime(2026, 1, 15);

    test('aggregates total statistics and computes win rate correctly', () {
      final catanMatches = [
        GameMatch(gameName: 'Catan', duration: 60, result: MatchResult.won, playedAt: now),
        GameMatch(gameName: 'Catan', duration: 60, result: MatchResult.won, playedAt: now),
      ];
      final azulMatches = [
        GameMatch(gameName: 'Azul', duration: 30, result: MatchResult.lost, playedAt: now),
        GameMatch(gameName: 'Azul', duration: 30, result: MatchResult.tie, playedAt: now),
      ];

      final summaries = [
        SummaryGameSummary.fromMatches(
          gameName: 'Catan',
          matches: catanMatches,
          timesPlayed: 2,
        ),
        SummaryGameSummary.fromMatches(
          gameName: 'Azul',
          matches: azulMatches,
          timesPlayed: 2,
        ),
      ];

      final exportData = SummaryExportData(
        fromDate: fromDate,
        toDate: toDate,
        resultFilter: null,
        players: ['Alice'],
        totalMatches: 4,
        matchCountByDay: {'2026-01-15': 4},
        summaries: summaries,
      );

      expect(exportData.totalGames, 2);
      expect(exportData.totalMatches, 4);
      expect(exportData.totalWins, 2);
      expect(exportData.totalTies, 1);
      expect(exportData.totalLosses, 1);
      expect(exportData.winRate, 0.5); // 2 / 4 = 50%
      expect(exportData.winLossRatio, 2.0); // 2 wins / 1 loss
    });

    test('winLossRatio handles zero losses and zero total matches safely', () {
      final exportDataNoLosses = SummaryExportData(
        fromDate: fromDate,
        toDate: toDate,
        resultFilter: null,
        players: [],
        totalMatches: 3,
        matchCountByDay: {},
        summaries: [
          SummaryGameSummary.fromMatches(
            gameName: 'Catan',
            matches: [
              GameMatch(gameName: 'Catan', duration: 60, result: MatchResult.won, playedAt: now),
              GameMatch(gameName: 'Catan', duration: 60, result: MatchResult.won, playedAt: now),
              GameMatch(gameName: 'Catan', duration: 60, result: MatchResult.won, playedAt: now),
            ],
            timesPlayed: 3,
          ),
        ],
      );

      expect(exportDataNoLosses.winLossRatio, 3.0);

      final emptyExportData = SummaryExportData(
        fromDate: fromDate,
        toDate: toDate,
        resultFilter: null,
        players: [],
        totalMatches: 0,
        matchCountByDay: {},
        summaries: [],
      );

      expect(emptyExportData.winRate, 0.0);
      expect(emptyExportData.winLossRatio, isNull);
    });

    test('topGames limits output to top 3 summaries', () {
      final summaries = List.generate(5, (index) {
        return SummaryGameSummary.fromMatches(
          gameName: 'Game $index',
          matches: [],
          timesPlayed: 5 - index,
        );
      });

      final exportData = SummaryExportData(
        fromDate: fromDate,
        toDate: toDate,
        resultFilter: null,
        players: [],
        totalMatches: 15,
        matchCountByDay: {},
        summaries: summaries,
      );

      final topGames = exportData.topGames();

      expect(topGames.length, 3);
      expect(topGames[0].gameName, 'Game 0');
      expect(topGames[1].gameName, 'Game 1');
      expect(topGames[2].gameName, 'Game 2');
    });
  });
}
