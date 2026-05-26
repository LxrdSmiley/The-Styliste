// ignore_for_file: invalid_annotation_target

// Directive N — Check-In Models
// GDD §8.12 — Daily Streak System data structures

import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_in_models.freezed.dart';
part 'check_in_models.g.dart';

/// Check-In State — Player's daily streak tracking
@freezed
class CheckInState with _$CheckInState {
  const CheckInState._();
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory CheckInState({
    @Default(0) int currentStreak,
    DateTime? lastCheckIn,
    @Default(0) int totalCheckIns,
    @Default(0) int longestStreak,
    @Default(<String>[]) List<String> rewardsClaimed,
    @Default(1) int nextRewardAt,
  }) = _CheckInState;

  factory CheckInState.fromJson(Map<String, dynamic> json) =>
      _$CheckInStateFromJson(json);

  /// Check if player can check in today (last check-in was not today)
  bool get canCheckInToday {
    if (lastCheckIn == null) return true;
    final DateTime today = DateTime.now();
    final DateTime last = lastCheckIn!;
    return !(today.year == last.year &&
        today.month == last.month &&
        today.day == last.day);
  }

  /// Check if streak is at risk (more than 24h since last check-in)
  bool get streakAtRisk {
    if (lastCheckIn == null) return false;
    final DateTime now = DateTime.now();
    final DateTime deadline = lastCheckIn!.add(const Duration(hours: 48));
    return now.isAfter(deadline);
  }

  /// Hours until streak breaks
  int get hoursUntilStreakBreaks {
    if (lastCheckIn == null) return -1;
    final DateTime deadline = lastCheckIn!.add(const Duration(hours: 48));
    final Duration remaining = deadline.difference(DateTime.now());
    return remaining.inHours.clamp(0, 48);
  }

  /// Get reward for specific streak day
  CheckInReward getRewardForDay(int day) {
    switch (day) {
      case 1:
        return const CheckInReward(
          day: 1,
          type: 'IDLE_BOOST_2H',
          title: '+2 Hour Idle Boost',
          description: 'Your empire works while you rest.',
        );
      case 3:
        return const CheckInReward(
          day: 3,
          type: 'CURRENCY_500',
          title: '500 Capital',
          description: 'Working capital for your next move.',
        );
      case 7:
        return const CheckInReward(
          day: 7,
          type: 'RARE_FABRIC',
          title: 'Rare Fabric Swatch',
          description: 'A premium material for your Atelier.',
        );
      case 14:
        return const CheckInReward(
          day: 14,
          type: 'LUXE_ACCESSORY',
          title: 'Luxe Outfit Accessory',
          description: 'Exclusive cosmetic for your mentor.',
        );
      case 30:
        return const CheckInReward(
          day: 30,
          type: 'PERMANENT_IDLE_5PCT',
          title: 'Permanent +5% Idle Multiplier',
          description: 'Your empire compounds faster. Forever.',
        );
      case 60:
        return const CheckInReward(
          day: 60,
          type: 'MAISON_BANNER',
          title: 'Exclusive Maison Banner',
          description: 'Prestige cosmetic for your alliance.',
        );
      case 100:
        return const CheckInReward(
          day: 100,
          type: 'LEGACY_BADGE',
          title: 'Legacy Check-In Badge',
          description: 'Proof of 100 days of dedication.',
        );
      default:
        return CheckInReward(
          day: day,
          type: 'STREAK_CONTINUE',
          title: 'Day $day Streak',
          description: 'Consistency builds empires.',
        );
    }
  }

  /// Get next milestone reward
  CheckInReward get nextMilestoneReward {
    final List<int> milestones = <int>[1, 3, 7, 14, 30, 60, 100];
    for (final int m in milestones) {
      if (currentStreak < m) {
        return getRewardForDay(m);
      }
    }
    return getRewardForDay(currentStreak + 1);
  }
}

/// Check-In Reward Model
@freezed
class CheckInReward with _$CheckInReward {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory CheckInReward({
    required int day,
    required String type,
    required String title,
    required String description,
  }) = _CheckInReward;

  factory CheckInReward.fromJson(Map<String, dynamic> json) =>
      _$CheckInRewardFromJson(json);
}

/// Streak Milestone Configuration
class StreakMilestones {
  static const List<int> days = <int>[1, 3, 7, 14, 30, 60, 100];

  static String getMessage(int day) {
    switch (day) {
      case 1:
        return 'You showed up. That is how every empire starts.';
      case 3:
        return 'Three days in — rivals are already nervous.';
      case 7:
        return 'A week of consistency. The fashion world is watching.';
      case 14:
        return 'Fourteen days. You are not a fluke — you are a force.';
      case 30:
        return 'A month. You have graduated from hopeful to inevitable.';
      case 60:
        return 'Two months. Legends are built in moments like this.';
      case 100:
        return 'One hundred days. I have seen empires rise and fall. Yours is rising.';
      default:
        return 'Welcome back, darling.';
    }
  }

  static String getRewardTitle(int day) {
    switch (day) {
      case 1:
        return '+2 Hour Idle Boost';
      case 3:
        return '500 Capital';
      case 7:
        return 'Rare Fabric Swatch';
      case 14:
        return 'Luxe Outfit Accessory';
      case 30:
        return 'Permanent +5% Idle';
      case 60:
        return 'Exclusive Maison Banner';
      case 100:
        return 'Legacy Badge';
      default:
        return 'Streak Reward';
    }
  }
}
