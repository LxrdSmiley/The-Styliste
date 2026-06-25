import 'package:flutter/material.dart';

import '../theme/styliste_colors.dart';
import '../theme/styliste_motion.dart';
import '../theme/styliste_radii.dart';
import '../theme/styliste_spacing.dart';
import '../theme/styliste_visual_mode.dart';

class GlassMetricCard extends StatelessWidget {
  const GlassMetricCard({
    required this.label,
    required this.value,
    this.delta,
    this.mode = StylisteVisualMode.editorialLight,
    this.isLoading = false,
    this.error,
    super.key,
  });

  final String label;
  final String value;
  final String? delta;
  final StylisteVisualMode mode;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: StylisteMotion.micro,
      curve: StylisteMotion.standardCurve,
      width: double.infinity,
      padding: const EdgeInsets.all(StylisteSpacing.gutter),
      decoration: BoxDecoration(
        color: mode.surface,
        borderRadius: BorderRadius.circular(StylisteRadii.card),
        border: Border.all(
          color: mode.accent.withValues(alpha: mode.isDark ? 0.34 : 0.24),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: StylisteColors.deepGold.withValues(alpha: 0.08),
            blurRadius: 24.0,
            offset: const Offset(0.0, 12.0),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: StylisteMotion.micro,
        child: _content(),
      ),
    );
  }

  Widget _content() {
    if (isLoading) {
      return const _MetricLoadingState(
        key: ValueKey<String>('glass-metric-loading'),
      );
    }

    if (error != null) {
      return _MetricErrorState(
        key: const ValueKey<String>('glass-metric-error'),
        message: error!,
        mode: mode,
      );
    }

    return _MetricValueState(
      key: const ValueKey<String>('glass-metric-value'),
      label: label,
      value: value,
      delta: delta,
      mode: mode,
    );
  }
}

class _MetricLoadingState extends StatelessWidget {
  const _MetricLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _SkeletonLine(width: 92.0, height: 10.0),
        SizedBox(height: StylisteSpacing.stackMd),
        _SkeletonLine(width: 136.0, height: 26.0),
        SizedBox(height: StylisteSpacing.stackSm),
        _SkeletonLine(width: 72.0, height: 10.0),
      ],
    );
  }
}

class _MetricErrorState extends StatelessWidget {
  const _MetricErrorState({
    required this.message,
    required this.mode,
    super.key,
  });

  final String message;
  final StylisteVisualMode mode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(Icons.error_outline, color: mode.danger, size: 18.0),
        const SizedBox(width: StylisteSpacing.stackSm),
        Expanded(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: mode.text,
              fontFamily: 'SpaceGrotesk',
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricValueState extends StatelessWidget {
  const _MetricValueState({
    required this.label,
    required this.value,
    required this.mode,
    this.delta,
    super.key,
  });

  final String label;
  final String value;
  final String? delta;
  final StylisteVisualMode mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: mode.secondaryText,
            fontFamily: 'SpaceGrotesk',
            fontSize: 10.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: StylisteSpacing.stackSm),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: mode.text,
            fontFamily: 'JetBrainsMono',
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (delta != null) ...<Widget>[
          const SizedBox(height: StylisteSpacing.stackSm),
          Text(
            delta!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: mode.profit,
              fontFamily: 'JetBrainsMono',
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: StylisteColors.textSecondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(StylisteRadii.pill),
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}
