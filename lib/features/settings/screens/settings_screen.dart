// GDD §3.6 — Settings: Expert/Casual toggle, notifications, legal
// Expert Mode: shows live demand variables in Ledger (GDD §8.9.11)
// Luxe acknowledges every mode switch with a personalised line

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../../legal/legal_documents.dart';
import '../../legal/screens/legal_document_screen.dart';

const String _kExpertModeKey = 'expert_mode_enabled';
const String _kNotificationsKey = 'notifications_enabled';
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
  bool _notifications = true;
  bool _reducedMotion = false;
  bool _highContrast = false;
  double _textScale = 1.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _expertMode = prefs.getBool(_kExpertModeKey) ?? false;
      _notifications = prefs.getBool(_kNotificationsKey) ?? true;
      _reducedMotion = prefs.getBool(_kReducedMotionKey) ?? false;
      _highContrast = prefs.getBool(_kHighContrastKey) ?? false;
      _textScale = prefs.getDouble(_kTextScaleKey) ?? 1.0;
      _loading = false;
    });
  }

  Future<void> _setExpertMode({required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kExpertModeKey, value);
    setState(() => _expertMode = value);
  }

  Future<void> _setNotifications({required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotificationsKey, value);
    setState(() => _notifications = value);
  }

  Future<void> _setReducedMotion({required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReducedMotionKey, value);
    setState(() => _reducedMotion = value);
  }

  Future<void> _setHighContrast({required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHighContrastKey, value);
    setState(() => _highContrast = value);
  }

  Future<void> _setTextScale(double value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kTextScaleKey, value);
    setState(() => _textScale = value);
  }

  // GDD §3.6 — Luxe acknowledges the mode switch with a personalised line
  Future<void> _onExpertModeToggle(bool newValue) async {
    final String luxeLine = newValue
        ? "The numbers don't lie, darling. Let's see what you're made of."
        : 'Smart. The empire matters more than the spreadsheet.';

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AurelianPalette.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AurelianPalette.champagneGold),
        ),
        title: Row(
          children: <Widget>[
            const Icon(
              Icons.auto_awesome,
              color: AurelianPalette.champagneGold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              newValue ? 'EXPERT MODE' : 'CASUAL MODE',
              style: const TextStyle(
                color: AurelianPalette.champagneGold,
                fontFamily: 'SpaceGrotesk',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        content: Text(
          '\u201C$luxeLine\u201D\n\n— Luxe',
          style: const TextStyle(
            color: AurelianPalette.ivory,
            fontFamily: 'SpaceGrotesk',
            fontStyle: FontStyle.italic,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: AurelianPalette.textTertiary,
                fontFamily: 'SpaceGrotesk',
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'CONFIRM',
              style: TextStyle(
                color: AurelianPalette.champagneGold,
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _setExpertMode(value: newValue);
    }
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
    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary,
      appBar: AppBar(
        backgroundColor: AurelianPalette.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AurelianPalette.champagneGold,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: AurelianPalette.champagneGold,
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AurelianPalette.champagneGold.withValues(alpha: 0.2),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AurelianPalette.champagneGold,
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: <Widget>[
                // ── EXPERIENCE ────────────────────────────────────────────
                const _SectionHeader(label: 'EXPERIENCE'),
                _SettingsTile(
                  icon: Icons.analytics_outlined,
                  title: 'Expert Mode',
                  subtitle:
                      'Shows live demand variables, market formulas, and advanced\neconomic indicators in the Ledger.',
                  trailing: Switch(
                    value: _expertMode,
                    onChanged: _onExpertModeToggle,
                    activeThumbColor: AurelianPalette.champagneGold,
                    activeTrackColor:
                        AurelianPalette.champagneGold.withValues(alpha: 0.3),
                    inactiveThumbColor: AurelianPalette.textTertiary,
                    inactiveTrackColor:
                        AurelianPalette.textTertiary.withValues(alpha: 0.2),
                  ),
                ),
                _ExpertModeChip(active: _expertMode),
                const SizedBox(height: 24),

                const _SectionHeader(label: 'ACCESSIBILITY'),
                _SettingsTile(
                  icon: Icons.motion_photos_off_outlined,
                  title: 'Reduced Motion',
                  subtitle:
                      'Limits decorative motion and animated transitions.',
                  trailing: Switch(
                    value: _reducedMotion,
                    onChanged: (bool v) => _setReducedMotion(value: v),
                    activeThumbColor: AurelianPalette.champagneGold,
                    activeTrackColor:
                        AurelianPalette.champagneGold.withValues(alpha: 0.3),
                    inactiveThumbColor: AurelianPalette.textTertiary,
                    inactiveTrackColor:
                        AurelianPalette.textTertiary.withValues(alpha: 0.2),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.contrast_outlined,
                  title: 'High Contrast',
                  subtitle:
                      'Strengthens borders, labels, and critical status colors.',
                  trailing: Switch(
                    value: _highContrast,
                    onChanged: (bool v) => _setHighContrast(value: v),
                    activeThumbColor: AurelianPalette.champagneGold,
                    activeTrackColor:
                        AurelianPalette.champagneGold.withValues(alpha: 0.3),
                    inactiveThumbColor: AurelianPalette.textTertiary,
                    inactiveTrackColor:
                        AurelianPalette.textTertiary.withValues(alpha: 0.2),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.text_fields_outlined,
                  title: 'Text Scale',
                  subtitle:
                      'Adjusts in-app reading comfort from compact to large.',
                  trailing: SizedBox(
                    width: 150,
                    child: Slider(
                      value: _textScale,
                      min: 0.9,
                      max: 1.3,
                      divisions: 4,
                      label: '${(_textScale * 100).round()}%',
                      activeColor: AurelianPalette.champagneGold,
                      inactiveColor:
                          AurelianPalette.textTertiary.withValues(alpha: 0.25),
                      onChanged: _setTextScale,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── NOTIFICATIONS ─────────────────────────────────────────
                const _SectionHeader(label: 'NOTIFICATIONS'),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle:
                      'Idle income milestones, event alerts, and Maison activity.',
                  trailing: Switch(
                    value: _notifications,
                    onChanged: (bool v) => _setNotifications(value: v),
                    activeThumbColor: AurelianPalette.champagneGold,
                    activeTrackColor:
                        AurelianPalette.champagneGold.withValues(alpha: 0.3),
                    inactiveThumbColor: AurelianPalette.textTertiary,
                    inactiveTrackColor:
                        AurelianPalette.textTertiary.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(height: 24),

                // ── LEGAL ──────────────────────────────────────────────────
                const _SectionHeader(label: 'LEGAL'),
                for (final LegalDocument document in LegalDocuments.all)
                  _SettingsLinkTile(
                    icon: document.icon,
                    title: document.title,
                    subtitle: document.summary,
                    onTap: () => _openLegalDocument(document),
                  ),
                const SizedBox(height: 48),

                // ── VERSION ────────────────────────────────────────────────
                Center(
                  child: Text(
                    'THE STYLISTE  v1.0.0\nSkinTeethNerd Studios',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          AurelianPalette.textTertiary.withValues(alpha: 0.5),
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 11,
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AurelianPalette.champagneGold,
          fontFamily: 'SpaceGrotesk',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AurelianPalette.ivory.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: AurelianPalette.champagneGold, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: AurelianPalette.ivory,
            fontFamily: 'SpaceGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AurelianPalette.textTertiary.withValues(alpha: 0.7),
            fontFamily: 'SpaceGrotesk',
            fontSize: 12,
            height: 1.4,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AurelianPalette.ivory.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: AurelianPalette.champagneGold, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: AurelianPalette.ivory,
            fontFamily: 'SpaceGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AurelianPalette.textTertiary.withValues(alpha: 0.66),
            fontFamily: 'SpaceGrotesk',
            fontSize: 11,
            height: 1.35,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AurelianPalette.textTertiary,
          size: 14,
        ),
      ),
    );
  }
}

class _ExpertModeChip extends StatelessWidget {
  const _ExpertModeChip({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: <Widget>[
          Icon(
            active ? Icons.visibility : Icons.visibility_off,
            size: 13,
            color: active
                ? AurelianPalette.champagneGold
                : AurelianPalette.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 6),
          Text(
            active
                ? 'Live demand variables visible in the Ledger'
                : 'Simplified demand indicators active',
            style: TextStyle(
              color: active
                  ? AurelianPalette.champagneGold.withValues(alpha: 0.7)
                  : AurelianPalette.textTertiary.withValues(alpha: 0.4),
              fontFamily: 'SpaceGrotesk',
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
