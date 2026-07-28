import 'match.dart';

enum SummaryExportSection { header, stats, filters, activity, topGames }

enum SummaryExportTemplate { landscapeDashboard, summaryResultsPortrait }

const int summaryExportTopGamesCount = 3;

class SummaryExportOptions {
  final SummaryExportTemplate template;
  final Set<SummaryExportSection> sections;
  final double pixelRatio;

  const SummaryExportOptions({
    required this.template,
    required this.sections,
    this.pixelRatio = 3,
  });

  factory SummaryExportOptions.defaults() {
    return const SummaryExportOptions(
      template: SummaryExportTemplate.landscapeDashboard,
      sections: {
        SummaryExportSection.header,
        SummaryExportSection.stats,
        SummaryExportSection.filters,
        SummaryExportSection.activity,
        SummaryExportSection.topGames,
      },
    );
  }

  bool includes(SummaryExportSection section) => sections.contains(section);

  double get canvasWidth {
    switch (template) {
      case SummaryExportTemplate.landscapeDashboard:
        return 960;
      case SummaryExportTemplate.summaryResultsPortrait:
        return 480;
    }
  }

  double get canvasAspectRatio {
    switch (template) {
      case SummaryExportTemplate.landscapeDashboard:
        return 16 / 9;
      case SummaryExportTemplate.summaryResultsPortrait:
        return 9 / 16;
    }
  }

  SummaryExportOptions copyWith({
    SummaryExportTemplate? template,
    Set<SummaryExportSection>? sections,
    double? pixelRatio,
  }) {
    return SummaryExportOptions(
      template: template ?? this.template,
      sections: sections ?? this.sections,
      pixelRatio: pixelRatio ?? this.pixelRatio,
    );
  }
}

class SummaryGameSummary {
  final String gameName;
  final List<GameMatch> matches;
  final int timesPlayed;
  final double? rating;
  final String? photoPath;
  final int wins;
  final int ties;
  final int losses;

  const SummaryGameSummary({
    required this.gameName,
    required this.matches,
    required this.timesPlayed,
    this.rating,
    this.photoPath,
    required this.wins,
    required this.ties,
    required this.losses,
  });

  factory SummaryGameSummary.fromMatches({
    required String gameName,
    required List<GameMatch> matches,
    required int timesPlayed,
    double? rating,
    String? photoPath,
  }) {
    var wins = 0;
    var ties = 0;
    var losses = 0;

    for (final match in matches) {
      switch (match.result) {
        case MatchResult.won:
          wins++;
          break;
        case MatchResult.tie:
          ties++;
          break;
        case MatchResult.lost:
          losses++;
          break;
      }
    }

    return SummaryGameSummary(
      gameName: gameName,
      matches: matches,
      timesPlayed: timesPlayed,
      rating: rating,
      photoPath: photoPath,
      wins: wins,
      ties: ties,
      losses: losses,
    );
  }

  MatchResult get dominantResult {
    if (wins >= ties && wins >= losses) {
      return MatchResult.won;
    }
    if (losses >= wins && losses >= ties) {
      return MatchResult.lost;
    }
    return MatchResult.tie;
  }
}

class SummaryExportData {
  final DateTime fromDate;
  final DateTime toDate;
  final MatchResult? resultFilter;
  final List<String> players;
  final int totalMatches;
  final Map<String, int> matchCountByDay;
  final List<SummaryGameSummary> summaries;

  const SummaryExportData({
    required this.fromDate,
    required this.toDate,
    required this.resultFilter,
    required this.players,
    required this.totalMatches,
    required this.matchCountByDay,
    required this.summaries,
  });

  int get totalGames => summaries.length;

  int get totalWins => summaries.fold(0, (sum, summary) => sum + summary.wins);

  int get totalTies => summaries.fold(0, (sum, summary) => sum + summary.ties);

  int get totalLosses =>
      summaries.fold(0, (sum, summary) => sum + summary.losses);

  double get winRate => totalMatches == 0 ? 0 : totalWins / totalMatches;

  double? get winLossRatio {
    if (totalWins == 0 && totalLosses == 0) {
      return null;
    }
    if (totalLosses == 0) {
      return totalWins.toDouble();
    }
    return totalWins / totalLosses;
  }

  List<SummaryGameSummary> topGames() =>
      summaries.take(summaryExportTopGamesCount).toList(growable: false);

  List<GameMatch> get allMatches {
    final matches = summaries
        .expand((summary) => summary.matches)
        .toList(growable: false);
    matches.sort((a, b) => a.playedAt.compareTo(b.playedAt));
    return matches;
  }
}
