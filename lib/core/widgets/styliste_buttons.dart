import 'package:flutter/material.dart';

import '../theme/styliste_colors.dart';
import '../theme/styliste_radii.dart';
import '../theme/styliste_spacing.dart';
import '../theme/styliste_typography.dart';

enum StylisteButtonFeedback {
  neutral,
  success,
  error,
}

class GoldPrimaryButton extends StatelessWidget {
  const GoldPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.feedback = StylisteButtonFeedback.neutral,
    this.disabledReason,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final StylisteButtonFeedback feedback;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    return _StylisteButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      feedback: feedback,
      disabledReason: disabledReason,
      palette: _ButtonPalette.gold(),
      radius: StylisteRadii.card,
      padding: const EdgeInsets.symmetric(
        horizontal: StylisteSpacing.gutter,
        vertical: 14.0,
      ),
    );
  }
}

class ObsidianPrimaryButton extends StatelessWidget {
  const ObsidianPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.feedback = StylisteButtonFeedback.neutral,
    this.disabledReason,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final StylisteButtonFeedback feedback;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    return _StylisteButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      feedback: feedback,
      disabledReason: disabledReason,
      palette: _ButtonPalette.obsidian(),
      radius: StylisteRadii.card,
      padding: const EdgeInsets.symmetric(
        horizontal: StylisteSpacing.gutter,
        vertical: 14.0,
      ),
    );
  }
}

class IvorySecondaryButton extends StatelessWidget {
  const IvorySecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.feedback = StylisteButtonFeedback.neutral,
    this.disabledReason,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final StylisteButtonFeedback feedback;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    return _StylisteButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      feedback: feedback,
      disabledReason: disabledReason,
      palette: _ButtonPalette.ivory(),
      radius: StylisteRadii.card,
      padding: const EdgeInsets.symmetric(
        horizontal: StylisteSpacing.gutter,
        vertical: 14.0,
      ),
    );
  }
}

class PillChoiceButton extends StatelessWidget {
  const PillChoiceButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.selected = false,
    this.isLoading = false,
    this.feedback = StylisteButtonFeedback.neutral,
    this.disabledReason,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool selected;
  final bool isLoading;
  final StylisteButtonFeedback feedback;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    return _StylisteButton(
      label: label,
      onPressed: onPressed,
      icon: icon ?? (selected ? Icons.check : null),
      isLoading: isLoading,
      feedback: feedback,
      disabledReason: disabledReason,
      palette: selected ? _ButtonPalette.gold() : _ButtonPalette.ivory(),
      radius: StylisteRadii.pill,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
    );
  }
}

class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isLoading = false,
    this.feedback = StylisteButtonFeedback.neutral,
    this.disabledReason,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isLoading;
  final StylisteButtonFeedback feedback;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final _ResolvedButtonColors colors =
        _ButtonPalette.obsidian().resolve(feedback);
    final bool enabled = onPressed != null && !isLoading;

    return _DisabledHint(
      enabled: enabled,
      disabledReason: disabledReason,
      child: Tooltip(
        message: enabled ? tooltip : disabledReason ?? tooltip,
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(
            width: StylisteSpacing.minTapTarget,
            height: StylisteSpacing.minTapTarget,
          ),
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
            style: _circleStyle(colors),
            child: _LoadingContent(
              isLoading: isLoading,
              spinnerColor: colors.foreground,
              child: Icon(icon, size: 19.0),
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingReactionButton extends StatelessWidget {
  const FloatingReactionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.count,
    this.isLoading = false,
    this.feedback = StylisteButtonFeedback.neutral,
    this.disabledReason,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? count;
  final bool isLoading;
  final StylisteButtonFeedback feedback;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final String displayLabel = count == null ? label : '$label $count';
    return _StylisteButton(
      label: displayLabel,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      feedback: feedback,
      disabledReason: disabledReason,
      palette: _ButtonPalette.glass(),
      radius: StylisteRadii.pill,
      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 11.0),
    );
  }
}

class _StylisteButton extends StatelessWidget {
  const _StylisteButton({
    required this.label,
    required this.onPressed,
    required this.palette,
    required this.radius,
    required this.padding,
    required this.feedback,
    required this.isLoading,
    this.icon,
    this.disabledReason,
  });

  final String label;
  final VoidCallback? onPressed;
  final _ButtonPalette palette;
  final double radius;
  final EdgeInsetsGeometry padding;
  final StylisteButtonFeedback feedback;
  final bool isLoading;
  final IconData? icon;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final _ResolvedButtonColors colors = palette.resolve(feedback);
    final bool enabled = onPressed != null && !isLoading;
    final IconData? effectiveIcon = icon ??
        switch (feedback) {
          StylisteButtonFeedback.neutral => null,
          StylisteButtonFeedback.success => Icons.check,
          StylisteButtonFeedback.error => Icons.error_outline,
        };

    return _DisabledHint(
      enabled: enabled,
      disabledReason: disabledReason,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: StylisteSpacing.minTapTarget,
          minWidth: StylisteSpacing.minTapTarget,
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: _buttonStyle(colors, radius, padding),
          child: _LoadingContent(
            isLoading: isLoading,
            spinnerColor: colors.foreground,
            child: _ButtonLabel(label: label, icon: effectiveIcon),
          ),
        ),
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (icon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 17.0),
        const SizedBox(width: StylisteSpacing.stackSm),
        Flexible(child: text),
      ],
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent({
    required this.child,
    required this.isLoading,
    required this.spinnerColor,
  });

  final Widget child;
  final bool isLoading;
  final Color spinnerColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Opacity(opacity: isLoading ? 0.0 : 1.0, child: child),
        if (isLoading)
          SizedBox.square(
            dimension: 18.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: spinnerColor,
            ),
          ),
      ],
    );
  }
}

class _DisabledHint extends StatelessWidget {
  const _DisabledHint({
    required this.enabled,
    required this.child,
    this.disabledReason,
  });

  final bool enabled;
  final Widget child;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final String? reason = enabled ? null : disabledReason;
    if (reason == null) return child;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        child,
        const SizedBox(height: StylisteSpacing.stackSm),
        Text(
          reason,
          textAlign: TextAlign.center,
          style: StylisteText.bodySmall.copyWith(
            color: StylisteColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ButtonPalette {
  const _ButtonPalette({
    required this.background,
    required this.pressed,
    required this.foreground,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.border,
  });

  factory _ButtonPalette.gold() {
    return const _ButtonPalette(
      background: StylisteColors.champagneGold,
      pressed: StylisteColors.deepGold,
      foreground: StylisteColors.textPrimary,
      disabledBackground: StylisteColors.alabaster,
      disabledForeground: StylisteColors.textSecondary,
      border: StylisteColors.champagneGold,
    );
  }

  factory _ButtonPalette.obsidian() {
    return const _ButtonPalette(
      background: StylisteColors.obsidian,
      pressed: StylisteColors.obsidianSurface,
      foreground: StylisteColors.ivory,
      disabledBackground: StylisteColors.warmGrey,
      disabledForeground: StylisteColors.textSecondary,
      border: StylisteColors.obsidian,
    );
  }

  factory _ButtonPalette.ivory() {
    return const _ButtonPalette(
      background: StylisteColors.ivory,
      pressed: StylisteColors.alabaster,
      foreground: StylisteColors.textPrimary,
      disabledBackground: StylisteColors.alabaster,
      disabledForeground: StylisteColors.textSecondary,
      border: StylisteColors.outlineSubtle,
    );
  }

  factory _ButtonPalette.glass() {
    return const _ButtonPalette(
      background: StylisteColors.surfaceGlass,
      pressed: StylisteColors.alabaster,
      foreground: StylisteColors.textPrimary,
      disabledBackground: StylisteColors.alabaster,
      disabledForeground: StylisteColors.textSecondary,
      border: StylisteColors.outlineSubtle,
    );
  }

  final Color background;
  final Color pressed;
  final Color foreground;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color border;

  _ResolvedButtonColors resolve(StylisteButtonFeedback feedback) {
    return switch (feedback) {
      StylisteButtonFeedback.neutral => _ResolvedButtonColors(
          background: background,
          pressed: pressed,
          foreground: foreground,
          disabledBackground: disabledBackground,
          disabledForeground: disabledForeground,
          border: border,
        ),
      StylisteButtonFeedback.success => const _ResolvedButtonColors(
          background: StylisteColors.profitGreen,
          pressed: StylisteColors.profitGreen,
          foreground: StylisteColors.ivory,
          disabledBackground: StylisteColors.alabaster,
          disabledForeground: StylisteColors.textSecondary,
          border: StylisteColors.profitGreen,
        ),
      StylisteButtonFeedback.error => const _ResolvedButtonColors(
          background: StylisteColors.rivalRed,
          pressed: StylisteColors.rivalRed,
          foreground: StylisteColors.ivory,
          disabledBackground: StylisteColors.alabaster,
          disabledForeground: StylisteColors.textSecondary,
          border: StylisteColors.rivalRed,
        ),
    };
  }
}

class _ResolvedButtonColors {
  const _ResolvedButtonColors({
    required this.background,
    required this.pressed,
    required this.foreground,
    required this.disabledBackground,
    required this.disabledForeground,
    required this.border,
  });

  final Color background;
  final Color pressed;
  final Color foreground;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color border;
}

ButtonStyle _buttonStyle(
  _ResolvedButtonColors colors,
  double radius,
  EdgeInsetsGeometry padding,
) {
  return ButtonStyle(
    minimumSize: const WidgetStatePropertyAll<Size>(
      Size(StylisteSpacing.minTapTarget, StylisteSpacing.minTapTarget),
    ),
    padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(padding),
    elevation: const WidgetStatePropertyAll<double>(0.0),
    textStyle: const WidgetStatePropertyAll<TextStyle>(
      StylisteText.labelCaps,
    ),
    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledBackground;
        }
        if (states.contains(WidgetState.pressed)) return colors.pressed;
        return colors.background;
      },
    ),
    foregroundColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disabledForeground;
        }
        return colors.foreground;
      },
    ),
    overlayColor: WidgetStatePropertyAll<Color>(
      colors.foreground.withValues(alpha: 0.08),
    ),
    side: WidgetStatePropertyAll<BorderSide>(
      BorderSide(color: colors.border.withValues(alpha: 0.72)),
    ),
    shape: WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    ),
  );
}

ButtonStyle _circleStyle(_ResolvedButtonColors colors) {
  return _buttonStyle(
    colors,
    StylisteRadii.pill,
    EdgeInsets.zero,
  ).copyWith(
    shape: const WidgetStatePropertyAll<OutlinedBorder>(CircleBorder()),
  );
}
