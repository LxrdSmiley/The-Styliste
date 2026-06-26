// GDD v6 section 2, 4, 4.1 - Aurelian Studio Atelier pass.
// Visual/gameplay clarity only: mint and drop remain server-authoritative.
//
// 5-second interaction gate:
//   _interactionSeconds increments ONLY while _touchActive == true.
//   Passive idle time in the Atelier does NOT count toward the gate.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/aurelian_theme.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/glass_metric_card.dart';
import '../../../core/widgets/gold_primary_button.dart';
import '../../../core/widgets/pill_badge.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../../../domain/models/design.dart';
import '../../design/services/hype_calculator.dart';
import '../../ftue/providers/first_objective_provider.dart';
import '../../luxe/widgets/luxe_recovery_card.dart';
import '../../trends/models/trend_tsunami.dart';
import '../../trends/providers/trend_provider.dart';
import '../constants/style_tags.dart';
import '../providers/mint_design_provider.dart';
import '../widgets/fabric_swatch_panel.dart';
import '../widgets/garment_canvas.dart';

class AtelierScreen extends ConsumerStatefulWidget {
  const AtelierScreen({
    this.inspirationDesign,
    this.prepareSessionOnStart = true,
    super.key,
  });

  final Design? inspirationDesign;
  final bool prepareSessionOnStart;

  @override
  ConsumerState<AtelierScreen> createState() => _AtelierScreenState();
}

class _AtelierScreenState extends ConsumerState<AtelierScreen> {
  Color _selectedDye = AppColors.ivory;
  final Set<String> _selectedStyleTags = <String>{...kDefaultStyleTags};
  int _interactionSeconds = 0;
  bool _touchActive = false;
  bool _isMinting = false;
  String? _atelierSessionId;
  bool _showSessionRecovery = false;
  bool _showMintRecovery = false;
  Future<String>? _atelierSessionFuture;
  Timer? _interactionTimer;

  static const int _gateSeconds = 5;
  static const double _previewMaterialQualityHeuristic = 65.0;
  static const double _previewAestheticAlignmentHeuristic = 72.0;
  static const String _atelierRecoveryMessage =
      'The Atelier lost the thread. Your choices are still here.';
  static const HypeCalculator _hypeCalculator = HypeCalculator();

  @override
  void initState() {
    super.initState();

    final Design? inspiration = widget.inspirationDesign;
    if (inspiration != null) {
      _selectedDye = _hexToColor(
        inspiration.fabricData['color_hex'] as String? ?? 'FAF7F0',
      );
      final List<String> inspirationTags = _readStyleTags(inspiration);
      if (inspirationTags.isNotEmpty) {
        _selectedStyleTags
          ..clear()
          ..addAll(inspirationTags.take(3));
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(firstObjectiveActionsProvider.notifier).markAtelierOpened();
      if (widget.prepareSessionOnStart) {
        unawaited(_prepareAtelierSession());
      }
    });
  }

  Future<void> _prepareAtelierSession() async {
    if (_atelierSessionId != null || !mounted) return;
    final Future<String>? existingFuture = _atelierSessionFuture;
    if (existingFuture != null) {
      try {
        await existingFuture;
      } catch (_) {
        // The request owner presents the player-safe session error.
      }
      return;
    }
    final Future<String> sessionFuture = startAtelierSession(
      fabricColorHex: _selectedFabricHex,
      styleTags: _selectedStyleTags.toList(growable: false),
    );
    setState(() {
      _atelierSessionFuture = sessionFuture;
      _showSessionRecovery = false;
    });
    try {
      final String sessionId = await sessionFuture;
      if (mounted) {
        setState(() {
          _atelierSessionId = sessionId;
          _showSessionRecovery = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _showSessionRecovery = true);
      }
    } finally {
      if (identical(_atelierSessionFuture, sessionFuture)) {
        _atelierSessionFuture = null;
      }
    }
  }

  void _onInteractionActive(bool active) {
    setState(() => _touchActive = active);
    if (active) {
      unawaited(_prepareAtelierSession());
      _interactionTimer ??= Timer.periodic(
        const Duration(seconds: 1),
        (Timer _) {
          if (!mounted) return;
          if (!_touchActive) return;
          if (_interactionSeconds < _gateSeconds) {
            setState(() => _interactionSeconds++);
          }
        },
      );
    } else {
      _interactionTimer?.cancel();
      _interactionTimer = null;
    }
  }

  bool get _mintUnlocked => _interactionSeconds >= _gateSeconds;

  String get _selectedFabricHex => _colorToHex(_selectedDye);

  void _onTagToggle(String tag) {
    setState(() {
      if (_selectedStyleTags.contains(tag)) {
        if (_selectedStyleTags.length > 1) {
          _selectedStyleTags.remove(tag);
        }
        return;
      }
      if (_selectedStyleTags.length < 3) {
        _selectedStyleTags.add(tag);
      }
    });
  }

  Future<void> _onMintAlpha() async {
    if (_isMinting || !_mintUnlocked) return;
    setState(() {
      _isMinting = true;
      _showMintRecovery = false;
    });

    try {
      await _prepareAtelierSession();
      final String? sessionId = _atelierSessionId;
      if (sessionId == null) {
        throw StateError('atelier session missing');
      }
      final Design design = await ref.read(
        mintDesignProvider(
          MintDesignInput(
            sessionId: sessionId,
            fabricColorHex: _selectedFabricHex,
            styleTags: _selectedStyleTags.toList(growable: false),
          ),
        ).future,
      );
      if (mounted) {
        setState(() => _isMinting = false);
        unawaited(
          context.push(
            AppRouter.atelierDropPreview,
            extra: design,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isMinting = false;
          _showMintRecovery = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _interactionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> selectedTags =
        _selectedStyleTags.toList(growable: false);
    final double progress =
        (_interactionSeconds / _gateSeconds).clamp(0.0, 1.0).toDouble();
    final AsyncValue<List<TrendTsunami>> activeTsunamis =
        ref.watch(activeTsunamiProvider);
    final _HypeProjection projection = _projectHype(
      selectedTags: selectedTags,
      activeTsunamis: activeTsunamis,
    );
    final String draftName = _draftName(selectedTags);
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final bool serverSyncPending =
        _atelierSessionFuture != null && _atelierSessionId == null;

    return StylisteScaffold(
      mode: StylisteVisualMode.atelierWarmStudio,
      useSafeArea: false,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const _AtelierTopBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double stageHeight = (constraints.maxHeight * 0.48)
                      .clamp(320.0, 430.0)
                      .toDouble();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 28.0),
                    children: <Widget>[
                      _AtelierStatePanel(
                        hasInspiration: widget.inspirationDesign != null,
                        serverSyncPending: serverSyncPending,
                        sessionRecoveryVisible: _showSessionRecovery,
                        reduceMotion: reduceMotion,
                      ),
                      const SizedBox(height: 12.0),
                      if (_showSessionRecovery) ...<Widget>[
                        LuxeRecoveryCard(
                          title: 'Atelier Recovery',
                          message: _atelierRecoveryMessage,
                          primaryLabel: 'Retry Sync',
                          onPrimary: () => unawaited(
                            _prepareAtelierSession(),
                          ),
                          icon: Icons.wifi_off_outlined,
                        ),
                        const SizedBox(height: 12.0),
                      ],
                      if (widget.inspirationDesign != null)
                        _InspirationBanner(design: widget.inspirationDesign!),
                      _StudioHeader(
                        draftName: draftName,
                        selectedTags: selectedTags,
                      ),
                      const SizedBox(height: 12.0),
                      _StudioStage(
                        height: stageHeight,
                        dyeColor: _selectedDye,
                        fabricLabel: _fabricLabel(_selectedDye),
                        draftName: draftName,
                        selectedTags: selectedTags,
                        ready: _mintUnlocked,
                        reduceMotion: reduceMotion,
                        onInteractionActive: _onInteractionActive,
                      ),
                      const SizedBox(height: 16.0),
                      FabricSwatchPanel(
                        selectedColor: _selectedDye,
                        onSwatchSelected: (Color color) {
                          setState(() => _selectedDye = color);
                        },
                      ),
                      const SizedBox(height: 12.0),
                      const _LockedToolNotice(),
                      const SizedBox(height: 16.0),
                      _StyleSignalPanel(
                        selectedTags: selectedTags,
                        onTagToggle: _onTagToggle,
                        activeTsunamis: activeTsunamis,
                      ),
                      const SizedBox(height: 16.0),
                      _MintReadinessPanel(
                        selectedTags: selectedTags,
                        fabricLabel: _fabricLabel(_selectedDye),
                        interactionSeconds: _interactionSeconds,
                        gateSeconds: _gateSeconds,
                        progress: progress,
                        projection: projection,
                        ready: _mintUnlocked,
                      ),
                      if (_showMintRecovery) ...<Widget>[
                        const SizedBox(height: 14.0),
                        LuxeRecoveryCard(
                          title: 'Mint Recovery',
                          message: _atelierRecoveryMessage,
                          primaryLabel: 'Try Mint Again',
                          onPrimary: _onMintAlpha,
                          secondaryLabel: 'Keep Designing',
                          onSecondary: () =>
                              setState(() => _showMintRecovery = false),
                          icon: Icons.auto_fix_high_outlined,
                        ),
                      ],
                      const SizedBox(height: 14.0),
                      AnimatedScale(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        scale: _mintUnlocked ? 1.0 : 0.985,
                        child: SizedBox(
                          width: double.infinity,
                          child: GoldPrimaryButton(
                            label: _mintButtonLabel(serverSyncPending),
                            isLoading: _isMinting,
                            onPressed: (_mintUnlocked && !_isMinting)
                                ? _onMintAlpha
                                : null,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mintButtonLabel(bool serverSyncPending) {
    if (_isMinting) return 'Minting Alpha';
    if (serverSyncPending) return 'Syncing Atelier';
    if (!_mintUnlocked) return 'Shape Fabric';
    return 'Mint Alpha';
  }

  String _draftName(List<String> selectedTags) {
    final Design? inspiration = widget.inspirationDesign;
    if (inspiration != null) {
      return inspiration.fabricData['inspiration_source_name'] as String? ??
          inspiration.name;
    }

    final String leadTag =
        selectedTags.isEmpty ? 'atelier' : selectedTags.first;
    return '${_fabricLabel(_selectedDye)} $leadTag study';
  }

  _HypeProjection _projectHype({
    required List<String> selectedTags,
    required AsyncValue<List<TrendTsunami>> activeTsunamis,
  }) {
    final List<TrendTsunami> waves = activeTsunamis.maybeWhen(
      data: (List<TrendTsunami> value) => value,
      orElse: () => <TrendTsunami>[],
    );
    try {
      final HypeCalculationResult result = _hypeCalculator.calculate(
        input: HypeCalculationInput(
          styleTags: selectedTags,
          // Non-authoritative UI projection only.
          // Final Hype is calculated by the server mint/drop path.
          materialQuality: _previewMaterialQualityHeuristic,
          aestheticAlignment: _previewAestheticAlignmentHeuristic,
        ),
        activeTsunamis: waves,
      );

      return _HypeProjection(
        score: result.totalScore,
        multiplier: result.tsunamiMultiplier,
        matchingTag: result.matchingTsunamiTag,
        trendLoading: activeTsunamis.isLoading,
        trendUnavailable: activeTsunamis.hasError,
      );
    } catch (_) {
      return _HypeProjection(
        trendLoading: activeTsunamis.isLoading,
        trendUnavailable: true,
      );
    }
  }
}

class _StudioHeader extends StatelessWidget {
  const _StudioHeader({
    required this.draftName,
    required this.selectedTags,
  });

  final String draftName;
  final List<String> selectedTags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'AURELIAN STUDIO',
                  style: TextStyle(
                    color: AurelianPalette.textTertiary,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  draftName.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AurelianPalette.textPrimary,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                    height: 0.96,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          _StudioCountPill(label: '${selectedTags.length}/3 SIGNALS'),
        ],
      ),
    );
  }
}

class _AtelierTopBar extends StatelessWidget {
  const _AtelierTopBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'ATELIER',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 4.0,
                color: AurelianPalette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtelierStatePanel extends StatelessWidget {
  const _AtelierStatePanel({
    required this.hasInspiration,
    required this.serverSyncPending,
    required this.reduceMotion,
    required this.sessionRecoveryVisible,
  });

  final bool hasInspiration;
  final bool serverSyncPending;
  final bool reduceMotion;
  final bool sessionRecoveryVisible;

  @override
  Widget build(BuildContext context) {
    return _StudioPanel(
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          PillBadge(
            label: hasInspiration ? 'Inspiration Loaded' : 'Base Silhouette',
            icon: hasInspiration ? Icons.palette_outlined : Icons.checkroom,
            mode: StylisteVisualMode.atelierWarmStudio,
          ),
          if (serverSyncPending)
            const PillBadge(
              label: 'Server Sync Pending',
              icon: Icons.sync,
              mode: StylisteVisualMode.atelierWarmStudio,
            ),
          if (sessionRecoveryVisible)
            const PillBadge(
              label: 'Recovery Ready',
              icon: Icons.error_outline,
              mode: StylisteVisualMode.atelierWarmStudio,
            ),
          if (reduceMotion)
            const PillBadge(
              label: 'Reduced Motion',
              icon: Icons.motion_photos_off_outlined,
              mode: StylisteVisualMode.atelierWarmStudio,
            ),
        ],
      ),
    );
  }
}

class _LockedToolNotice extends StatelessWidget {
  const _LockedToolNotice();

  @override
  Widget build(BuildContext context) {
    return _StudioPanel(
      child: Row(
        children: <Widget>[
          const PillBadge(
            label: 'Later Build',
            icon: Icons.lock_outline,
            mode: StylisteVisualMode.atelierWarmStudio,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'AR try-on, AI texture suggestions, and advanced cloth lab tools '
              'remain locked. Current Alpha minting uses the server flow.',
              style: TextStyle(
                color: AurelianPalette.textSecondary.withValues(alpha: 0.84),
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioStage extends StatelessWidget {
  const _StudioStage({
    required this.height,
    required this.dyeColor,
    required this.fabricLabel,
    required this.draftName,
    required this.selectedTags,
    required this.ready,
    required this.reduceMotion,
    required this.onInteractionActive,
  });

  final double height;
  final Color dyeColor;
  final String fabricLabel;
  final String draftName;
  final List<String> selectedTags;
  final bool ready;
  final bool reduceMotion;
  final ValueChanged<bool> onInteractionActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: height,
      decoration: BoxDecoration(
        color: AurelianPalette.alabaster,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: ready
              ? AurelianPalette.champagneGoldDark
              : AurelianPalette.champagneGold.withValues(alpha: 0.72),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AurelianPalette.champagneGoldDark.withValues(alpha: 0.18),
            blurRadius: 28.0,
            offset: const Offset(0.0, 16.0),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AurelianPalette.ivory,
                    AurelianPalette.champagneGold.withValues(alpha: 0.48),
                    AurelianPalette.alabaster,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: GarmentCanvas(
              dyeColor: dyeColor,
              reduceMotion: reduceMotion,
              onInteractionActive: onInteractionActive,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _AtelierGarmentOverlayPainter(
                  fabricColor: dyeColor,
                  ready: ready,
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _StudioDraftingPainter()),
            ),
          ),
          const Positioned(
            left: 14.0,
            top: 14.0,
            child: IgnorePointer(
              child: _StagePill(label: 'CREATION IN PROGRESS'),
            ),
          ),
          Positioned(
            right: 14.0,
            top: 14.0,
            child: IgnorePointer(
              child: _StagePill(label: fabricLabel.toUpperCase()),
            ),
          ),
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: 14.0,
            child: IgnorePointer(
              child: _StageIdentity(
                draftName: draftName,
                selectedTags: selectedTags,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageIdentity extends StatelessWidget {
  const _StageIdentity({
    required this.draftName,
    required this.selectedTags,
  });

  final String draftName;
  final List<String> selectedTags;

  @override
  Widget build(BuildContext context) {
    final String tagLine = selectedTags.isEmpty
        ? 'NO TAGS SELECTED'
        : selectedTags.take(2).join(' / ').toUpperCase();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.obsidian.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.46),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                draftName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AurelianPalette.ivory,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Text(
                tagLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AurelianPalette.champagneGoldDark,
                  fontSize: 9.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleSignalPanel extends StatelessWidget {
  const _StyleSignalPanel({
    required this.selectedTags,
    required this.onTagToggle,
    required this.activeTsunamis,
  });

  final List<String> selectedTags;
  final ValueChanged<String> onTagToggle;
  final AsyncValue<List<TrendTsunami>> activeTsunamis;

  @override
  Widget build(BuildContext context) {
    final List<TrendTsunami> waves = activeTsunamis.maybeWhen(
      data: (List<TrendTsunami> value) => value,
      orElse: () => <TrendTsunami>[],
    );

    return _StudioPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: _PanelTitle(label: 'STYLE SIGNALS'),
              ),
              Text(
                '${selectedTags.length}/3 SELECTED',
                style: const TextStyle(
                  color: AurelianPalette.textSecondary,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            _trendLine(activeTsunamis, selectedTags, waves),
            style: TextStyle(
              color: AurelianPalette.textSecondary.withValues(alpha: 0.84),
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: kAvailableStyleTags.map((String tag) {
              final bool selected = selectedTags.contains(tag);
              final TrendTsunami? trend = waves.getMatchingTsunami(tag);
              return _StyleSignalChip(
                label: trend == null ? tag : '$tag ${trend.multiplierDisplay}',
                selected: selected,
                hasTrend: trend != null,
                onTap: () => onTagToggle(tag),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }

  String _trendLine(
    AsyncValue<List<TrendTsunami>> activeTsunamis,
    List<String> selectedTags,
    List<TrendTsunami> waves,
  ) {
    if (activeTsunamis.isLoading) {
      return 'Trend scan loading. Projection uses the current design brief.';
    }
    if (activeTsunamis.hasError) {
      return 'Trend signal unavailable. Minting still uses the server flow.';
    }

    for (final String tag in selectedTags) {
      final TrendTsunami? trend = waves.getMatchingTsunami(tag);
      if (trend != null) {
        return '${trend.tagName.toUpperCase()} is live at ${trend.multiplierDisplay} alignment.';
      }
    }
    return 'No selected signal is riding the live Trend Tsunami.';
  }
}

class _StyleSignalChip extends StatelessWidget {
  const _StyleSignalChip({
    required this.label,
    required this.selected,
    required this.hasTrend,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool hasTrend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Opacity(
        opacity: selected ? 1.0 : 0.58,
        child: InkWell(
          borderRadius: BorderRadius.circular(999.0),
          onTap: onTap,
          child: PillBadge(
            label: label,
            icon: selected
                ? Icons.check
                : hasTrend
                    ? Icons.auto_awesome
                    : null,
            mode: StylisteVisualMode.atelierWarmStudio,
          ),
        ),
      ),
    );
  }
}

class _MintReadinessPanel extends StatelessWidget {
  const _MintReadinessPanel({
    required this.selectedTags,
    required this.fabricLabel,
    required this.interactionSeconds,
    required this.gateSeconds,
    required this.progress,
    required this.projection,
    required this.ready,
  });

  final List<String> selectedTags;
  final String fabricLabel;
  final int interactionSeconds;
  final int gateSeconds;
  final double progress;
  final _HypeProjection projection;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return _StudioPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(child: _PanelTitle(label: 'MINT READINESS')),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: ready ? 1.0 : 0.52,
                child: PillBadge(
                  label: ready ? 'Ready' : 'In Progress',
                  icon: ready ? Icons.check : Icons.touch_app,
                  mode: StylisteVisualMode.atelierWarmStudio,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Row(
            children: <Widget>[
              Expanded(
                child: GlassMetricCard(
                  label: 'Fabric',
                  value: fabricLabel.toUpperCase(),
                  mode: StylisteVisualMode.atelierWarmStudio,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: GlassMetricCard(
                  label: 'Style',
                  value: '${selectedTags.length}/3',
                  mode: StylisteVisualMode.atelierWarmStudio,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: GlassMetricCard(
                  label: 'Drape',
                  value: '$interactionSeconds/$gateSeconds S',
                  mode: StylisteVisualMode.atelierWarmStudio,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.0),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.0,
              backgroundColor:
                  AurelianPalette.champagneGold.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                ready
                    ? AurelianPalette.champagneGoldDark
                    : AurelianPalette.softRose,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: GlassMetricCard(
                  label: 'Projected Hype',
                  value: projection.displayScore,
                  delta: 'Projection only',
                  mode: StylisteVisualMode.atelierWarmStudio,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: GlassMetricCard(
                  label: 'Trend Alignment',
                  value: projection.trendDisplay,
                  mode: StylisteVisualMode.atelierWarmStudio,
                  isLoading: projection.trendLoading,
                  error: projection.trendUnavailable
                      ? 'Trend signal unavailable'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Final hype is minted by the server after MINT ALPHA.',
            style: TextStyle(
              color: AurelianPalette.textTertiary,
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _InspirationBanner extends StatelessWidget {
  const _InspirationBanner({required this.design});

  final Design design;

  @override
  Widget build(BuildContext context) {
    final String sourceName =
        design.fabricData['inspiration_source_name'] as String? ?? design.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AurelianPalette.champagneGold.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AurelianPalette.champagneGoldDark.withValues(alpha: 0.34),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.palette_outlined,
            color: AurelianPalette.textPrimary,
            size: 16.0,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'INSPIRATION LOADED: ${sourceName.toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AurelianPalette.textPrimary,
                fontSize: 10.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioPanel extends StatelessWidget {
  const _StudioPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AurelianPalette.alabaster,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.64),
        ),
      ),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AurelianPalette.textTertiary,
        fontSize: 10.0,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
    );
  }
}

class _StudioCountPill extends StatelessWidget {
  const _StudioCountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return PillBadge(
      label: label,
      mode: StylisteVisualMode.atelierWarmStudio,
    );
  }
}

class _StagePill extends StatelessWidget {
  const _StagePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return PillBadge(
      label: label,
      mode: StylisteVisualMode.atelierWarmStudio,
    );
  }
}

class _HypeProjection {
  const _HypeProjection({
    this.score,
    this.multiplier = 1.0,
    this.matchingTag,
    this.trendLoading = false,
    this.trendUnavailable = false,
  });

  final double? score;
  final double multiplier;
  final String? matchingTag;
  final bool trendLoading;
  final bool trendUnavailable;

  String get displayScore {
    final double? current = score;
    return current == null ? 'UNAVAILABLE' : current.toStringAsFixed(1);
  }

  String get trendDisplay {
    if (trendUnavailable) return 'UNAVAILABLE';
    if (trendLoading) return 'SCANNING';
    final String? tag = matchingTag;
    if (tag == null || multiplier <= 1.0) return 'NO MATCH';
    return '${tag.toUpperCase()} ${multiplier.toStringAsFixed(1)}X';
  }
}

class _StudioDraftingPainter extends CustomPainter {
  const _StudioDraftingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = AurelianPalette.champagneGoldDark.withValues(alpha: 0.16)
      ..strokeWidth = 1.0;

    for (double x = 42.0; x < size.width; x += 42.0) {
      canvas.drawLine(Offset(x, 0.0), Offset(x, size.height), line);
    }
    for (double y = 42.0; y < size.height; y += 42.0) {
      canvas.drawLine(Offset(0.0, y), Offset(size.width, y), line);
    }

    final Paint arc = Paint()
      ..color = AurelianPalette.softRose.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.72,
        height: size.height * 0.86,
      ),
      -0.9,
      1.8,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _StudioDraftingPainter oldDelegate) => false;
}

class _AtelierGarmentOverlayPainter extends CustomPainter {
  const _AtelierGarmentOverlayPainter({
    required this.fabricColor,
    required this.ready,
  });

  final Color fabricColor;
  final bool ready;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2.0, size.height * 0.48);
    final Paint spotlight = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          AurelianPalette.champagneGold.withValues(alpha: ready ? 0.42 : 0.26),
          AurelianPalette.champagneGold.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: size.shortestSide * 0.48),
      );
    canvas.drawCircle(center, size.shortestSide * 0.48, spotlight);

    final Path mannequin = Path()
      ..moveTo(center.dx, size.height * 0.18)
      ..cubicTo(
        center.dx - 38.0,
        size.height * 0.22,
        center.dx - 50.0,
        size.height * 0.34,
        center.dx - 42.0,
        size.height * 0.42,
      )
      ..lineTo(center.dx - 76.0, size.height * 0.82)
      ..quadraticBezierTo(
        center.dx,
        size.height * 0.95,
        center.dx + 76.0,
        size.height * 0.82,
      )
      ..lineTo(center.dx + 42.0, size.height * 0.42)
      ..cubicTo(
        center.dx + 50.0,
        size.height * 0.34,
        center.dx + 38.0,
        size.height * 0.22,
        center.dx,
        size.height * 0.18,
      )
      ..close();

    final Paint fabric = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          fabricColor.withValues(alpha: 0.78),
          (Color.lerp(fabricColor, AppColors.obsidian, 0.18) ?? fabricColor)
              .withValues(alpha: 0.72),
          AurelianPalette.champagneGoldDark.withValues(alpha: 0.72),
        ],
      ).createShader(mannequin.getBounds());
    canvas.drawPath(mannequin, fabric);

    final Paint edge = Paint()
      ..color = AurelianPalette.ivory.withValues(alpha: 0.76)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawPath(mannequin, edge);

    final Paint stand = Paint()
      ..color = AppColors.obsidian.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(
        Offset(center.dx, size.height * 0.92),
        Offset(center.dx, size.height * 0.99),
        stand,
      )
      ..drawLine(
        Offset(center.dx - 42.0, size.height * 0.99),
        Offset(center.dx + 42.0, size.height * 0.99),
        stand,
      );

    final Paint stitch = Paint()
      ..color = AppColors.obsidian.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas
      ..drawLine(
        Offset(center.dx, size.height * 0.24),
        Offset(center.dx, size.height * 0.88),
        stitch,
      )
      ..drawLine(
        Offset(center.dx - 44.0, size.height * 0.48),
        Offset(center.dx + 44.0, size.height * 0.48),
        stitch,
      );
  }

  @override
  bool shouldRepaint(covariant _AtelierGarmentOverlayPainter oldDelegate) {
    return oldDelegate.fabricColor != fabricColor || oldDelegate.ready != ready;
  }
}

List<String> _readStyleTags(Design design) {
  final Object? rawTags = design.fabricData['style_tags'];
  if (rawTags is! List<Object?>) return kDefaultStyleTags;

  final List<String> tags = rawTags
      .map((Object? value) => value?.toString().trim() ?? '')
      .where((String tag) => tag.isNotEmpty)
      .take(3)
      .toList(growable: false);
  return tags.isEmpty ? kDefaultStyleTags : tags;
}

Color _hexToColor(String hex) {
  try {
    final String clean = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$clean', radix: 16));
  } catch (_) {
    return AppColors.ivory;
  }
}

String _colorToHex(Color color) {
  return color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
}

String _fabricLabel(Color color) {
  final String hex = _colorToHex(color).toUpperCase();
  return switch (hex) {
    'FAF7F0' => 'Ivory',
    '1C1C1C' => 'Noir',
    'C9A84C' => 'Gold',
    'C8FF00' => 'Lime',
    _ => 'Custom',
  };
}
