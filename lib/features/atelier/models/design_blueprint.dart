/// Client-owned, versioned editing intent. It contains no score, reward, Vex,
/// customer, feed, ownership, or authority field; the server owns those values.
class DesignBlueprint {
  const DesignBlueprint({
    required this.version,
    required this.garmentCategory,
    required this.editableZones,
    required this.materials,
    required this.palette,
    required this.constructionChoices,
    required this.revisionLineage,
  });

  static const int currentVersion = 1;
  static const String starterGarment = 'starter_garment';

  final int version;
  final String garmentCategory;
  final List<String> editableZones;
  final List<String> materials;
  final List<String> palette;
  final List<String> constructionChoices;
  final List<String> revisionLineage;

  factory DesignBlueprint.starter({
    required List<String> materials,
    required List<String> palette,
  }) {
    return DesignBlueprint(
      version: currentVersion,
      garmentCategory: starterGarment,
      editableZones: const <String>['bodice'],
      materials: _bounded(materials, 1, 4, fallback: 'starter_fabric'),
      palette: _bounded(palette, 1, 6, fallback: 'FAF7F0'),
      constructionChoices: const <String>['straight_seam'],
      revisionLineage: const <String>[],
    );
  }

  DesignBlueprint copyWith({
    List<String>? editableZones,
    List<String>? materials,
    List<String>? palette,
    List<String>? constructionChoices,
    List<String>? revisionLineage,
  }) {
    return DesignBlueprint(
      version: version,
      garmentCategory: garmentCategory,
      editableZones: editableZones ?? this.editableZones,
      materials: materials ?? this.materials,
      palette: palette ?? this.palette,
      constructionChoices: constructionChoices ?? this.constructionChoices,
      revisionLineage: revisionLineage ?? this.revisionLineage,
    );
  }

  Map<String, Object> toJson() {
    return <String, Object>{
      'version': version,
      'garment_category': garmentCategory,
      'editable_zones': editableZones,
      'materials': materials,
      'palette': palette,
      'construction_choices': constructionChoices,
      'revision_lineage': revisionLineage,
    };
  }

  bool get isReleaseValid {
    return version == currentVersion &&
        garmentCategory == starterGarment &&
        editableZones.isNotEmpty &&
        editableZones.length <= 8 &&
        materials.isNotEmpty &&
        materials.length <= 4 &&
        palette.isNotEmpty &&
        palette.length <= 6 &&
        constructionChoices.isNotEmpty &&
        constructionChoices.length <= 6;
  }

  static List<String> _bounded(
    List<String> values,
    int minimum,
    int maximum, {
    required String fallback,
  }) {
    final List<String> normalized = values
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toSet()
        .take(maximum)
        .toList(growable: false);
    return normalized.isEmpty && minimum > 0 ? <String>[fallback] : normalized;
  }
}
