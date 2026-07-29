import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/styliste_colors.dart';
import '../../../core/theme/styliste_spacing.dart';
import '../../../core/theme/styliste_typography.dart';
import '../../../core/theme/styliste_visual_mode.dart';
import '../../../core/widgets/aurelian_components.dart';
import '../../../core/widgets/styliste_buttons.dart';
import '../../../core/widgets/styliste_scaffold.dart';
import '../models/kingston_capsule.dart';
import '../providers/capsule_foundation_provider.dart';

class CapsuleWorkspaceScreen extends ConsumerStatefulWidget {
  const CapsuleWorkspaceScreen({super.key});

  @override
  ConsumerState<CapsuleWorkspaceScreen> createState() =>
      _CapsuleWorkspaceScreenState();
}

class _CapsuleWorkspaceScreenState
    extends ConsumerState<CapsuleWorkspaceScreen> {
  final GlobalKey<FormState> _briefFormKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _narrativeController = TextEditingController();

  String _targetAudience = CollectionBrief.targetAudiences.first;
  String _houseCode = CollectionBrief.houseCodes.first;
  String _paletteDirection = CollectionBrief.paletteDirections.first;
  String _materialDirection = CollectionBrief.materialDirections.first;
  String _silhouette = CapsuleLookGrammar.silhouettes.first;
  String _lookMaterial = CapsuleLookGrammar.materials.first;
  String _lookPalette = CapsuleLookGrammar.palettes.first;
  String _construction = CapsuleLookGrammar.constructions.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(capsuleFoundationProvider.notifier).restore();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _narrativeController.dispose();
    super.dispose();
  }

  void _beginEditing() {
    ref.read(capsuleFoundationProvider.notifier).beginEditing();
  }

  Future<void> _saveBrief() async {
    if (!(_briefFormKey.currentState?.validate() ?? false)) return;
    await ref.read(capsuleFoundationProvider.notifier).saveBrief(
          CollectionBrief(
            title: _titleController.text,
            narrative: _narrativeController.text,
            targetAudience: _targetAudience,
            houseCode: _houseCode,
            paletteDirection: _paletteDirection,
            materialDirection: _materialDirection,
          ),
        );
  }

  Future<void> _saveLook(String role) {
    return ref.read(capsuleFoundationProvider.notifier).saveLook(
          role: role,
          grammar: CapsuleLookGrammar(
            silhouette: _silhouette,
            material: _lookMaterial,
            palette: _lookPalette,
            construction: _construction,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final CapsuleFoundationState state = ref.watch(capsuleFoundationProvider);
    final CapsuleFoundationNotifier actions = ref.read(
      capsuleFoundationProvider.notifier,
    );
    final KingstonCapsule? capsule = state.capsule;

    return AurelianScaffold(
      mode: StylisteVisualMode.atelierWarmStudio,
      appBar: AurelianContextualAppBar(
        eyebrow: 'Kingston House',
        title: 'Capsule Workspace',
        leading: IconButton(
          tooltip: 'Return to Atelier',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 32.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 640.0
                      ? 560.0
                      : constraints.maxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _HouseResolutionCard(
                      specialization: capsule?.specialization,
                      restored: state.phase == CapsuleFoundationPhase.restored,
                    ),
                    const SizedBox(height: StylisteSpacing.stackMd),
                    if (capsule != null) ...<Widget>[
                      _CapsulePatternBoard(capsule: capsule),
                      const SizedBox(height: StylisteSpacing.stackMd),
                    ],
                    if (capsule == null)
                      _InitialState(state: state, onRetry: actions.retry)
                    else ...<Widget>[
                      _StageSignal(
                        label: capsule.stage.label,
                        isReady: capsule.samplingUnavailable,
                      ),
                      const SizedBox(height: StylisteSpacing.stackMd),
                      _ReliabilityNotice(
                        state: state,
                        onRetry: actions.retry,
                      ),
                      if (capsule.stage == KingstonCapsuleStage.briefDraft)
                        _CollectionBriefForm(
                          formKey: _briefFormKey,
                          titleController: _titleController,
                          narrativeController: _narrativeController,
                          targetAudience: _targetAudience,
                          houseCode: _houseCode,
                          paletteDirection: _paletteDirection,
                          materialDirection: _materialDirection,
                          isSubmitting:
                              state.phase == CapsuleFoundationPhase.submitting,
                          onEditing: _beginEditing,
                          onTargetAudience: (String value) =>
                              setState(() => _targetAudience = value),
                          onHouseCode: (String value) =>
                              setState(() => _houseCode = value),
                          onPaletteDirection: (String value) =>
                              setState(() => _paletteDirection = value),
                          onMaterialDirection: (String value) =>
                              setState(() => _materialDirection = value),
                          onSubmit: _saveBrief,
                        ),
                      const SizedBox(height: StylisteSpacing.stackMd),
                      _LookRoleCard(
                        role: 'hero_piece',
                        label: 'Hero Piece',
                        detail:
                            'The image that introduces your House to Kingston.',
                        complete:
                            capsule.lookFor('hero_piece')?.isComplete ?? false,
                        active: capsule.stage ==
                            KingstonCapsuleStage.briefConfirmed,
                        isSubmitting:
                            state.phase == CapsuleFoundationPhase.submitting,
                        silhouette: _silhouette,
                        material: _lookMaterial,
                        palette: _lookPalette,
                        construction: _construction,
                        onEditing: _beginEditing,
                        onSilhouette: (String value) =>
                            setState(() => _silhouette = value),
                        onMaterial: (String value) =>
                            setState(() => _lookMaterial = value),
                        onPalette: (String value) =>
                            setState(() => _lookPalette = value),
                        onConstruction: (String value) =>
                            setState(() => _construction = value),
                        onSubmit: () => _saveLook('hero_piece'),
                      ),
                      const SizedBox(height: StylisteSpacing.stackSm),
                      _LookRoleCard(
                        role: 'commercial_anchor',
                        label: 'Commercial Anchor',
                        detail:
                            'The piece that proves your point of view can travel.',
                        complete:
                            capsule.lookFor('commercial_anchor')?.isComplete ??
                                false,
                        active: capsule.stage ==
                            KingstonCapsuleStage.heroPieceComplete,
                        isSubmitting:
                            state.phase == CapsuleFoundationPhase.submitting,
                        silhouette: _silhouette,
                        material: _lookMaterial,
                        palette: _lookPalette,
                        construction: _construction,
                        onEditing: _beginEditing,
                        onSilhouette: (String value) =>
                            setState(() => _silhouette = value),
                        onMaterial: (String value) =>
                            setState(() => _lookMaterial = value),
                        onPalette: (String value) =>
                            setState(() => _lookPalette = value),
                        onConstruction: (String value) =>
                            setState(() => _construction = value),
                        onSubmit: () => _saveLook('commercial_anchor'),
                      ),
                      const SizedBox(height: StylisteSpacing.stackSm),
                      _LookRoleCard(
                        role: 'experimental_piece',
                        label: 'Experimental Piece',
                        detail:
                            'The controlled risk that makes the capsule unmistakably yours.',
                        complete:
                            capsule.lookFor('experimental_piece')?.isComplete ??
                                false,
                        active: capsule.stage ==
                            KingstonCapsuleStage.commercialAnchorComplete,
                        isSubmitting:
                            state.phase == CapsuleFoundationPhase.submitting,
                        silhouette: _silhouette,
                        material: _lookMaterial,
                        palette: _lookPalette,
                        construction: _construction,
                        onEditing: _beginEditing,
                        onSilhouette: (String value) =>
                            setState(() => _silhouette = value),
                        onMaterial: (String value) =>
                            setState(() => _lookMaterial = value),
                        onPalette: (String value) =>
                            setState(() => _lookPalette = value),
                        onConstruction: (String value) =>
                            setState(() => _construction = value),
                        onSubmit: () => _saveLook('experimental_piece'),
                      ),
                      if (capsule.stage ==
                          KingstonCapsuleStage
                              .experimentalPieceComplete) ...<Widget>[
                        const SizedBox(height: StylisteSpacing.stackMd),
                        GoldPrimaryButton(
                          label: 'Confirm capsule readiness',
                          icon: Icons.verified_outlined,
                          isLoading:
                              state.phase == CapsuleFoundationPhase.submitting,
                          onPressed:
                              state.phase == CapsuleFoundationPhase.submitting
                                  ? null
                                  : actions.evaluateReadiness,
                        ),
                      ],
                      if (capsule.samplingUnavailable) ...<Widget>[
                        const SizedBox(height: StylisteSpacing.stackMd),
                        _SamplingBoundary(readiness: capsule.readiness),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HouseResolutionCard extends StatelessWidget {
  const _HouseResolutionCard({
    required this.specialization,
    required this.restored,
  });

  final String? specialization;
  final bool restored;

  @override
  Widget build(BuildContext context) {
    final String lens = specialization == 'architect' ? 'Architect' : 'Artisan';
    return Semantics(
      label:
          'Kingston House resolution. $lens lens. Both lenses have equal gameplay ceilings.',
      child: _Panel(
        color: StylisteColors.obsidian,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              restored
                  ? 'RESTORED FROM YOUR HOUSE RECORD'
                  : 'FOUNDER PATH RESOLVED',
              style: StylisteText.labelCaps.copyWith(
                color: StylisteColors.champagneGold,
              ),
            ),
            const SizedBox(height: StylisteSpacing.stackSm),
            Text(
              '$lens lens, one Kingston ceiling.',
              style: StylisteText.headline.copyWith(
                color: StylisteColors.ivory,
              ),
            ),
            const SizedBox(height: StylisteSpacing.stackSm),
            const Text(
              'Luxe keeps the creative and business lenses in view. Neither changes your access to the capsule or its readiness rule.',
              style: TextStyle(color: StylisteColors.warmGrey, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapsulePatternBoard extends StatelessWidget {
  const _CapsulePatternBoard({required this.capsule});

  final KingstonCapsule capsule;

  @override
  Widget build(BuildContext context) {
    final List<(String, String)> roles = <(String, String)>[
      ('hero_piece', 'Hero Piece'),
      ('commercial_anchor', 'Commercial Anchor'),
      ('experimental_piece', 'Experimental Piece'),
    ];
    return AurelianCard(
      semanticLabel:
          'Three-look Kingston capsule pattern board. Hero Piece, Commercial Anchor, Experimental Piece.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AurelianSectionHeader(
            eyebrow: 'Three-look capsule',
            title: 'One House, three distinct roles',
            detail:
                'Pattern-cutting lines keep the garments central while each role carries a different job.',
          ),
          const SizedBox(height: StylisteSpacing.stackMd),
          SizedBox(
            height: 210,
            child: CustomPaint(
              painter: _CapsulePatternPainter(
                completed: roles
                    .map(
                      ((String, String) role) =>
                          capsule.lookFor(role.$1)?.isComplete ?? false,
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          const SizedBox(height: StylisteSpacing.stackSm),
          Wrap(
            spacing: StylisteSpacing.stackSm,
            runSpacing: StylisteSpacing.stackSm,
            children: roles
                .map(
                  ((String, String) role) => AurelianStatusChip(
                    label: role.$2,
                    icon: capsule.lookFor(role.$1)?.isComplete ?? false
                        ? Icons.check
                        : Icons.more_horiz,
                    tone: capsule.lookFor(role.$1)?.isComplete ?? false
                        ? AurelianStatusTone.positive
                        : AurelianStatusTone.neutral,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _CapsulePatternPainter extends CustomPainter {
  const _CapsulePatternPainter({required this.completed});

  final List<bool> completed;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint drafting = Paint()
      ..color = StylisteColors.deepGold.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double y = 18; y < size.height; y += 24) {
      canvas.drawLine(
          Offset.zero.translate(0, y), Offset(size.width, y), drafting);
    }

    final double column = size.width / 3;
    for (int index = 0; index < 3; index++) {
      final Offset center = Offset(
        column * index + column / 2,
        size.height * 0.48,
      );
      final Paint seam = Paint()
        ..color = completed[index]
            ? StylisteColors.profitGreen
            : StylisteColors.deepGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = completed[index] ? 2.1 : 1.4;
      final double width = column * (index == 2 ? 0.58 : 0.5);
      final Path garment = Path()
        ..moveTo(center.dx - width * 0.18, center.dy - 76)
        ..quadraticBezierTo(
          center.dx,
          center.dy - 88,
          center.dx + width * 0.18,
          center.dy - 76,
        )
        ..lineTo(center.dx + width * 0.5, center.dy - 45)
        ..lineTo(center.dx + width * 0.32, center.dy - 12)
        ..lineTo(center.dx + width * (index == 1 ? 0.4 : 0.56), center.dy + 70)
        ..lineTo(center.dx - width * (index == 1 ? 0.4 : 0.56), center.dy + 70)
        ..lineTo(center.dx - width * 0.32, center.dy - 12)
        ..lineTo(center.dx - width * 0.5, center.dy - 45)
        ..close();
      canvas.drawPath(garment, seam);
      canvas.drawLine(
        Offset(center.dx, center.dy - 82),
        Offset(center.dx, center.dy + 70),
        drafting,
      );
      canvas.drawCircle(
        Offset(center.dx, center.dy - 28),
        4,
        seam,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CapsulePatternPainter oldDelegate) {
    for (int index = 0; index < completed.length; index++) {
      if (oldDelegate.completed[index] != completed[index]) return true;
    }
    return false;
  }
}

class _InitialState extends StatelessWidget {
  const _InitialState({required this.state, required this.onRetry});

  final CapsuleFoundationState state;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final bool loading = state.phase == CapsuleFoundationPhase.loading ||
        state.phase == CapsuleFoundationPhase.submitting;
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (loading) ...<Widget>[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: StylisteSpacing.stackMd),
            const Text(
              'Luxe is restoring your Kingston House record.',
              textAlign: TextAlign.center,
              style: StylisteText.body,
            ),
          ] else ...<Widget>[
            Semantics(
              liveRegion: true,
              child: Text(
                state.error ?? 'Your capsule is temporarily unavailable.',
                style: StylisteText.body.copyWith(
                  color: StylisteColors.rivalRed,
                ),
              ),
            ),
            const SizedBox(height: StylisteSpacing.stackMd),
            GoldPrimaryButton(
              label: 'Retry restoration',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}

class _StageSignal extends StatelessWidget {
  const _StageSignal({required this.label, required this.isReady});

  final String label;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Current capsule stage: $label',
      child: Row(
        children: <Widget>[
          Icon(
            isReady ? Icons.verified_outlined : Icons.auto_awesome_outlined,
            color: StylisteColors.deepGold,
          ),
          const SizedBox(width: StylisteSpacing.stackSm),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: StylisteText.labelCaps.copyWith(
                color: StylisteColors.deepGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReliabilityNotice extends StatelessWidget {
  const _ReliabilityNotice({required this.state, required this.onRetry});

  final CapsuleFoundationState state;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final String? message = switch (state.phase) {
      CapsuleFoundationPhase.empty =>
        'Your House is ready for its first Collection Brief.',
      CapsuleFoundationPhase.editing =>
        'Your choices are local until Luxe confirms this step.',
      CapsuleFoundationPhase.confirmed =>
        'Luxe confirmed your last capsule step.',
      CapsuleFoundationPhase.offline ||
      CapsuleFoundationPhase.retryableError =>
        state.error ?? 'That step was not confirmed. Your capsule is safe.',
      _ => null,
    };
    if (message == null) {
      return const SizedBox.shrink();
    }
    final bool isError = state.phase == CapsuleFoundationPhase.offline ||
        state.phase == CapsuleFoundationPhase.retryableError;
    return Padding(
      padding: const EdgeInsets.only(bottom: StylisteSpacing.stackMd),
      child: _Panel(
        color: isError ? StylisteColors.ivory : StylisteColors.alabaster,
        borderColor:
            isError ? StylisteColors.rivalRed : StylisteColors.profitGreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: StylisteText.body.copyWith(
                  color: isError
                      ? StylisteColors.rivalRed
                      : StylisteColors.profitGreen,
                ),
              ),
            ),
            if (isError) ...<Widget>[
              const SizedBox(height: StylisteSpacing.stackSm),
              IvorySecondaryButton(
                label: 'Retry safely',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CollectionBriefForm extends StatelessWidget {
  const _CollectionBriefForm({
    required this.formKey,
    required this.titleController,
    required this.narrativeController,
    required this.targetAudience,
    required this.houseCode,
    required this.paletteDirection,
    required this.materialDirection,
    required this.isSubmitting,
    required this.onEditing,
    required this.onTargetAudience,
    required this.onHouseCode,
    required this.onPaletteDirection,
    required this.onMaterialDirection,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController narrativeController;
  final String targetAudience;
  final String houseCode;
  final String paletteDirection;
  final String materialDirection;
  final bool isSubmitting;
  final VoidCallback onEditing;
  final ValueChanged<String> onTargetAudience;
  final ValueChanged<String> onHouseCode;
  final ValueChanged<String> onPaletteDirection;
  final ValueChanged<String> onMaterialDirection;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('COLLECTION BRIEF', style: StylisteText.labelCaps),
            const SizedBox(height: StylisteSpacing.stackSm),
            const Text(
              'Give the three looks one unmistakable Kingston point of view.',
              style: StylisteText.body,
            ),
            const SizedBox(height: StylisteSpacing.stackMd),
            TextFormField(
              controller: titleController,
              maxLength: 48,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => onEditing(),
              decoration: const InputDecoration(labelText: 'Capsule title'),
              validator: (String? value) => (value?.trim().length ?? 0) >= 2
                  ? null
                  : 'Give the capsule a title of at least 2 characters.',
            ),
            const SizedBox(height: StylisteSpacing.stackSm),
            TextFormField(
              controller: narrativeController,
              minLines: 3,
              maxLines: 5,
              maxLength: 240,
              onChanged: (_) => onEditing(),
              decoration: const InputDecoration(
                labelText: 'Narrative statement',
              ),
              validator: (String? value) => (value?.trim().length ?? 0) >= 12
                  ? null
                  : 'Use at least 12 characters to set the point of view.',
            ),
            const SizedBox(height: StylisteSpacing.stackSm),
            _ChoiceField(
              label: 'Kingston audience',
              value: targetAudience,
              choices: CollectionBrief.targetAudiences,
              onChanged: (String value) {
                onEditing();
                onTargetAudience(value);
              },
            ),
            _ChoiceField(
              label: 'House code',
              value: houseCode,
              choices: CollectionBrief.houseCodes,
              onChanged: (String value) {
                onEditing();
                onHouseCode(value);
              },
            ),
            _ChoiceField(
              label: 'Palette direction',
              value: paletteDirection,
              choices: CollectionBrief.paletteDirections,
              onChanged: (String value) {
                onEditing();
                onPaletteDirection(value);
              },
            ),
            _ChoiceField(
              label: 'Material direction',
              value: materialDirection,
              choices: CollectionBrief.materialDirections,
              onChanged: (String value) {
                onEditing();
                onMaterialDirection(value);
              },
            ),
            const SizedBox(height: StylisteSpacing.stackMd),
            GoldPrimaryButton(
              label: 'Confirm collection brief',
              icon: Icons.arrow_forward,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _LookRoleCard extends StatelessWidget {
  const _LookRoleCard({
    required this.role,
    required this.label,
    required this.detail,
    required this.complete,
    required this.active,
    required this.isSubmitting,
    required this.silhouette,
    required this.material,
    required this.palette,
    required this.construction,
    required this.onEditing,
    required this.onSilhouette,
    required this.onMaterial,
    required this.onPalette,
    required this.onConstruction,
    required this.onSubmit,
  });

  final String role;
  final String label;
  final String detail;
  final bool complete;
  final bool active;
  final bool isSubmitting;
  final String silhouette;
  final String material;
  final String palette;
  final String construction;
  final VoidCallback onEditing;
  final ValueChanged<String> onSilhouette;
  final ValueChanged<String> onMaterial;
  final ValueChanged<String> onPalette;
  final ValueChanged<String> onConstruction;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final String stateLabel = complete
        ? 'Confirmed'
        : active
            ? 'Now shaping'
            : 'Ahead';
    return Semantics(
      container: true,
      label: '$label. $stateLabel. $detail',
      child: _Panel(
        borderColor: active ? StylisteColors.champagneGold : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(label, style: StylisteText.headline)),
                Text(
                  stateLabel.toUpperCase(),
                  style: StylisteText.labelCaps.copyWith(
                    color: complete
                        ? StylisteColors.profitGreen
                        : StylisteColors.deepGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: StylisteSpacing.stackSm),
            Text(detail, style: StylisteText.body),
            if (active) ...<Widget>[
              const SizedBox(height: StylisteSpacing.stackMd),
              _ChoiceField(
                label: 'Silhouette',
                value: silhouette,
                choices: CapsuleLookGrammar.silhouettes,
                onChanged: (String value) {
                  onEditing();
                  onSilhouette(value);
                },
              ),
              _ChoiceField(
                label: 'Material',
                value: material,
                choices: CapsuleLookGrammar.materials,
                onChanged: (String value) {
                  onEditing();
                  onMaterial(value);
                },
              ),
              _ChoiceField(
                label: 'Palette',
                value: palette,
                choices: CapsuleLookGrammar.palettes,
                onChanged: (String value) {
                  onEditing();
                  onPalette(value);
                },
              ),
              _ChoiceField(
                label: 'Construction',
                value: construction,
                choices: CapsuleLookGrammar.constructions,
                onChanged: (String value) {
                  onEditing();
                  onConstruction(value);
                },
              ),
              const SizedBox(height: StylisteSpacing.stackMd),
              GoldPrimaryButton(
                label: 'Confirm $label',
                icon: Icons.check,
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : onSubmit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.label,
    required this.value,
    required this.choices,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> choices;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: StylisteSpacing.stackSm),
      child: DropdownButtonFormField<String>(
        key: ValueKey<String>(value),
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: choices
            .map(
              (String choice) => DropdownMenuItem<String>(
                value: choice,
                child: Text(_label(choice), overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(growable: false),
        onChanged: (String? next) {
          if (next != null) onChanged(next);
        },
      ),
    );
  }
}

class _SamplingBoundary extends StatelessWidget {
  const _SamplingBoundary({required this.readiness});

  final Map<String, dynamic> readiness;

  @override
  Widget build(BuildContext context) {
    final List<Object?> causes = readiness['causes'] is List<Object?>
        ? readiness['causes'] as List<Object?>
        : const <Object?>[];
    return Semantics(
      liveRegion: true,
      label: 'Capsule readiness confirmed. Sampling unavailable in this build.',
      child: _Panel(
        color: StylisteColors.obsidian,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'READINESS CONFIRMED',
              style: StylisteText.labelCaps.copyWith(
                color: StylisteColors.champagneGold,
              ),
            ),
            const SizedBox(height: StylisteSpacing.stackSm),
            const Text(
              'Your three-look capsule is coherent enough to carry forward.',
              style: TextStyle(
                color: StylisteColors.ivory,
                fontSize: 18.0,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: StylisteSpacing.stackSm),
            ...causes.map(
              (Object? cause) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '• $cause',
                  style: const TextStyle(color: StylisteColors.warmGrey),
                ),
              ),
            ),
            const SizedBox(height: StylisteSpacing.stackMd),
            const Text(
              'Sampling is deliberately unavailable in the Kingston proof-of-fun build. No production, launch, score, reward, or Vex result is created here.',
              style: TextStyle(color: StylisteColors.warmGrey, height: 1.35),
            ),
            const SizedBox(height: StylisteSpacing.stackSm),
            const IvorySecondaryButton(
              label: 'Sampling unavailable in this build',
              icon: Icons.lock_outline,
              onPressed: null,
              disabledReason:
                  'This boundary protects the approved Early Game scope.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({this.child, this.color, this.borderColor});

  final Widget? child;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(StylisteSpacing.gutter),
      decoration: BoxDecoration(
        color: color ?? StylisteColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor ??
              StylisteColors.outlineSubtle.withValues(alpha: 0.72),
        ),
      ),
      child: child,
    );
  }
}

String _label(String value) {
  return value
      .split('_')
      .map(
        (String word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}
