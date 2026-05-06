// Abstract repository interface — economy / transactions
// PROJECT_RULES §3 — ALL economy mutations go through Edge Functions.
// This interface is read-only for client; writes are via Edge Function calls.

import '../models/brand.dart';
import '../models/campaign.dart';
import '../models/equity.dart';
import '../models/store.dart';

abstract interface class EconomyRepository {
  Future<Brand?> fetchBrandState(String playerId);
  Stream<Brand> watchBrandState(String playerId);

  Future<List<Store>> fetchStores(String playerId);
  Future<List<Campaign>> fetchCampaigns(String playerId);

  Future<BrandEquity?> fetchBrandEquity(String brandId);
  Future<List<EquityPosition>> fetchEquityPositions(String holderId);
  Stream<BrandEquity> watchEquityTicker(String brandId);
}
