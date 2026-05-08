// PROJECT_RULES §2 — Supabase table names and Edge Function endpoints
// All values are compile-time constants. URL values from --dart-define.
// GDD v6 — Alabaster Standard

abstract final class SupabaseConstants {
  // --- Core Player Tables ---
  static const String tablePlayers = 'players';
  static const String tableBrandState = 'brand_state';

  // --- Design & Atelier Tables ---
  static const String tableDesigns = 'designs';
  static const String tableGarmentDrops = 'garment_drops';

  // --- Mogul / Business Tables ---
  static const String tableStores = 'stores';
  static const String tableSupplyChain = 'supply_chain';
  static const String tableSuppliers = 'suppliers';
  static const String tableEquityPositions = 'equity_positions';
  static const String tableBrandsEquity = 'brands_equity';
  static const String tableLoans = 'loans';
  static const String tableCampaigns = 'campaigns';

  // --- Social Tables ---
  static const String tableFollows = 'follows';
  static const String tableFeedPosts = 'feed_posts';
  static const String tablePartnerships = 'partnerships';

  // --- Maison Tables ---
  static const String tableMaisons = 'maisons';
  static const String tableMaisonMembers = 'maison_members';
  static const String tableMaisonTreasuryLedger = 'maison_treasury_ledger';

  // --- Event & Gameplay Tables ---
  static const String tableEvents = 'events';
  static const String tablePlayerEvents = 'player_events';
  static const String tableTalent = 'talent';

  // --- Monetization Tables ---
  static const String tableIapReceipts = 'iap_receipts';

  // --- System Tables ---
  static const String tablePlayerReports = 'player_reports';
  static const String tableIdleIncomeLog = 'idle_income_log';

  // --- Phase 6: The Trend Tsunami (GDD v6 §3) ---
  static const String tableTrendTsunamis = 'trend_tsunamis';
  static const String tableTrendTsunamiArchive = 'trend_tsunami_archive';

  // --- Phase 7: Maison District Warfare (GDD v6) ---
  static const String tableFashionDistricts = 'fashion_districts';
  static const String tableDistrictLegacyWatermarks = 'district_legacy_watermarks';
  static const String tableDistrictTakeoverLog = 'district_takeover_log';

  // --- Phase 8: Aurelian Ascension (GDD v6 §3.5) ---
  static const String tableHallOfSovereigns = 'hall_of_sovereigns';

  // --- Storage Buckets ---
  static const String bucketAvatars = 'avatars';
  static const String bucketDesigns = 'designs';
  static const String bucketFeedMedia = 'feed_media';
  static const String bucketReportScreenshots = 'report_screenshots';

  // --- Edge Function Names ---
  static const String fnCalculateIdleIncome = 'calculate-idle-income';
  static const String fnMintDesign = 'mint-design';
  static const String fnProcessTransaction = 'process-transaction';
  static const String fnMaisonDonate = 'maison-donate';
  static const String fnValidateIap = 'validate-iap';
  static const String fnAttemptDistrictTakeover = 'attempt_district_takeover';
  static const String fnEclipseEventTick = 'eclipse-event-tick';
  static const String fnTrendDecay = 'trend-decay';

  // --- RPC Functions ---
  static const String fnCalculateTrendTsunami = 'calculate_global_trend_tsunami';
  static const String fnUnlockJointVenture = 'unlock_joint_venture';
  static const String fnExecuteMemorialization = 'execute_memorialization';
  static const String fnGetSovereignMultiplier = 'get_sovereign_multiplier';
  static const String fnExecuteSovereignGenesis = 'execute_sovereign_genesis';
  
  // --- Directive H: Crisis Engine RPCs ---
  static const String fnApplyKintsugiRepair = 'apply_kintsugi_repair';
  static const String fnApplyPublicApology = 'apply_public_apology';
  static const String fnTriggerScandal = 'trigger_scandal';
  
  // --- Directive I: Sovereign Talent RPCs ---
  static const String fnExecuteCastingPull = 'execute_casting_pull';
  
  // --- Directive J: Aurelian Gala RPCs ---
  static const String fnSubmitToGala = 'submit_to_gala';
  static const String fnCastGalaVote = 'cast_gala_vote';
  static const String fnGetGalaLeaderboard = 'get_gala_leaderboard';
  
  // --- Directive K: The Archive RPCs ---
  static const String fnExecuteArchivePurchase = 'execute_archive_purchase';
  static const String fnListOnArchive = 'list_on_archive';
  static const String fnCancelArchiveListing = 'cancel_archive_listing';
  
  // --- Directive L: Supply Chain RPCs ---
  static const String fnProcessIdleIncome = 'process_idle_income';
  static const String fnExecuteLiquidation = 'execute_liquidation';
  static const String fnUpgradeLogistics = 'upgrade_logistics';
  
  // --- Directive M: The Aurelian Storefront RPCs ---
  static const String fnVerifyAndGrantLuxe = 'verify_and_grant_luxe';
  static const String fnRecordFailedTransaction = 'record_failed_transaction';
  
  // --- Directive N: Telemetry & Retention RPCs ---
  static const String fnRecordCheckIn = 'record_check_in';
  static const String fnLogTelemetryEvent = 'log_telemetry_event';
  static const String fnBatchLogTelemetry = 'batch_log_telemetry';
  static const String fnDetectEconomyAnomaly = 'detect_economy_anomaly';
  static const String fnRegisterFcmToken = 'register_fcm_token';
  
  // --- Tables ---
  static const String tableFiatTransactions = 'fiat_transactions';
  static const String tableTelemetryEvents = 'telemetry_events';
  static const String tableDailyCheckIns = 'daily_check_ins';
  static const String tableFcmTokens = 'fcm_tokens';

  // --- Realtime Channels ---
  static const String channelFeed = 'public:feed_posts';
  static const String channelEquityTicker = 'public:brands_equity';
  static const String channelMaisonTreasury = 'public:maisons';
  static const String channelTrendTsunami = 'public:trend_tsunamis';
}
