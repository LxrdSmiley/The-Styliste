// Directive J — Gala Models
// GDD §6.9, §12.3.3 — Weekly PvP event data structures

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../talent/models/talent.dart';
import '../services/gala_scoring_engine.dart';

part 'gala_models.freezed.dart';
part 'gala_models.g.dart';

/// Gala Event — Weekly themed competition
@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GalaEvent with _$GalaEvent {
  const GalaEvent._();
  const factory GalaEvent({
    required String id,
    required String themeTitle,
    required DateTime startsAt, required DateTime endsAt, String? themeDescription,
    @Default(<String>[]) List<String> styleTags,
    @Default('upcoming') String status,
    @Default(10000) int prizePoolLuxe,
    @Default(0) int totalSubmissions,
  }) = _GalaEvent;

  factory GalaEvent.fromJson(Map<String, dynamic> json) =>
      _$GalaEventFromJson(json);

  /// Check if event is currently accepting submissions
  bool get isAcceptingSubmissions =>
      status == 'active' || status == 'upcoming';

  /// Check if event is in voting phase
  bool get isVoting => status == 'voting' || status == 'active';

  /// Time remaining until event ends
  Duration get timeRemaining => endsAt.difference(DateTime.now());

  /// Formatted time remaining string
  String get formattedTimeRemaining {
    final Duration remaining = timeRemaining;
    if (remaining.isNegative) return 'ENDED';
    
    final int days = remaining.inDays;
    final int hours = remaining.inHours % 24;
    
    if (days > 0) {
      return '$days DAYS $hours HRS';
    }
    return '$hours HRS ${remaining.inMinutes % 60} MIN';
  }
}

/// Gala Submission — Player's entry with votes
@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GalaSubmission with _$GalaSubmission {
  const GalaSubmission._();
  const factory GalaSubmission({
    required String id,
    required String eventId,
    required String playerId,
    required String designId,
    String? talentId,
    @Default(0.0) double currentScore,
    @Default(0) int voteCount,
    @Default(0) int adoreCount,
    @Default(0) int iconicCount,
    @Default(0) int sovereignCount,
    @Default(0) int timelessCount,
    DateTime? submittedAt,
    int? finalRank,
    @Default(0) int luxeWon,
    @Default(false) bool isGalaSovereign,
    // Populated via join
    String? designName,
    String? designImageUrl,
    String? playerName,
    Talent? talent,
  }) = _GalaSubmission;

  factory GalaSubmission.fromJson(Map<String, dynamic> json) =>
      _$GalaSubmissionFromJson(json);

  /// Check if this submission has a Sovereign talent (for Gilded Ripple)
  bool get hasSovereignTalent => talent?.tier == TalentTier.sovereign;

  /// Formatted score display
  String get formattedScore {
    if (currentScore == currentScore.toInt()) {
      return currentScore.toInt().toString();
    }
    return currentScore.toStringAsFixed(1);
  }
}

/// Vote cast by a player
@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GalaVote with _$GalaVote {
  const GalaVote._();
  const factory GalaVote({
    required String id,
    required String submissionId,
    required String voterId,
    required String voteTier,
    @Default(0) int basePoints,
    @Default(1.0) double talentMultiplier,
    @Default(0.0) double finalPoints,
    @Default(0) int luxeSpent,
    DateTime? votedAt,
  }) = _GalaVote;

  factory GalaVote.fromJson(Map<String, dynamic> json) =>
      _$GalaVoteFromJson(json);

  /// Get VoteTier enum
  VoteTier get tier => GalaScoringEngine.fromString(voteTier);
}

/// Daily vote limits for a player
@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class VoteLimits with _$VoteLimits {
  const VoteLimits._();
  const factory VoteLimits({
    required String playerId,
    required String eventId,
    required DateTime voteDate,
    @Default(0) int adoreUsed,
    @Default(0) int iconicUsed,
    @Default(0) int sovereignUsed,
    @Default(0) int timelessUsed,
  }) = _VoteLimits;

  factory VoteLimits.fromJson(Map<String, dynamic> json) =>
      _$VoteLimitsFromJson(json);

  /// Check if player can cast specific vote tier
  bool canVote(VoteTier tier) {
    switch (tier) {
      case VoteTier.adore:
        return adoreUsed < 100;  // Soft limit
      case VoteTier.iconic:
        return iconicUsed < 10;
      case VoteTier.sovereign:
        return sovereignUsed < 3;
      case VoteTier.timeless:
        return timelessUsed < 1;
    }
  }

  /// Get remaining votes for tier
  int remaining(VoteTier tier) {
    switch (tier) {
      case VoteTier.adore:
        return 100 - adoreUsed;
      case VoteTier.iconic:
        return 10 - iconicUsed;
      case VoteTier.sovereign:
        return 3 - sovereignUsed;
      case VoteTier.timeless:
        return 1 - timelessUsed;
    }
  }
}

/// Leaderboard entry
@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class LeaderboardEntry with _$LeaderboardEntry {
  const LeaderboardEntry._();
  const factory LeaderboardEntry({
    required int rank,
    required String submissionId,
    required String playerId,
    required String designId,
    required double currentScore, String? talentId,
    @Default(0) int voteCount,
    @Default(false) bool isGalaSovereign,
    // Populated fields
    String? playerName,
    String? designName,
    String? designImageUrl,
    String? talentName,
  }) = _LeaderboardEntry;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);

  /// Prize for this rank
  int get prizeAmount => GalaPrizeCalculator.calculatePrize(rank);

  /// Is this The Sovereign (Rank 1)?
  bool get isTheSovereign => rank == 1;
}

/// Submission result after voting
@freezed
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class VoteResult with _$VoteResult {
  const factory VoteResult({
    required bool success,
    required double finalPoints,
    String? message,
    String? submissionId,
  }) = _VoteResult;

  factory VoteResult.fromJson(Map<String, dynamic> json) =>
      _$VoteResultFromJson(json);
}
