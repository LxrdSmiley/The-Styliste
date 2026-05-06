// PROJECT_RULES §2 — Supabase table names and Edge Function endpoints
// All values are compile-time constants. URL values from --dart-define.

abstract final class SupabaseConstants {
  // --- Table Names ---
  static const String tablePlayers = 'players';
  static const String tableBrandState = 'brand_state';
  static const String tableDesigns = 'designs';
  static const String tableStores = 'stores';
  static const String tableSupplyChain = 'supply_chain';
  static const String tableSuppliers = 'suppliers';
  static const String tableEquityPositions = 'equity_positions';
  static const String tableBrandsEquity = 'brands_equity';
  static const String tableFollows = 'follows';
  static const String tableMaisons = 'maisons';
  static const String tableMaisonMembers = 'maison_members';
  static const String tableMaisonTreasuryLedger = 'maison_treasury_ledger';
  static const String tableIapReceipts = 'iap_receipts';
  static const String tableFeedPosts = 'feed_posts';
  static const String tablePartnerships = 'partnerships';
  static const String tableCampaigns = 'campaigns';
  static const String tableEvents = 'events';
  static const String tablePlayerEvents = 'player_events';
  static const String tableLoans = 'loans';
  static const String tableTalent = 'talent';
  static const String tablePlayerReports = 'player_reports';
  static const String tableIdleIncomeLog = 'idle_income_log';

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
  static const String fnEclipseEventTick = 'eclipse-event-tick';
  static const String fnTrendDecay = 'trend-decay';

  // --- Realtime Channels ---
  static const String channelFeed = 'public:feed_posts';
  static const String channelEquityTicker = 'public:brands_equity';
  static const String channelMaisonTreasury = 'public:maisons';
}
