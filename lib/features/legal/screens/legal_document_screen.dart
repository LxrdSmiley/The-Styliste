import 'package:flutter/material.dart';

import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../legal_documents.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    required this.document,
    super.key,
  });

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return AurelianScaffold(
      mode: StylisteVisualMode.noirCinematic,
      appBar: AurelianContextualAppBar(
        eyebrow: 'Alpha legal',
        title: document.shortTitle,
        leading: IconButton(
          tooltip: 'Return to settings',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: AurelianResponsiveBody(
        maxWidth: 720,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _DocumentHero(document: document),
            const SizedBox(height: StylisteSpacing.lg),
            for (final LegalSection section in document.sections) ...<Widget>[
              _LegalSectionBlock(section: section),
              const SizedBox(height: StylisteSpacing.md),
            ],
            const AurelianStatePanel(
              kind: AurelianStateKind.unavailable,
              title: 'Launch legal approval is pending',
              message:
                  'This bundled alpha copy supports review only. Final counsel and public-URL verification remain required before release.',
              authorityLabel: 'Bundled alpha document',
              preservationLabel: 'Readable in-app review copy',
              retrySafetyLabel: 'No acceptance or account mutation occurs here',
              compact: true,
            ),
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
    return AurelianEditorialHero(
      dark: true,
      eyebrow: 'Alpha document · review copy',
      title: document.title,
      detail: document.summary,
      visual: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            document.icon,
            color: StylisteColors.champagneGold,
            size: StylisteSpacing.iconLg,
            semanticLabel: document.shortTitle,
          ),
          const SizedBox(width: StylisteSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _MetaLine(
                  label: 'Version',
                  value: LegalDocuments.alphaVersion,
                ),
                const _MetaLine(
                  label: 'Updated',
                  value: LegalDocuments.lastUpdated,
                ),
                _MetaLine(label: 'Source', value: document.gddReference),
                _MetaLine(
                  label: 'Public URL',
                  value: document.publicUrl ?? 'Bundled in-app alpha copy',
                ),
              ],
            ),
          ),
        ],
      ),
      status: const AurelianStatusChip(
        label: 'Not launch-approved',
        icon: Icons.gavel_outlined,
        tone: AurelianStatusTone.warning,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: StylisteSpacing.xxs),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '$label: ',
              style: StylisteText.bodySmall.copyWith(
                color: StylisteColors.champagneGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
        style: StylisteText.bodySmall.copyWith(
          color: StylisteColors.warmGrey,
        ),
      ),
    );
  }
}

class _LegalSectionBlock extends StatelessWidget {
  const _LegalSectionBlock({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    return AurelianCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              section.heading.toUpperCase(),
              style: StylisteText.labelCaps.copyWith(
                color: StylisteColors.champagneGold,
              ),
            ),
          ),
          const SizedBox(height: StylisteSpacing.sm),
          Text(section.body, style: StylisteText.bodyLarge),
        ],
      ),
    );
  }
}
