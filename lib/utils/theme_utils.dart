import 'package:flutter/material.dart';
import '../models/match.dart';

class AppColors {
  static const Color headerCoral = Color(0xFFF88379);
  static const Color brandPeach = Color(0xFFFFB7A3);
  static const Color brandRose = Color(0xFFE85D75);
  static const Color brandBlue = Color(0xFF305A8C);
  static const Color brandTeal = Color(0xFF2C9FAF);

  static const Color weightEasy = Color(0xFF3F8CFF);
  static const Color weightMedium = Color(0xFF2CA58D);
  static const Color weightHard = Color(0xFFF2A65A);
  static const Color weightExtreme = Color(0xFFD1495B);

  static const Color resultWon = Color(0xFF2EAF61);
  static const Color resultTie = Color(0xFF4F8EE8);
  static const Color resultLost = Color(0xFFD1495B);
}

enum MatchResultTagSize { compact, regular }

Widget buildMatchResultTag(
  MatchResult result, {
  MatchResultTagSize size = MatchResultTagSize.compact,
  bool uppercase = false,
}) {
  final label = uppercase ? result.label.toUpperCase() : result.label;
  final iconSize = size == MatchResultTagSize.compact ? 13.0 : 16.0;
  final fontSize = size == MatchResultTagSize.compact ? 10.0 : 12.0;
  final horizontalPadding = size == MatchResultTagSize.compact ? 10.0 : 12.0;
  final verticalPadding = size == MatchResultTagSize.compact ? 6.0 : 6.0;
  final spacing = size == MatchResultTagSize.compact ? 4.0 : 4.0;

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    ),
    decoration: BoxDecoration(
      color: result.color,
      borderRadius: BorderRadius.circular(999),
      boxShadow: [
        BoxShadow(
          color: result.color.withValues(alpha: 0.34),
          blurRadius: size == MatchResultTagSize.compact ? 10 : 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(result.icon, color: Colors.white, size: iconSize),
        SizedBox(width: spacing),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: uppercase ? 0.7 : 0,
          ),
        ),
      ],
    ),
  );
}

/// Shared weight color mapping used across the app.
Color getWeightColor(double weight) {
  if (weight < 3.0) {
    return AppColors.weightEasy;
  } else if (weight < 4.0) {
    return AppColors.weightMedium;
  } else if (weight <= 4.5) {
    return AppColors.weightHard;
  } else {
    return AppColors.weightExtreme;
  }
}

extension MatchResultUi on MatchResult {
  Color get color {
    switch (this) {
      case MatchResult.won:
        return AppColors.resultWon;
      case MatchResult.tie:
        return AppColors.resultTie;
      case MatchResult.lost:
        return AppColors.resultLost;
    }
  }

  IconData get icon {
    switch (this) {
      case MatchResult.won:
        return Icons.emoji_events;
      case MatchResult.tie:
        return Icons.handshake;
      case MatchResult.lost:
        return Icons.sentiment_dissatisfied;
    }
  }

  String get label {
    switch (this) {
      case MatchResult.won:
        return 'Win';
      case MatchResult.tie:
        return 'Draw';
      case MatchResult.lost:
        return 'Loss';
    }
  }

  String get displayText {
    switch (this) {
      case MatchResult.won:
        return 'Win';
      case MatchResult.tie:
        return 'Draw';
      case MatchResult.lost:
        return 'Loss';
    }
  }
}
