// GDD v8 §§18, 21, 22 — accessibility, presentation, and legal controls.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../../legal/legal_documents.dart';
import '../../legal/screens/legal_document_screen.dart';

const String _kExpertModeKey = 'expert_mode_enabled';
const String _kReducedMotionKey = 'reduced_motion_enabled';
const String _kHighContrastKey = 'high_contrast_enabled';
const String _kTextScaleKey = 'accessibility_text_scale';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _expertMode = false;
  bool _reducedMotion = false;
  bool _highContrast = false;
  double _textScale = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _expertMode = prefs.getBool(_kExpertModeKey) ?? false;
      _reducedMotion = prefs.getBool(_kReducedMotionKey) ?? false;
      _highContrast = prefs.getBool(_kHighContrastKey) ?? false;
      _textScale = prefs.getDouble(_kTextScaleKey) ?? 1;
      _loading = false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _onExpertModeToggle(bool value) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(value ? 'Enable Expert Mode?' : 'Use guided presentation?'),
        content: Text(
          value
              ? 'Expert Mode reveals more explanatory variables. It does not change outcomes, scoring ceilings, or rewards.'
              : 'Guided presentation reduces information density. Server-owned rules remain identical.',
        ),
        actions: <Widget>[
          IvorySecondaryButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          GoldPrimaryButton(
            label: 'Confirm presentation',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    await _saveBool(_kExpertModeKey, value);
    if (mounted) setState(() => _expertMode = value);
  }

  Future<void> _toggleReducedMotion(bool value) async {
    await _saveBool(_kReducedMotionKey, value);
    if (mounted) setState(() => _reducedMotion = value);
  }

  Future<void> _toggleHighContrast(bool value) async {
    await _saveBool(_kHighContrastKey, value);
    if (mounted) setState(() => _highContrast = value);
  }

  Future<void> _setTextScale(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kTextScaleKey, value);
    if (mounted) setState(() => _textScale = value);
  }

  void _openLegalDocument(LegalDocument document) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            LegalDocumentScreen(document: document),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AurelianScaffold(
      mode: StylisteVisualMode.noirCinematic,
      appBar: AurelianContextualAppBar(
        eyebrow: 'House',
        title: 'Settings & Legal',
        leading: IconButton(
          tooltip: 'Return to House',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _loading
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: const AurelianStatePanel(
                  kind: AurelianStateKind.loading,
                  title: 'Restoring your preferences',
                  message:
                      'Reading local presentation and accessibility choices.',
                ),
              ),
            )
          : AurelianResponsiveBody(
              maxWidth: 620,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const AurelianSectionHeader(
                    eyebrow: 'Presentation',
                    title: 'Choose how much information you see',
                    detail:
                        'These controls change presentation only. They never change economic or progression authority.',
                  ),
                  const SizedBox(height: StylisteSpacing.md),
                  AurelianCard(
                    child: Column(
                      children: <Widget>[
                        _SettingsSwitch(
                          icon: Icons.analytics_outlined,
                          title: 'Expert Mode',
                          subtitle:
                              'Reveal more explanatory variables without changing outcomes.',
                          value: _expertMode,
                          onChanged: _onExpertModeToggle,
                        ),
                        const Divider(height: StylisteSpacing.lg),
                        _SettingsSwitch(
                          icon: Icons.motion_photos_off_outlined,
                          title: 'Reduced motion',
                          subtitle:
                              'Prefer restrained transitions and static visual fallbacks.',
                          value: _reducedMotion,
                          onChanged: _toggleReducedMotion,
                        ),
                        const Divider(height: StylisteSpacing.lg),
                        _SettingsSwitch(
                          icon: Icons.contrast_outlined,
                          title: 'High contrast',
                          subtitle:
                              'Use stronger local contrast where supported.',
                          value: _highContrast,
                          onChanged: _toggleHighContrast,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: StylisteSpacing.md),
                  AurelianCard(
                    semanticLabel:
                        'Text scale. Current ${(_textScale * 100).round()} percent.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _SettingTitle(
                          icon: Icons.text_fields,
                          title: 'Text scale preview',
                          subtitle:
                              'System text scaling remains authoritative; this stores an in-game preference for supported surfaces.',
                        ),
                        Slider(
                          value: _textScale,
                          min: 1,
                          max: 1.5,
                          divisions: 5,
                          label: '${(_textScale * 100).round()}%',
                          onChanged: (double value) =>
                              setState(() => _textScale = value),
                          onChangeEnd: _setTextScale,
                        ),
                        Text(
                          '${(_textScale * 100).round()}% preview',
                          textScaler: TextScaler.linear(_textScale),
                          style: StylisteText.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: StylisteSpacing.lg),
                  const AurelianSectionHeader(
                    eyebrow: 'Legal',
                    title: 'Alpha documents',
                    detail:
                        'Bundled review copies remain clearly separated from final counsel-approved launch text.',
                  ),
                  const SizedBox(height: StylisteSpacing.md),
                  ...LegalDocuments.all.map(
                    (LegalDocument document) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: StylisteSpacing.sm,
                      ),
                      child: _LegalDocumentTile(
                        document: document,
                        onTap: () => _openLegalDocument(document),
                      ),
                    ),
                  ),
                  const SizedBox(height: StylisteSpacing.md),
                  Text(
                    'THE STYLISTE  v0.1.0-alpha.1',
                    textAlign: TextAlign.center,
                    style: StylisteText.labelCaps.copyWith(
                      color: StylisteColors.warmGrey,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: '$title. $subtitle',
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(
          icon,
          color: StylisteColors.champagneGold,
          semanticLabel: title,
        ),
        title: Text(title, style: StylisteText.title),
        subtitle: Text(
          subtitle,
          style: StylisteText.bodySmall.copyWith(
            color: StylisteColors.warmGrey,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _SettingTitle extends StatelessWidget {
  const _SettingTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          color: StylisteColors.champagneGold,
          semanticLabel: title,
        ),
        const SizedBox(width: StylisteSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: StylisteText.title),
              Text(
                subtitle,
                style: StylisteText.bodySmall.copyWith(
                  color: StylisteColors.warmGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegalDocumentTile extends StatelessWidget {
  const _LegalDocumentTile({
    required this.document,
    required this.onTap,
  });

  final LegalDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${document.title}. ${document.summary}',
      child: AurelianCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: StylisteSpacing.minTapTarget,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  document.icon,
                  color: StylisteColors.champagneGold,
                  semanticLabel: document.shortTitle,
                ),
                const SizedBox(width: StylisteSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(document.title, style: StylisteText.title),
                      const SizedBox(height: StylisteSpacing.xxs),
                      Text(
                        document.summary,
                        style: StylisteText.bodySmall.copyWith(
                          color: StylisteColors.warmGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: StylisteSpacing.xs),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
