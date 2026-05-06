// GDD §3.1–3.4 — Game balance constants
// All economy thresholds are SERVER-AUTHORITATIVE; these constants are
// used for UI display only, never for server-side calculations.
// PROJECT_RULES §3 — Source of Truth: Database > Edge Functions > Local State > UI

abstract final class GameConstants {
  // --- Brand Rank (GDD §3.1) ---
  static const int maxBrandRank = 100;
  static const int minBrandRank = 1;

  // --- Idle Mechanics (GDD §3.3–3.4) ---
  /// Full-rate offline earnings window in hours
  static const int idleFullRateHours = 24;

  /// Decay floor: efficiency drops to this % after full-rate window
  static const double idleDecayFloor = 0.40;

  /// Momentum buff duration in hours after active session (GDD §3.4)
  static const int momentumBuffHours = 12;

  // --- XP Sources (GDD §3.2) ---
  static const double xpActiveRatio = 0.35;
  static const double xpIdleRatio = 0.35;
  static const double xpSocialRatio = 0.20;
  static const double xpEventRatio = 0.10;

  // --- Brand Rank Phase Boundaries (GDD §3.2) ---
  static const int earlyGameMaxRank = 25;
  static const int midGameMaxRank = 65;
  static const int lateGameMinRank = 66;

  // --- Maison City Dominance (GDD §6.3.3) ---
  static const double domainCaptureThreshold = 0.51;   // 51% market share
  static const double dominanceMaintainFloor = 0.45;   // grace period triggers below 45%
  static const int dominanceGracePeriodDays = 7;
  static const double rivalChallengeThreshold = 0.30;  // 30%+ share to declare challenge

  // --- Brand Heat Tiers (GDD §8.9.7) ---
  static const int heatCold = 25;
  static const int heatWarm = 50;
  static const int heatHot = 75;
  static const int heatIconic = 100;

  // --- Sustainability Certification Tiers (GDD §8.9.5) ---
  static const int sustainOrganicTier = 1;
  static const int sustainFairTradeTier = 2;
  static const int sustainCarbonNeutralTier = 3;
  static const int sustainRegenerativeTier = 4;

  // --- Equity / IPO (GDD §5.6) ---
  static const int ipoUnlockRank = 60;
  static const double hostileTakeoverThreshold = 0.51;
  static const double votingRightsThreshold = 0.10;

  // --- Mini-game Durations in seconds (GDD §5.7) ---
  static const int miniGameMinDuration = 8;
  static const int miniGameMaxDuration = 15;
  static const int flashSaleDuration = 60;

  // --- Supply Chain (GDD §5.1) ---
  static const double dealFailurePenaltyRevenue = -0.30;   // -30% idle revenue 24h
  static const double qualityDropHypePenalty = -0.15;      // -15% sell rate
  static const double maison10MemberDiscountQualifier = 10.0;

  // --- Follower Acquisition (GDD §8.11.1) ---
  static const int followersPerFeedInteractionMin = 1;
  static const int followersPerFeedInteractionMax = 10;
  static const int followersPerCoDropMin = 50;
  static const int followersPerCoDropMax = 300;
  static const int followersPerEventWinMin = 100;
  static const int followersPerEventWinMax = 1000;

  // --- AR Viral Moment (GDD §4.4) ---
  static const int arViralReactionThreshold = 100;
  static const double arViralFollowerBoost = 0.15;   // +15% global followers for 6h
  static const int arViralBoostDurationHours = 6;
}
