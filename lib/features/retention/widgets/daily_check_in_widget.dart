// Directive N — Daily Check-In Widget
// GDD §8.12, §3.7 — The 30-Day Streak System
//
// Shows current streak, next milestone, and claim button
// Luxe personalized messages per streak day

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/telemetry_service.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../models/check_in_models.dart';

/// Daily Check-In Widget — Streak display and claim button
///
/// Shows:
/// - Current streak counter (flame animation)
/// - Next milestone preview
/// - Luxe personalized message
/// - Claim button (disabled if already checked in today)
class DailyCheckInWidget extends ConsumerStatefulWidget {
  const DailyCheckInWidget({super.key});

  @override
  ConsumerState<DailyCheckInWidget> createState() => _DailyCheckInWidgetState();
}

class _DailyCheckInWidgetState extends ConsumerState<DailyCheckInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flameController;
  CheckInState? _state;
  bool _isLoading = true;
  bool _isClaiming = false;
  String? _rewardMessage;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _loadCheckInState();
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  Future<void> _loadCheckInState() async {
    final String? playerId = Supabase.instance.client.auth.currentUser?.id;
    if (playerId == null) return;

    try {
      final PostgrestMap? response = await Supabase.instance.client
          .from(SupabaseConstants.tableDailyCheckIns)
          .select()
          .eq('player_id', playerId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          if (response != null) {
            _state = CheckInState.fromJson(response);
          } else {
            _state = const CheckInState();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _claimCheckIn() async {
    if (_isClaiming) return;

    setState(() => _isClaiming = true);
    HapticFeedback.mediumImpact();

    final String? playerId = Supabase.instance.client.auth.currentUser?.id;
    if (playerId == null) return;

    try {
      final Map<String, dynamic> result =
          await Supabase.instance.client.rpc<Map<String, dynamic>>(
        SupabaseConstants.fnRecordCheckIn,
        params: <String, dynamic>{'p_player_id': playerId},
      );

      final bool isNewDay = result['is_new_day'] as bool? ?? false;
      final int streak = result['streak'] as int? ?? 0;
      final String? reward = result['reward_granted'] as String?;
      final String? message = result['message'] as String?;

      if (isNewDay && mounted) {
        setState(() {
          _state = _state?.copyWith(
            currentStreak: streak,
            lastCheckIn: DateTime.now(),
            totalCheckIns: (_state?.totalCheckIns ?? 0) + 1,
          );
          _rewardMessage = message;
        });

        // Log telemetry
        TelemetryService.instance.logCheckIn(
          streakDay: streak,
          rewardGranted: reward ?? 'NONE',
          isNewDay: true,
        );

        // Clear reward message after delay
        Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() => _rewardMessage = null);
          }
        });
      }
    } catch (e) {
      debugPrint('Check-in failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSkeleton();
    }

    if (_state == null) {
      return const SizedBox.shrink();
    }

    final bool canCheckIn = _state!.canCheckInToday;
    final int streak = _state!.currentStreak;
    final int nextMilestone = _getNextMilestone(streak);
    final int daysToMilestone = nextMilestone - streak;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AurelianPalette.champagneGold.withValues(alpha: 0.15),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'DAILY CHECK-IN',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: Color(0xFF2A2A2A),
                ),
              ),
              if (streak > 0)
                AnimatedBuilder(
                  animation: _flameController,
                  builder: (BuildContext context, Widget? child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Color.lerp(
                              const Color(0xFFFF6B35),
                              const Color(0xFFFFA500),
                              _flameController.value,
                            )!,
                            const Color(0xFFFF4500),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 16.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            '$streak',
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            ' DAY${streak == 1 ? '' : 'S'}',
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Streak visualization
          if (streak > 0) ...<Widget>[
            _buildStreakBar(streak, nextMilestone),
            const SizedBox(height: 12.0),
            Text(
              daysToMilestone <= 0
                  ? '🔥 MILESTONE REACHED! Claim your reward.'
                  : '$daysToMilestone day${daysToMilestone == 1 ? '' : 's'} to next milestone',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 11.0,
                color: const Color(0xFF2A2A2A).withValues(alpha: 0.6),
              ),
            ),
          ] else ...<Widget>[
            Text(
              'Start your streak today. Every empire begins with a single day.',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 12.0,
                color: const Color(0xFF2A2A2A).withValues(alpha: 0.5),
              ),
            ),
          ],

          const SizedBox(height: 16.0),

          // Luxe message
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: AurelianPalette.champagneGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    _rewardMessage ?? _getLuxeMessage(streak),
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF2A2A2A).withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          // Claim button
          GestureDetector(
            onTap: canCheckIn ? _claimCheckIn : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: canCheckIn
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: _isClaiming
                    ? const SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        canCheckIn ? 'CLAIM TODAY' : 'COME BACK TOMORROW',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: canCheckIn
                              ? Colors.white
                              : const Color(0xFF999999),
                        ),
                      ),
              ),
            ),
          ),

          // Reward animation
          if (_rewardMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF44AA44).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: const Color(0xFF44AA44).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF44AA44),
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        _rewardMessage!,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 12.0,
                          color: Color(0xFF44AA44),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.5, end: 0.0),
        ],
      ),
    );
  }

  Widget _buildStreakBar(int streak, int nextMilestone) {
    final double progress = streak / nextMilestone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8.0,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0
                  ? const Color(0xFF44AA44)
                  : AurelianPalette.champagneGold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: const SizedBox(
        height: 200.0,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
          ),
        ),
      ),
    );
  }

  int _getNextMilestone(int streak) {
    final List<int> milestones = <int>[1, 3, 7, 14, 30, 60, 100];
    for (final int m in milestones) {
      if (streak < m) return m;
    }
    return 100 + ((streak ~/ 100) * 100);
  }

  String _getLuxeMessage(int streak) {
    final List<String> messages = <String>[
      'You showed up. That is how every empire starts, darling.',
      'Two days of consistency. The rivals are watching.',
      'Three days in — rivals are already nervous. I can tell.',
      'Four days. The fashion world is beginning to notice.',
      'Five days. Your rhythm is forming.',
      'Six days. One more and you hit the week milestone.',
      'A week of consistency. The fashion world is watching.',
      'Eight days. The streak is becoming a statement.',
      'Nine days. Discipline is becoming reputation.',
      'Ten days. Double digits. That is commitment.',
      'Eleven days and counting. The empire is solidifying.',
      'Twelve days. Your rivals are taking notes.',
      'Thirteen days. Superstition says this is lucky. I say you earned it.',
      'Fourteen days. You are not a fluke — you are a force.',
      'Halfway to a month. That is longer than most careers in this industry.',
    ];

    if (streak < messages.length) {
      return messages[streak];
    }
    if (streak >= 30 && streak < 60) {
      return 'A month-plus streak. You have graduated from hopeful to inevitable.';
    }
    if (streak >= 60 && streak < 100) {
      return 'Two months of dominance. Legends are built in moments like this.';
    }
    if (streak >= 100) {
      return 'One hundred days. I have seen empires rise and fall. Yours is rising.';
    }
    return 'Welcome back, darling. The empire awaits.';
  }
}
