// Gate A Wave 2A client DTOs model an authoritative receipt; they do not
// calculate readiness, ownership, scores, or rewards.

enum KingstonCapsuleStage {
  briefDraft,
  briefConfirmed,
  heroPieceComplete,
  commercialAnchorComplete,
  experimentalPieceComplete,
  samplingUnavailable,
  unknown,
}

KingstonCapsuleStage capsuleStageFromApi(Object? value) {
  return switch (value) {
    'brief_draft' => KingstonCapsuleStage.briefDraft,
    'brief_confirmed' => KingstonCapsuleStage.briefConfirmed,
    'hero_piece_complete' => KingstonCapsuleStage.heroPieceComplete,
    'commercial_anchor_complete' =>
      KingstonCapsuleStage.commercialAnchorComplete,
    'experimental_piece_complete' =>
      KingstonCapsuleStage.experimentalPieceComplete,
    'sampling_unavailable' => KingstonCapsuleStage.samplingUnavailable,
    _ => KingstonCapsuleStage.unknown,
  };
}

extension KingstonCapsuleStageLabel on KingstonCapsuleStage {
  String get label {
    return switch (this) {
      KingstonCapsuleStage.briefDraft => 'Collection Brief',
      KingstonCapsuleStage.briefConfirmed => 'Hero Piece',
      KingstonCapsuleStage.heroPieceComplete => 'Commercial Anchor',
      KingstonCapsuleStage.commercialAnchorComplete => 'Experimental Piece',
      KingstonCapsuleStage.experimentalPieceComplete => 'Readiness',
      KingstonCapsuleStage.samplingUnavailable => 'Sampling unavailable',
      KingstonCapsuleStage.unknown => 'Preparing capsule',
    };
  }
}

class CollectionBrief {
  const CollectionBrief({
    required this.title,
    required this.narrative,
    required this.targetAudience,
    required this.houseCode,
    required this.paletteDirection,
    required this.materialDirection,
  });

  static const List<String> targetAudiences = <String>[
    'kingston_creatives',
    'city_evenings',
  ];
  static const List<String> houseCodes = <String>[
    'tailored_radiance',
    'soft_structure',
  ];
  static const List<String> paletteDirections = <String>[
    'ivory_obsidian',
    'kingston_blue_ivory',
  ];
  static const List<String> materialDirections = <String>[
    'cotton_twill',
    'linen_blend',
  ];

  final String title;
  final String narrative;
  final String targetAudience;
  final String houseCode;
  final String paletteDirection;
  final String materialDirection;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title.trim(),
      'narrative': narrative.trim(),
      'target_audience': targetAudience,
      'house_code': houseCode,
      'palette_direction': paletteDirection,
      'material_direction': materialDirection,
    };
  }
}

class CapsuleLookGrammar {
  const CapsuleLookGrammar({
    required this.silhouette,
    required this.material,
    required this.palette,
    required this.construction,
  });

  static const List<String> silhouettes = <String>[
    'column',
    'draped',
    'structured',
  ];
  static const List<String> materials = CollectionBrief.materialDirections;
  static const List<String> palettes = CollectionBrief.paletteDirections;
  static const List<String> constructions = <String>[
    'straight_seam',
    'soft_drape',
    'sharp_panel',
  ];

  final String silhouette;
  final String material;
  final String palette;
  final String construction;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'silhouette': silhouette,
      'material': material,
      'palette': palette,
      'construction': construction,
    };
  }
}

class KingstonCapsuleLook {
  const KingstonCapsuleLook({required this.role, this.grammar});

  final String role;
  final Map<String, dynamic>? grammar;

  bool get isComplete => grammar != null;
}

class KingstonCapsule {
  const KingstonCapsule({
    required this.stage,
    required this.specialization,
    required this.brief,
    required this.looks,
    required this.readiness,
    required this.samplingUnavailable,
  });

  final KingstonCapsuleStage stage;
  final String? specialization;
  final Map<String, dynamic> brief;
  final List<KingstonCapsuleLook> looks;
  final Map<String, dynamic> readiness;
  final bool samplingUnavailable;

  factory KingstonCapsule.fromReceipt(Map<String, dynamic> receipt) {
    final Map<String, dynamic> capsule = _asMap(receipt['capsule']);
    final List<Object?> rawLooks = capsule['looks'] is List<Object?>
        ? capsule['looks'] as List<Object?>
        : const <Object?>[];
    return KingstonCapsule(
      stage: capsuleStageFromApi(capsule['stage']),
      specialization: capsule['founder_specialization'] as String?,
      brief: _asMap(capsule['brief']),
      looks: rawLooks
          .map(_asMap)
          .where((Map<String, dynamic> look) => look['role'] is String)
          .map(
            (Map<String, dynamic> look) => KingstonCapsuleLook(
              role: look['role'] as String,
              grammar: look['grammar'] == null ? null : _asMap(look['grammar']),
            ),
          )
          .toList(growable: false),
      readiness: _asMap(capsule['readiness']),
      samplingUnavailable:
          _asMap(capsule['sampling'])['status'] == 'unavailable',
    );
  }

  KingstonCapsuleLook? lookFor(String role) {
    for (final KingstonCapsuleLook look in looks) {
      if (look.role == role) return look;
    }
    return null;
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    final Map<String, dynamic> result = <String, dynamic>{};
    value.forEach((Object? key, Object? entry) {
      result[key.toString()] = entry;
    });
    return result;
  }
  return <String, dynamic>{};
}
