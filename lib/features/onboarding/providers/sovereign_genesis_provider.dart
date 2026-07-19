// GDD v7 §§19.2–19.3, 22 — Genesis remains server-authoritative.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';

final class SovereignGenesisRequest {
  const SovereignGenesisRequest({
    required this.userId,
    required this.brandName,
    required this.careerPath,
    required this.city,
    required this.marketTier,
    required this.avatarConfig,
  });

  final String userId;
  final String brandName;
  final String careerPath;
  final String city;
  final String marketTier;
  final Map<String, dynamic> avatarConfig;
}

final class SovereignGenesisResult {
  const SovereignGenesisResult({required this.success, this.message});

  final bool success;
  final String? message;

  factory SovereignGenesisResult.fromRpc(Object? rpcResult) {
    final Map<String, dynamic> row;
    if (rpcResult is Map<String, dynamic>) {
      row = rpcResult;
    } else if (rpcResult is List && rpcResult.isNotEmpty) {
      final Object? firstRow = rpcResult.first;
      if (firstRow is Map<String, dynamic>) {
        row = firstRow;
      } else if (firstRow is Map) {
        row = Map<String, dynamic>.from(firstRow);
      } else {
        throw StateError('Genesis returned an unexpected response.');
      }
    } else {
      throw StateError('Genesis returned an unexpected response.');
    }

    return SovereignGenesisResult(
      success: row['success'] == true,
      message: row['message'] as String?,
    );
  }
}

abstract interface class SovereignGenesisGateway {
  Future<SovereignGenesisResult> execute(SovereignGenesisRequest request);
}

final Provider<SovereignGenesisGateway> sovereignGenesisGatewayProvider =
    Provider<SovereignGenesisGateway>(
  (Ref<SovereignGenesisGateway> _) => _SupabaseSovereignGenesisGateway(),
);

final class _SupabaseSovereignGenesisGateway
    implements SovereignGenesisGateway {
  @override
  Future<SovereignGenesisResult> execute(
    SovereignGenesisRequest request,
  ) async {
    final Object? rpcResult = await SupabaseService.client.rpc(
      SupabaseConstants.fnExecuteSovereignGenesis,
      params: <String, dynamic>{
        'p_user_id': request.userId,
        'p_brand_name': request.brandName,
        'p_career_path': request.careerPath,
        'p_city': request.city,
        'p_market_tier': request.marketTier,
        'p_avatar_config': request.avatarConfig,
      },
    );

    return SovereignGenesisResult.fromRpc(rpcResult);
  }
}
