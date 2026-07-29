// GDD v8 §§8.2, 18.5–18.7 — Kingston Atelier exploration.
// Gate A ends at the server-authoritative capsule-readiness boundary.
//
// 5-second interaction gate:
//   _interactionSeconds increments ONLY while _touchActive == true.
//   Passive idle time in the Atelier does NOT count toward the gate.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_motion.dart';
import '../../../core/theme/styliste_radii.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/glass_metric_card.dart';
import '../../../core/widgets/pill_badge.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../../../domain/models/design.dart';
import '../../ftue/providers/first_objective_provider.dart';
import '../../trends/models/trend_tsunami.dart';
import '../../trends/providers/trend_provider.dart';
import '../constants/style_tags.dart';
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
  Color _selectedDye = StylisteColors.ivory;
  final Set<String> _selectedStyleTags = <String>{...kDefaultStyleTags};
  int _interactionSeconds = 0;
  bool _touchActive = false;
  Timer? _interactionTimer;

  static const int _gateSeconds = 5;

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
    });
  }

  void _onInteractionActive(bool active) {
    setState(() => _touchActive = active);
    if (active) {
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

  bool get _studyReady => _interactionSeconds >= _gateSeconds;

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
    final String draftName = _draftName(selectedTags);
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return AurelianScaffold(
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
                        reduceMotion: reduceMotion,
                      ),
                      const SizedBox(height: 12.0),
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
                        ready: _studyReady,
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
                      _AtelierReadinessPanel(
                        selectedTags: selectedTags,
                        fabricLabel: _fabricLabel(_selectedDye),
                        interactionSeconds: _interactionSeconds,
                        gateSeconds: _gateSeconds,
                        progress: progress,
                        ready: _studyReady,
                      ),
                      const SizedBox(height: 14.0),
                      AnimatedScale(
                        duration:
                            reduceMotion ? Duration.zero : StylisteMotion.micro,
                        scale: _studyReady ? 1.0 : 0.985,
                        child: SizedBox(
                          width: double.infinity,
                          child: GoldPrimaryButton(
                            label: _studyButtonLabel(),
                            icon: Icons.arrow_forward,
                            disabledReason: _studyReady
                                ? null
                                : 'Shape the garment for five active seconds before opening the capsule.',
                            onPressed: _studyReady
                                ? () => context.push(AppRouter.atelierCapsule)
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

  String _studyButtonLabel() {
    if (!_studyReady) return 'Shape the Garment';
    return 'Open Kingston Capsule';
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
    final Widget titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'AURELIAN STUDIO',
          style: StylisteText.labelCaps.copyWith(
            color: StylisteColors.textTertiary,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 5.0),
        Text(
          draftName.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: StylisteText.headline.copyWith(
            color: StylisteColors.textPrimary,
            fontSize: 24,
          ),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool stacked = constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                titleBlock,
                const SizedBox(height: StylisteSpacing.sm),
                _StudioCountPill(label: '${selectedTags.length}/3 SIGNALS'),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(child: titleBlock),
              const SizedBox(width: 12.0),
              _StudioCountPill(label: '${selectedTags.length}/3 SIGNALS'),
            ],
          );
        },
      ),
    );
  }
}

class _AtelierTopBar extends StatelessWidget {
  const _AtelierTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        StylisteSpacing.lg,
        StylisteSpacing.sm,
        StylisteSpacing.lg,
        StylisteSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'ATELIER',
              textAlign: TextAlign.center,
              style: StylisteText.labelCaps.copyWith(
                letterSpacing: 4,
                color: StylisteColors.textPrimary,
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
    required this.reduceMotion,
  });

  final bool hasInspiration;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return _StudioPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              PillBadge(
                label:
                    hasInspiration ? 'Inspiration Loaded' : 'Base Silhouette',
                icon: hasInspiration ? Icons.palette_outlined : Icons.checkroom,
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
          const SizedBox(height: StylisteSpacing.sm),
          const AurelianEvidenceBand(
            label: 'Study authority',
            value: 'Local garment exploration',
            detail:
                'This garment study stays local. Only the capsule submits bounded, authenticated intents.',
            icon: Icons.edit_note_outlined,
          ),
          const SizedBox(height: StylisteSpacing.sm),
          IvorySecondaryButton(
            label: 'Review study boundary',
            icon: Icons.info_outline,
            onPressed: () => _showStudyBoundary(context),
          ),
        ],
      ),
    );
  }
}

void _showStudyBoundary(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          StylisteSpacing.lg,
          StylisteSpacing.lg,
          StylisteSpacing.lg,
          StylisteSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const AurelianStatePanel(
          kind: AurelianStateKind.editing,
          title: 'This study stays in the Atelier',
          message:
              'Dye, drape interaction, and style signals help you read the garment. They do not create a score, reward, release, or authoritative blueprint.',
          authorityLabel: 'Local editor state',
          preservationLabel:
              'The study remains visible while this Atelier route is retained.',
          retrySafetyLabel:
              'No server mutation is attached to this explanatory sheet.',
          compact: true,
        ),
      );
    },
  );
}

class _LockedToolNotice extends StatelessWidget {
  const _LockedToolNotice();

  @override
  Widget build(BuildContext context) {
    return const AurelianStatePanel(
      kind: AurelianStateKind.unavailable,
      title: 'Advanced studio tools are held',
      message:
          'AR try-on, generative styling, launch, and advanced cloth tools remain unavailable. Gate A stops at capsule readiness.',
      authorityLabel: 'Gate A feature registry',
      preservationLabel:
          'The local garment study and capsule remain available.',
      compact: true,
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
          reduceMotion ? Duration.zero : StylisteMotion.screenTransitionMin,
      curve: StylisteMotion.standardCurve,
      height: height,
      decoration: BoxDecoration(
        color: StylisteColors.alabaster,
        borderRadius: BorderRadius.circular(StylisteRadii.control),
        border: Border.all(
          color: ready
              ? StylisteColors.deepGold
              : StylisteColors.champagneGold.withValues(alpha: 0.72),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StylisteColors.deepGold.withValues(alpha: 0.18),
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
                    StylisteColors.ivory,
                    StylisteColors.champagneGold.withValues(alpha: 0.48),
                    StylisteColors.alabaster,
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
        color: StylisteColors.obsidian.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: StylisteColors.champagneGold.withValues(alpha: 0.46),
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
                  color: StylisteColors.ivory,
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
                  color: StylisteColors.champagneGold,
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
          Wrap(
            spacing: StylisteSpacing.sm,
            runSpacing: StylisteSpacing.xs,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              const _PanelTitle(label: 'STYLE SIGNALS'),
              Text(
                '${selectedTags.length}/3 SELECTED',
                style: const TextStyle(
                  color: StylisteColors.textSecondary,
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
              color: StylisteColors.textSecondary.withValues(alpha: 0.84),
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
      return 'Trend signal unavailable. Your local garment study is preserved.';
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: StylisteSpacing.minTapTarget,
            ),
            child: Center(
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
        ),
      ),
    );
  }
}

class _AtelierReadinessPanel extends StatelessWidget {
  const _AtelierReadinessPanel({
    required this.selectedTags,
    required this.fabricLabel,
    required this.interactionSeconds,
    required this.gateSeconds,
    required this.progress,
    required this.ready,
  });

  final List<String> selectedTags;
  final String fabricLabel;
  final int interactionSeconds;
  final int gateSeconds;
  final double progress;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return _StudioPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: StylisteSpacing.sm,
            runSpacing: StylisteSpacing.xs,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              const _PanelTitle(label: 'GARMENT STUDY'),
              AnimatedOpacity(
                duration: StylisteMotion.resolve(
                  context,
                  StylisteMotion.micro,
                ),
                opacity: ready ? 1.0 : 0.52,
                child: PillBadge(
                  label: ready ? 'Study Ready' : 'Shape in Progress',
                  icon: ready ? Icons.check : Icons.touch_app,
                  mode: StylisteVisualMode.atelierWarmStudio,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool oneColumn =
                  MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
                      constraints.maxWidth < 300;
              final double width = oneColumn
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 16) / 3;
              return Wrap(
                spacing: StylisteSpacing.sm,
                runSpacing: StylisteSpacing.sm,
                children: <Widget>[
                  SizedBox(
                    width: width,
                    child: GlassMetricCard(
                      label: 'Fabric',
                      value: fabricLabel.toUpperCase(),
                      mode: StylisteVisualMode.atelierWarmStudio,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: GlassMetricCard(
                      label: 'Style',
                      value: '${selectedTags.length}/3',
                      mode: StylisteVisualMode.atelierWarmStudio,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: GlassMetricCard(
                      label: 'Active drape',
                      value: '$interactionSeconds/$gateSeconds S',
                      mode: StylisteVisualMode.atelierWarmStudio,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.0),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5.0,
              backgroundColor:
                  StylisteColors.champagneGold.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                ready ? StylisteColors.deepGold : StylisteColors.roseAccent,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          AurelianStatePanel(
            kind:
                ready ? AurelianStateKind.confirmed : AurelianStateKind.editing,
            title: ready
                ? 'Your visual study is ready'
                : 'Keep shaping the garment',
            message: ready
                ? 'These choices remain a local study. The Kingston capsule uses its own validated brief and three canonical look roles.'
                : 'Move across the garment to inspect its drape. No Hype, reward, or release result is calculated here.',
            authorityLabel:
                ready ? 'Local study completion' : 'Local editor state',
            preservationLabel:
                'Dye, style signals, and active-drape progress on this retained route.',
            retrySafetyLabel:
                'Opening the capsule starts no release, reward, or score request.',
            compact: true,
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
        color: StylisteColors.champagneGold.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: StylisteColors.deepGold.withValues(alpha: 0.34),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.palette_outlined,
            color: StylisteColors.textPrimary,
            size: 16.0,
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'INSPIRATION LOADED: ${sourceName.toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: StylisteColors.textPrimary,
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
        color: StylisteColors.alabaster,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: StylisteColors.champagneGold.withValues(alpha: 0.64),
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
        color: StylisteColors.textTertiary,
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

class _StudioDraftingPainter extends CustomPainter {
  const _StudioDraftingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = StylisteColors.deepGold.withValues(alpha: 0.16)
      ..strokeWidth = 1.0;

    for (double x = 42.0; x < size.width; x += 42.0) {
      canvas.drawLine(Offset(x, 0.0), Offset(x, size.height), line);
    }
    for (double y = 42.0; y < size.height; y += 42.0) {
      canvas.drawLine(Offset(0.0, y), Offset(size.width, y), line);
    }

    final Paint arc = Paint()
      ..color = StylisteColors.roseAccent.withValues(alpha: 0.18)
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
          StylisteColors.champagneGold.withValues(
            alpha: ready ? 0.42 : 0.26,
          ),
          StylisteColors.champagneGold.withValues(alpha: 0.0),
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
          (Color.lerp(fabricColor, StylisteColors.obsidian, 0.18) ??
                  fabricColor)
              .withValues(alpha: 0.72),
          StylisteColors.deepGold.withValues(alpha: 0.72),
        ],
      ).createShader(mannequin.getBounds());
    canvas.drawPath(mannequin, fabric);

    final Paint edge = Paint()
      ..color = StylisteColors.ivory.withValues(alpha: 0.76)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawPath(mannequin, edge);

    final Paint stand = Paint()
      ..color = StylisteColors.obsidian.withValues(alpha: 0.34)
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
      ..color = StylisteColors.obsidian.withValues(alpha: 0.22)
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
    return StylisteColors.ivory;
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
