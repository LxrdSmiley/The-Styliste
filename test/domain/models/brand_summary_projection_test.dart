import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/domain/models/brand.dart';

void main() {
  test('brand summary omits private fields without failing the HQ projection',
      () {
    final Brand brand = Brand.fromSummaryJson(<String, dynamic>{
      'player_id': 'player-1',
      'heat': 50,
      'hype_score': 0,
      'followers': 0,
      'house_funds': 0,
      'total_revenue': 0,
      'lifetime_gross_revenue': 0,
      'lifetime_costs': 0,
      'lifetime_net_result': 0,
      'idle_revenue_per_hour': 0,
      'idle_base_revenue_per_hour': 0,
      'idle_store_revenue_per_hour': 0,
      'momentum_buff_active': false,
      'momentum_buff_until': null,
      'last_active_at': '2026-07-29T22:00:00Z',
      'sustainability_tier': 0,
      'dpp_enabled': false,
      'dpp_fully_mapped': false,
      'founder_rep': 50,
      'current_tarnish': 0,
      'kintsugi_level': 0,
      'total_scandals_survived': 0,
      'market_tier': null,
      'warehouse_capacity': 5000,
      'current_inventory_value': 0,
      'logistics_level': 1,
    });

    expect(brand.playerId, 'player-1');
    expect(brand.heat, 50);
    expect(brand.hypeScore, 0);
    expect(brand.followers, 0);
    expect(brand.luxeTokens, 0);
    expect(brand.prestigeTokens, 0);
    expect(brand.avatarConfiguration, isNull);
    expect(brand.lastActiveAt, DateTime.utc(2026, 7, 29, 22));
  });

  test('brand summary safely coerces PostgREST numeric representations', () {
    final Brand brand = Brand.fromSummaryJson(<String, dynamic>{
      'player_id': 'player-1',
      'heat': 72.9,
      'hype_score': '4200.5',
      'followers': '12800',
      'idle_revenue_per_hour': 860,
      'total_revenue': '124000.25',
      'momentum_buff_active': 1,
      'sustainability_tier': '2',
      'dpp_enabled': 'true',
      'dpp_fully_mapped': false,
      'founder_rep': 60,
      'current_tarnish': 4,
      'kintsugi_level': 1,
      'total_scandals_survived': 2,
      'warehouse_capacity': '6000',
      'current_inventory_value': 1200,
      'logistics_level': 2,
    });

    expect(brand.heat, 72);
    expect(brand.hypeScore, 4200.5);
    expect(brand.followers, 12800);
    expect(brand.totalRevenue, 124000.25);
    expect(brand.momentumBuffActive, isTrue);
    expect(brand.dppEnabled, isTrue);
    expect(brand.warehouseCapacity, 6000);
  });
}
