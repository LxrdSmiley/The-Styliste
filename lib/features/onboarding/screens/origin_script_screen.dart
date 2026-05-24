// GDD §1.1 Screen 2 — Origin Script
// 6-line poetic manifesto with typewriter effect.
// Micro-directive §2: ValueNotifier<String> drives only the active-line widget;
// Timer.periodic never calls setState on the Scaffold.
// Tap to skip current line; tap after all lines → Sovereign Registry.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Manifesto copy — GDD §1.1 Screen 2
// ---------------------------------------------------------------------------
const List<String> _kManifestoLines = <String>[
  'Every empire starts with a stitch.',
  'Every icon starts with a choice.',
  'The world doesn\'t remember the timid.',
  'It remembers the ones who dared to define it.',
  'You didn\'t come here to follow trends.',
  'You came here to set them.',
];

// Character emit interval.
const Duration _kCharInterval = Duration(milliseconds: 40);
// Pause between lines after a line completes.
const Duration _kLinePause = Duration(milliseconds: 400);
// Pause after tap-skip before advancing to next line.
const Duration _kSkipPause = Duration(milliseconds: 200);

class OriginScriptScreen extends ConsumerStatefulWidget {
  const OriginScriptScreen({super.key});

  @override
  ConsumerState<OriginScriptScreen> createState() => _OriginScriptScreenState();
}

class _OriginScriptScreenState extends ConsumerState<OriginScriptScreen> {
  // Completed lines — updated infrequently (at most 6 times total).
  final List<String> _completedLines = <String>[];

  // The line currently being typed — driven by ValueNotifier.
  // Only the ValueListenableBuilder watching this rebuilds at 40ms cadence.
  final ValueNotifier<String> _activeLineNotifier = ValueNotifier<String>('');

  int _currentLineIndex = 0;
  Timer? _typeTimer;
  bool _allLinesComplete = false;

  @override
  void initState() {
    super.initState();
    _startTypingLine(_currentLineIndex);
  }

  void _startTypingLine(int lineIndex) {
    if (lineIndex >= _kManifestoLines.length) {
      _onAllLinesComplete();
      return;
    }

    _activeLineNotifier.value = '';
    final String targetLine = _kManifestoLines[lineIndex];
    int charIndex = 0;

    _typeTimer = Timer.periodic(_kCharInterval, (Timer timer) {
      charIndex++;
      // Mutate notifier — only ValueListenableBuilder rebuilds, not Scaffold.
      _activeLineNotifier.value = targetLine.substring(0, charIndex);

      if (charIndex >= targetLine.length) {
        timer.cancel();
        _typeTimer = null;
        // Infrequent setState: advance completed lines list (at most 6 calls).
        Future<void>.delayed(_kLinePause, () {
          if (!mounted) return;
          setState(() {
            _completedLines.add(targetLine);
            _currentLineIndex++;
            _activeLineNotifier.value = '';
          });
          _startTypingLine(_currentLineIndex);
        });
      }
    });
  }

  void _onAllLinesComplete() {
    if (!mounted) return;
    setState(() => _allLinesComplete = true);
  }

  /// Tap handler: skip active line or advance to next screen.
  void _onTap() {
    if (_allLinesComplete) {
      context.go(AppRouter.onboardingSovereignRegistry);
      return;
    }

    final String targetLine = _kManifestoLines[_currentLineIndex];
    final bool lineInProgress = _activeLineNotifier.value != targetLine;

    if (lineInProgress) {
      // Skip to end of current line immediately.
      _typeTimer?.cancel();
      _typeTimer = null;
      _activeLineNotifier.value = targetLine;

      Future<void>.delayed(_kSkipPause, () {
        if (!mounted) return;
        setState(() {
          _completedLines.add(targetLine);
          _currentLineIndex++;
          _activeLineNotifier.value = '';
        });
        _startTypingLine(_currentLineIndex);
      });
    }
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _activeLineNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Scaffold(
        backgroundColor: AppColors.obsidian,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // --- Completed lines (static; never rebuild after being added) ---
                ..._completedLines.map(
                  (String line) => Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      line,
                      style: const TextStyle(
                        color: AppColors.ivory,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                // --- Active line (rebuilds every 40ms, isolated) ---
                if (!_allLinesComplete)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: ValueListenableBuilder<String>(
                      valueListenable: _activeLineNotifier,
                      builder: (BuildContext ctx, String value, Widget? _) {
                        return Text(
                          value,
                          style: const TextStyle(
                            color: AppColors.ivory,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w300,
                            height: 1.5,
                            letterSpacing: 0.3,
                          ),
                        );
                      },
                    ),
                  ),

                // --- Luxe prompt (appears after all lines complete) ---
                if (_allLinesComplete)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: const Text(
                      'Tap to continue, darling.',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 14.0,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.5,
                      ),
                    )
                        .animate(onPlay: (AnimationController c) => c.repeat())
                        .fadeIn(duration: const Duration(milliseconds: 600))
                        .then(delay: const Duration(milliseconds: 800))
                        .shimmer(
                          duration: const Duration(milliseconds: 1200),
                          color: AppColors.gold,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
