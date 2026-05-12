// GDD §3.6 — Settings: Expert/Casual toggle, notifications, legal
// Expert Mode: shows live demand variables in Ledger (GDD §8.9.11)
// Luxe acknowledges every mode switch with a personalised line

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/aurelian_theme.dart';

const String _kExpertModeKey = 'expert_mode_enabled';
const String _kNotificationsKey = 'notifications_enabled';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _expertMode = false;
  bool _notifications = true;
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
            const Icon(Icons.auto_awesome, color: AurelianPalette.champagneGold, size: 20),
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
              style: TextStyle(color: AurelianPalette.textTertiary, fontFamily: 'SpaceGrotesk'),
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary,
      appBar: AppBar(
        backgroundColor: AurelianPalette.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AurelianPalette.champagneGold, size: 20),
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
              child: CircularProgressIndicator(color: AurelianPalette.champagneGold),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: <Widget>[
                // ── EXPERIENCE ────────────────────────────────────────────
                const _SectionHeader(label: 'EXPERIENCE'),
                _SettingsTile(
                  icon: Icons.analytics_outlined,
                  title: 'Expert Mode',
                  subtitle: 'Shows live demand variables, market formulas, and advanced\neconomic indicators in the Ledger.',
                  trailing: Switch(
                    value: _expertMode,
                    onChanged: _onExpertModeToggle,
                    activeThumbColor: AurelianPalette.champagneGold,
                    activeTrackColor: AurelianPalette.champagneGold.withValues(alpha: 0.3),
                    inactiveThumbColor: AurelianPalette.textTertiary,
                    inactiveTrackColor: AurelianPalette.textTertiary.withValues(alpha: 0.2),
                  ),
                ),
                _ExpertModeChip(active: _expertMode),
                const SizedBox(height: 24),

                // ── NOTIFICATIONS ─────────────────────────────────────────
                const _SectionHeader(label: 'NOTIFICATIONS'),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Idle income milestones, event alerts, and Maison activity.',
                  trailing: Switch(
                    value: _notifications,
                    onChanged: (bool v) => _setNotifications(value: v),
                    activeThumbColor: AurelianPalette.champagneGold,
                    activeTrackColor: AurelianPalette.champagneGold.withValues(alpha: 0.3),
                    inactiveThumbColor: AurelianPalette.textTertiary,
                    inactiveTrackColor: AurelianPalette.textTertiary.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(height: 24),

                // ── LEGAL ──────────────────────────────────────────────────
                const _SectionHeader(label: 'LEGAL'),
                _SettingsLinkTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _launchUrl('https://thestyliste.app/privacy'),
                ),
                _SettingsLinkTile(
                  icon: Icons.gavel_outlined,
                  title: 'Terms of Service',
                  onTap: () => _launchUrl('https://thestyliste.app/terms'),
                ),
                _SettingsLinkTile(
                  icon: Icons.description_outlined,
                  title: 'EULA',
                  onTap: () => _launchUrl('https://thestyliste.app/eula'),
                ),
                _SettingsLinkTile(
                  icon: Icons.group_outlined,
                  title: 'Community Guidelines',
                  onTap: () => _launchUrl('https://thestyliste.app/community'),
                ),
                _SettingsLinkTile(
                  icon: Icons.cookie_outlined,
                  title: 'Cookie Policy',
                  onTap: () => _launchUrl('https://thestyliste.app/cookies'),
                ),
                _SettingsLinkTile(
                  icon: Icons.copyright_outlined,
                  title: 'DMCA / Copyright',
                  onTap: () => _launchUrl('https://thestyliste.app/dmca'),
                ),
                _SettingsLinkTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Refund Policy',
                  onTap: () => _launchUrl('https://thestyliste.app/refunds'),
                ),
                _SettingsLinkTile(
                  icon: Icons.child_care_outlined,
                  title: 'Children\'s Privacy',
                  onTap: () => _launchUrl('https://thestyliste.app/coppa'),
                ),
                _SettingsLinkTile(
                  icon: Icons.accessibility_new_outlined,
                  title: 'Accessibility Statement',
                  onTap: () => _launchUrl('https://thestyliste.app/accessibility'),
                ),
                const SizedBox(height: 48),

                // ── VERSION ────────────────────────────────────────────────
                Center(
                  child: Text(
                    'THE STYLISTE  v1.0.0\nSkinTeethNerd Studios',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AurelianPalette.textTertiary.withValues(alpha: 0.5),
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
