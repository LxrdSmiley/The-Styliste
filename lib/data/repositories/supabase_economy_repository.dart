// Supabase implementation of EconomyRepository
// PROJECT_RULES §3 — Read-only client access. All mutations via Edge Functions.

import '../../core/constants/supabase_constants.dart';
import '../../core/services/supabase_service.dart';
import '../../domain/models/brand.dart';
import '../../domain/models/campaign.dart';
import '../../domain/models/equity.dart';
import '../../domain/models/store.dart';
import '../../domain/repositories/economy_repository.dart';

class SupabaseEconomyRepository implements EconomyRepository {
  const SupabaseEconomyRepository();

  @override
  Future<Brand?> fetchBrandState(String playerId) async {
    final Map<String, dynamic>? data = await SupabaseService.client
        .schema('api')
        .from('brand_summary')
        .select()
        .eq('player_id', playerId)
        .maybeSingle();

    return data != null ? Brand.fromJson(data) : null;
  }

  @override
  Stream<Brand> watchBrandState(String playerId) async* {
    // api.brand_summary is a security-invoker view, not a replication table.
    while (true) {
      final Brand? brand = await fetchBrandState(playerId);
      if (brand != null) yield brand;
      await Future<void>.delayed(const Duration(seconds: 30));
    }
  }

  @override
  Future<List<Store>> fetchStores(String playerId) async {
    final List<Map<String, dynamic>> data = await SupabaseService.client
        .schema('api')
        .from('store_summary')
        .select()
        .eq('player_id', playerId);

    return data.map((Map<String, dynamic> row) => Store.fromJson(row)).toList();
  }

  @override
  Future<List<Campaign>> fetchCampaigns(String playerId) async {
    final List<Map<String, dynamic>> data = await SupabaseService.client
        .from(SupabaseConstants.tableCampaigns)
        .select()
        .eq('player_id', playerId);

    return data
        .map((Map<String, dynamic> row) => Campaign.fromJson(row))
        .toList();
  }

  @override
  Future<BrandEquity?> fetchBrandEquity(String brandId) async {
    final Map<String, dynamic>? data = await SupabaseService.client
        .from(SupabaseConstants.tableBrandsEquity)
        .select()
        .eq('brand_id', brandId)
        .maybeSingle();

    return data != null ? BrandEquity.fromJson(data) : null;
  }

  @override
  Future<List<EquityPosition>> fetchEquityPositions(String holderId) async {
    final List<Map<String, dynamic>> data = await SupabaseService.client
        .from(SupabaseConstants.tableEquityPositions)
        .select()
        .eq('holder_id', holderId);

    return data
        .map((Map<String, dynamic> row) => EquityPosition.fromJson(row))
        .toList();
  }

  @override
  Stream<BrandEquity> watchEquityTicker(String brandId) {
    return SupabaseService.client
        .from(SupabaseConstants.tableBrandsEquity)
        .stream(primaryKey: <String>['brand_id'])
        .eq('brand_id', brandId)
        .where((List<Map<String, dynamic>> rows) => rows.isNotEmpty)
        .map(
          (List<Map<String, dynamic>> rows) => BrandEquity.fromJson(rows.first),
        );
  }
}
