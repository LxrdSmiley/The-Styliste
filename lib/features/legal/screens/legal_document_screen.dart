import 'package:flutter/material.dart';

import '../../../core/theme/aurelian_theme.dart';
import '../legal_documents.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    required this.document,
    super.key,
  });

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AurelianPalette.textPrimary,
      appBar: AppBar(
        backgroundColor: AurelianPalette.textPrimary,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AurelianPalette.champagneGold,
            size: 20.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          document.shortTitle.toUpperCase(),
          style: const TextStyle(
            color: AurelianPalette.champagneGold,
            fontFamily: 'SpaceGrotesk',
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: AurelianPalette.champagneGold.withValues(alpha: 0.2),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 32.0),
          children: <Widget>[
            _DocumentHero(document: document),
            const SizedBox(height: 18.0),
            for (final LegalSection section in document.sections)
              _LegalSectionBlock(section: section),
          ],
        ),
      ),
    );
  }
}

class _DocumentHero extends StatelessWidget {
  const _DocumentHero({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AurelianPalette.ivory.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AurelianPalette.champagneGold.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                document.icon,
                color: AurelianPalette.champagneGold,
                size: 24.0,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  document.title,
                  style: const TextStyle(
                    color: AurelianPalette.ivory,
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            document.summary,
            style: TextStyle(
              color: AurelianPalette.ivory.withValues(alpha: 0.72),
              fontFamily: 'SpaceGrotesk',
              fontSize: 13.0,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16.0),
          const _MetaLine(label: 'Version', value: LegalDocuments.alphaVersion),
          const SizedBox(height: 6.0),
          const _MetaLine(label: 'Updated', value: LegalDocuments.lastUpdated),
          const SizedBox(height: 6.0),
          _MetaLine(label: 'Source', value: document.gddReference),
          const SizedBox(height: 6.0),
          _MetaLine(
            label: 'Public URL',
            value: document.publicUrl ?? 'Bundled in-app alpha copy',
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: AurelianPalette.champagneGold,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
      style: TextStyle(
        color: AurelianPalette.textTertiary.withValues(alpha: 0.78),
        fontFamily: 'SpaceGrotesk',
        fontSize: 11.0,
        height: 1.4,
      ),
    );
  }
}

class _LegalSectionBlock extends StatelessWidget {
  const _LegalSectionBlock({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            section.heading.toUpperCase(),
            style: const TextStyle(
              color: AurelianPalette.champagneGold,
              fontFamily: 'SpaceGrotesk',
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            section.body,
            style: TextStyle(
              color: AurelianPalette.ivory.withValues(alpha: 0.72),
              fontFamily: 'SpaceGrotesk',
              fontSize: 13.0,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
