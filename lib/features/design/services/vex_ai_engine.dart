// GDD v6 — Vex AI Critic: Procedural Editorial Engine
// Converts HypeCalculationResult into Vogue-style fashion critique
// Alabaster Standard: Localized, <100ms generation, weighted vocabulary pools
//
// NO third-party LLM APIs — pure procedural generation for F2P margin protection

import 'dart:math';

import '../models/vex_review.dart';
import 'hype_calculator.dart';

/// Vocabulary pool for procedural text generation
class _VexVocabulary {
  // --- Tarnished Pool (score < 40) ---
  static const List<String> tarnishedHeadlines = <String>[
    'Tragically Basic',
    'A Predictable Disaster',
    'Belongs in the Bargain Bin',
    'Conceptually Bankrupt',
    'The Definition of Forgettable',
    'Visual Noise, Signifying Nothing',
    'A Masterclass in Mediocrity',
  ];

  static const List<String> tarnishedBodies = <String>[
    'While the execution shows basic technical competence, the conceptual framework is utterly derivative. There is no point of view here.',
    'One wonders if any thought was given to the current cultural moment. This piece exists in a vacuum of creative intent.',
    'The construction is adequate. The vision is absent. Fashion demands more than mere fabric assembly.',
    'Technically, nothing failed. Culturally, everything did.',
    'This is not a statement. It is a whisper into a void that refuses to answer.',
  ];

  // --- Derivative Pool (40-70) ---
  static const List<String> derivativeHeadlines = <String>[
    'Competent but Forgettable',
    'Safe to the Point of Sedation',
    'Trend-Adjacent, Not Trend-Setting',
    'The Echo of Better Ideas',
    'Fashionably Late to Its Own Party',
    'Polished, Yet Hollow',
  ];

  static const List<String> derivativeBodies = <String>[
    'This piece will not damage your brand, but it will not elevate it either. It exists in the middle ground where careers plateau.',
    'The references are clear, perhaps too clear. Originality requires transformation, not transcription.',
    'Execution meets industry standards. Vision falls short of cultural relevance.',
    'There is craft here. What is missing is courage.',
  ];

  // --- Visionary Pool (70-90 or tsunami match) ---
  static const List<String> visionaryHeadlines = <String>[
    'The Alabaster Standard Redefined',
    'Aurelian Perfection Achieved',
    'A Tectonic Shift in the Meta',
    'Precisely What the Moment Demands',
    'Cultural Relevance, Perfectly Executed',
    'The New Canon Takes Form',
    'Vision Translated to Silk and Structure',
  ];

  static const List<String> visionaryBodies = <String>[
    'This is precisely what the moment demands. The execution honors the concept, and the concept honors the culture.',
    'You have captured the zeitgeist without sacrificing personal vision. This is the definition of relevant fashion.',
    'The silhouette speaks. The fabric listens. Together, they compose a statement that will resonate across the feed.',
    'This is not merely clothing. This is commentary—worn, seen, and understood.',
  ];

  // --- Sovereign Pool (90+ and crest match) ---
  static const List<String> sovereignHeadlines = <String>[
    'Transcendent',
    'Sovereign Class',
    'The New Canon',
    'You Have Authored a Cultural Moment',
    'A Masterpiece for the Alabaster Age',
    'The Standard Against Which All Others Will Be Measured',
    'Pure Aurelian Radiance',
  ];

  static const List<String> sovereignBodies = <String>[
    'You have not merely designed a garment. You have authored a cultural moment that will define this season.',
    'The construction is flawless. The vision is absolute. This is what happens when talent meets timing.',
    'This piece does not follow trends. It establishes them. Others will reference this work for years.',
    'In a sea of derivative noise, this is the signal. Clear, pure, and undeniable.',
    'You have captured the crest of the wave and ridden it to shore. Sovereign work.',
  ];

  static const List<String> conclusions = <String>[
    'The verdict is clear.',
    'The judgment stands.',
    'So concludes the critique.',
    'Vex has spoken.',
  ];
}

/// The Vex AI Engine — procedural fashion critic
///
/// Ingests HypeCalculationResult, outputs emotionally charged editorial review
/// <100ms generation guaranteed through pre-computed vocabulary pools
class VexAIEngine {
  final Random _random;

  VexAIEngine({Random? random}) : _random = random ?? Random();

  /// Generate a VexReview from hype calculation result
  ///
  /// [result] — The hype calculation with tsunami multipliers
  /// [optedIn] — Whether player chose to face Vex's judgment
  VexReview generateReview({
    required HypeCalculationResult result,
    bool optedIn = true,
  }) {
    final VexVerdict verdict = _determineVerdict(result);
    final String headline = _selectHeadline(verdict, result);
    final String body = _generateBody(verdict, result);

    return VexReview(
      headline: headline,
      body: body,
      verdict: verdict,
      hypeScore: result.totalScore,
      matchingTsunamiTag: result.matchingTsunamiTag,
      tsunamiMultiplier: result.tsunamiMultiplier,
      wasOptedIn: optedIn,
      generatedAt: DateTime.now().toUtc(),
    );
  }

  /// Determine verdict tier from hype result
  VexVerdict _determineVerdict(HypeCalculationResult result) {
    final double score = result.totalScore;
    final bool hasTsunamiMatch = result.tsunamiMultiplier > 1.0;
    final bool isCrestMatch = result.wasCrestMatch;

    // Sovereign: 90+ AND crest match
    if (score >= 90.0 && isCrestMatch) {
      return VexVerdict.sovereign;
    }

    // Visionary: 70-90 OR any tsunami match with decent score
    if (score >= 70.0 || (hasTsunamiMatch && score >= 60.0)) {
      return VexVerdict.visionary;
    }

    // Derivative: 40-70
    if (score >= 40.0) {
      return VexVerdict.derivative;
    }

    // Tarnished: < 40
    return VexVerdict.tarnished;
  }

  /// Select headline from appropriate vocabulary pool
  String _selectHeadline(VexVerdict verdict, HypeCalculationResult result) {
    final List<String> pool;

    switch (verdict) {
      case VexVerdict.tarnished:
        pool = _VexVocabulary.tarnishedHeadlines;
      case VexVerdict.derivative:
        pool = _VexVocabulary.derivativeHeadlines;
      case VexVerdict.visionary:
        pool = _VexVocabulary.visionaryHeadlines;
      case VexVerdict.sovereign:
        pool = _VexVocabulary.sovereignHeadlines;
    }

    return pool[_random.nextInt(pool.length)];
  }

  /// Generate body text with contextual awareness
  String _generateBody(VexVerdict verdict, HypeCalculationResult result) {
    final StringBuffer body = StringBuffer();

    // Base paragraph from pool
    final String baseText = _selectBaseBody(verdict);
    body.write(baseText);

    // Add tsunami-specific commentary if applicable
    if (result.tsunamiMultiplier > 1.0 && result.matchingTsunamiTag != null) {
      body.write(' ');
      body.write(_generateTsunamiCommentary(result));
    }

    // Add base vs tsunami tension if high base but no match
    if (result.baseScore > 70.0 && result.tsunamiMultiplier == 1.0) {
      body.write(' ');
      body.write(_generateAntiMatchCommentary(result));
    }

    // Conclusion
    body.write(' ');
    body.write(
      _VexVocabulary
          .conclusions[_random.nextInt(_VexVocabulary.conclusions.length)],
    );

    return body.toString();
  }

  /// Select base body text from pool
  String _selectBaseBody(VexVerdict verdict) {
    final List<String> pool;

    switch (verdict) {
      case VexVerdict.tarnished:
        pool = _VexVocabulary.tarnishedBodies;
      case VexVerdict.derivative:
        pool = _VexVocabulary.derivativeBodies;
      case VexVerdict.visionary:
        pool = _VexVocabulary.visionaryBodies;
      case VexVerdict.sovereign:
        pool = _VexVocabulary.sovereignBodies;
    }

    return pool[_random.nextInt(pool.length)];
  }

  /// Generate commentary for tsunami-matched designs
  String _generateTsunamiCommentary(HypeCalculationResult result) {
    final String tag = result.matchingTsunamiTag!;

    if (result.wasCrestMatch) {
      // Crest match (2.5x)
      final List<String> crestPhrases = <String>[
        'You rode the crest of the $tag wave with devastating precision.',
        'The $tag tsunami crested, and you were poised perfectly to capture its full power.',
        'This is what it looks like when vision aligns with the $tag cultural moment.',
      ];
      return crestPhrases[_random.nextInt(crestPhrases.length)];
    } else {
      // Surge match (1.5x)
      final List<String> surgePhrases = <String>[
        'You caught the $tag surge and translated it into something personal.',
        'The $tag trend provided fertile ground for your specific vision.',
        'While others merely referenced $tag, you evolved it.',
      ];
      return surgePhrases[_random.nextInt(surgePhrases.length)];
    }
  }

  /// Generate commentary for high-base designs that missed the tsunami
  String _generateAntiMatchCommentary(HypeCalculationResult result) {
    final List<String> antiPhrases = <String>[
      'Technically brilliant, but culturally deaf to the prevailing winds.',
      'The craft is undeniable. The timing, regrettable.',
      'Had this arrived in a different season, it might have dominated.',
      'A strong voice speaking to an empty room.',
    ];
    return antiPhrases[_random.nextInt(antiPhrases.length)];
  }

  /// Quick check: what would the verdict be? (for UI preview)
  VexVerdict previewVerdict(HypeCalculationResult result) {
    return _determineVerdict(result);
  }

  /// Preview headline without full generation (for UI hints)
  String? previewHeadline(HypeCalculationResult result) {
    final VexVerdict verdict = _determineVerdict(result);
    if (verdict == VexVerdict.tarnished) {
      return null; // Keep suspense for negative reviews
    }
    return _selectHeadline(verdict, result);
  }
}

/// Global engine instance (singleton pattern)
final VexAIEngine vexEngine = VexAIEngine();
