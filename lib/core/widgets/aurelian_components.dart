import 'package:flutter/material.dart';

import '../theme/styliste_colors.dart';
import '../theme/styliste_motion.dart';
import '../theme/styliste_radii.dart';
import '../theme/styliste_spacing.dart';
import '../theme/styliste_typography.dart';
import '../theme/styliste_visual_mode.dart';
import 'styliste_buttons.dart';

enum AurelianStateKind {
  loading,
  empty,
  offline,
  retryableError,
  terminalError,
  confirmed,
  restored,
  permissionDenied,
  sessionExpired,
  maintenance,
  disabled,
  unavailable,
}

class AurelianContextualAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AurelianContextualAppBar({
    required this.title,
    this.eyebrow,
    this.leading,
    this.actions = const <Widget>[],
    super.key,
  });

  final String title;
  final String? eyebrow;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Size get preferredSize => Size.fromHeight(eyebrow == null ? 64 : 76);

  @override
  Widget build(BuildContext context) {
    final Color foreground = Theme.of(context).colorScheme.onSurface;
    return AppBar(
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: leading == null,
      leading: leading,
      titleSpacing: leading == null ? StylisteSpacing.lg : 0,
      title: Semantics(
        header: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (eyebrow != null) ...<Widget>[
              Text(
                eyebrow!.toUpperCase(),
                style: StylisteText.labelCaps.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: StylisteSpacing.xxs),
            ],
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: StylisteText.title.copyWith(color: foreground),
            ),
          ],
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class AurelianCard extends StatelessWidget {
  const AurelianCard({
    required this.child,
    this.padding = const EdgeInsets.all(StylisteSpacing.md),
    this.emphasized = false,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool emphasized;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized ? colors.primaryContainer : colors.surface,
        borderRadius: BorderRadius.circular(StylisteRadii.card),
        border: Border.all(
          color: emphasized ? colors.primary : colors.outlineVariant,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.09),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
    if (semanticLabel != null) {
      card = Semantics(
        container: true,
        label: semanticLabel,
        child: card,
      );
    }
    return card;
  }
}

class AurelianSectionHeader extends StatelessWidget {
  const AurelianSectionHeader({
    required this.title,
    this.eyebrow,
    this.detail,
    this.trailing,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String? detail;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (eyebrow != null) ...<Widget>[
                  Text(
                    eyebrow!.toUpperCase(),
                    style: StylisteText.labelCaps.copyWith(
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: StylisteSpacing.xs),
                ],
                Text(
                  title,
                  style: StylisteText.headline.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                if (detail != null) ...<Widget>[
                  const SizedBox(height: StylisteSpacing.xs),
                  Text(
                    detail!,
                    style: StylisteText.body.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: StylisteSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class AurelianStatusChip extends StatelessWidget {
  const AurelianStatusChip({
    required this.label,
    required this.icon,
    this.tone = AurelianStatusTone.neutral,
    super.key,
  });

  final String label;
  final IconData icon;
  final AurelianStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (tone) {
      AurelianStatusTone.neutral => Theme.of(context).colorScheme.primary,
      AurelianStatusTone.positive => StylisteColors.profitGreen,
      AurelianStatusTone.warning => StylisteColors.warningAmber,
      AurelianStatusTone.danger => StylisteColors.rivalRed,
    };
    return Semantics(
      label: label,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: StylisteSpacing.minTapTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: StylisteSpacing.sm,
          vertical: StylisteSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(StylisteRadii.pill),
          border: Border.all(color: color.withValues(alpha: 0.72)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: StylisteSpacing.iconSm, color: color),
            const SizedBox(width: StylisteSpacing.xs),
            Flexible(
              child: Text(
                label.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: StylisteText.labelCaps.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum AurelianStatusTone { neutral, positive, warning, danger }

class AurelianStatePanel extends StatelessWidget {
  const AurelianStatePanel({
    required this.kind,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.compact = false,
    super.key,
  });

  final AurelianStateKind kind;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final _StatePresentation presentation = _presentation(kind, context);
    final bool isLive = kind != AurelianStateKind.empty &&
        kind != AurelianStateKind.disabled &&
        kind != AurelianStateKind.unavailable;
    return Semantics(
      container: true,
      liveRegion: isLive,
      label: '${presentation.semanticPrefix}. $title. $message',
      child: AurelianCard(
        emphasized: kind == AurelianStateKind.confirmed ||
            kind == AurelianStateKind.restored,
        padding: EdgeInsets.all(
          compact ? StylisteSpacing.md : StylisteSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (kind == AurelianStateKind.loading)
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox.square(
                  dimension: StylisteSpacing.iconLg,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: presentation.color,
                  ),
                ),
              )
            else
              Icon(
                presentation.icon,
                color: presentation.color,
                size: StylisteSpacing.iconLg,
                semanticLabel: presentation.semanticPrefix,
              ),
            const SizedBox(height: StylisteSpacing.md),
            Text(
              title,
              style: StylisteText.title.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: StylisteSpacing.xs),
            Text(
              message,
              style: StylisteText.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: StylisteSpacing.lg),
              GoldPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                icon: presentation.actionIcon,
              ),
            ],
            if (secondaryActionLabel != null) ...<Widget>[
              const SizedBox(height: StylisteSpacing.xs),
              IvorySecondaryButton(
                label: secondaryActionLabel!,
                onPressed: onSecondaryAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LuxeGuidanceCard extends StatelessWidget {
  const LuxeGuidanceCard({
    required this.message,
    this.contextLabel = 'Luxe guidance',
    this.mode = StylisteVisualMode.editorialLight,
    super.key,
  });

  final String message;
  final String contextLabel;
  final StylisteVisualMode mode;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$contextLabel. $message',
      child: AurelianCard(
        emphasized: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: StylisteSpacing.minTapTarget,
              height: StylisteSpacing.minTapTarget,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: mode.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(StylisteRadii.control),
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                color: mode.accent,
                semanticLabel: 'Luxe',
              ),
            ),
            const SizedBox(width: StylisteSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    contextLabel.toUpperCase(),
                    style: StylisteText.labelCaps.copyWith(
                      color: mode.accent,
                    ),
                  ),
                  const SizedBox(height: StylisteSpacing.xs),
                  Text(
                    message,
                    style: StylisteText.bodyLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AurelianReceiptPanel extends StatelessWidget {
  const AurelianReceiptPanel({
    required this.title,
    required this.receiptId,
    required this.restored,
    this.detail,
    super.key,
  });

  final String title;
  final String receiptId;
  final bool restored;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return AurelianCard(
      semanticLabel:
          '${restored ? 'Restored' : 'Confirmed'} receipt. $title. $receiptId',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AurelianStatusChip(
            label: restored ? 'Restored' : 'Confirmed',
            icon: restored ? Icons.restore : Icons.verified_outlined,
            tone: AurelianStatusTone.positive,
          ),
          const SizedBox(height: StylisteSpacing.md),
          Text(title, style: StylisteText.title),
          const SizedBox(height: StylisteSpacing.xs),
          SelectableText(
            receiptId,
            style: StylisteText.metricSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (detail != null) ...<Widget>[
            const SizedBox(height: StylisteSpacing.xs),
            Text(detail!, style: StylisteText.body),
          ],
        ],
      ),
    );
  }
}

class AurelianResponsiveBody extends StatelessWidget {
  const AurelianResponsiveBody({
    required this.child,
    this.maxWidth = 640,
    this.bottomPadding = StylisteSpacing.xl,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: StylisteSpacing.md,
            bottom: bottomPadding + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class AurelianMotionSwap extends StatelessWidget {
  const AurelianMotionSwap({
    required this.child,
    required this.identity,
    super.key,
  });

  final Widget child;
  final Object identity;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: StylisteMotion.resolve(context, StylisteMotion.microMax),
      switchInCurve: StylisteMotion.standardCurve,
      switchOutCurve: StylisteMotion.standardCurve,
      child: KeyedSubtree(key: ValueKey<Object>(identity), child: child),
    );
  }
}

_StatePresentation _presentation(
  AurelianStateKind kind,
  BuildContext context,
) {
  return switch (kind) {
    AurelianStateKind.loading => _StatePresentation(
        Icons.hourglass_top,
        Theme.of(context).colorScheme.primary,
        'Loading',
        Icons.refresh,
      ),
    AurelianStateKind.empty => _StatePresentation(
        Icons.inbox_outlined,
        Theme.of(context).colorScheme.primary,
        'Empty state',
        Icons.add,
      ),
    AurelianStateKind.offline => const _StatePresentation(
        Icons.cloud_off_outlined,
        StylisteColors.warningAmber,
        'Offline',
        Icons.refresh,
      ),
    AurelianStateKind.retryableError => const _StatePresentation(
        Icons.sync_problem_outlined,
        StylisteColors.warningAmber,
        'Retryable error',
        Icons.refresh,
      ),
    AurelianStateKind.terminalError => const _StatePresentation(
        Icons.error_outline,
        StylisteColors.rivalRed,
        'Error',
        Icons.support_agent_outlined,
      ),
    AurelianStateKind.confirmed => const _StatePresentation(
        Icons.verified_outlined,
        StylisteColors.profitGreen,
        'Confirmed',
        Icons.arrow_forward,
      ),
    AurelianStateKind.restored => const _StatePresentation(
        Icons.restore,
        StylisteColors.profitGreen,
        'Restored',
        Icons.arrow_forward,
      ),
    AurelianStateKind.permissionDenied => const _StatePresentation(
        Icons.lock_outline,
        StylisteColors.rivalRed,
        'Permission denied',
        Icons.arrow_back,
      ),
    AurelianStateKind.sessionExpired => const _StatePresentation(
        Icons.timer_off_outlined,
        StylisteColors.warningAmber,
        'Session expired',
        Icons.refresh,
      ),
    AurelianStateKind.maintenance => const _StatePresentation(
        Icons.construction_outlined,
        StylisteColors.warningAmber,
        'Maintenance',
        Icons.refresh,
      ),
    AurelianStateKind.disabled => _StatePresentation(
        Icons.block_outlined,
        Theme.of(context).colorScheme.outline,
        'Disabled',
        Icons.info_outline,
      ),
    AurelianStateKind.unavailable => _StatePresentation(
        Icons.lock_clock_outlined,
        Theme.of(context).colorScheme.primary,
        'Unavailable',
        Icons.arrow_back,
      ),
  };
}

class _StatePresentation {
  const _StatePresentation(
    this.icon,
    this.color,
    this.semanticPrefix,
    this.actionIcon,
  );

  final IconData icon;
  final Color color;
  final String semanticPrefix;
  final IconData actionIcon;
}
