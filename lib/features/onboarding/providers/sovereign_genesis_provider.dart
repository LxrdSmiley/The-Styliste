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
      success: row['success'] == true || row['status'] == 'initialized',
      message: (row['message'] ?? row['status']) as String?,
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
    final Map<String, dynamic> rpcResult = await SupabaseService.invokeFunction(
      SupabaseConstants.fnFounderTrial,
      body: <String, dynamic>{
        'action': 'initialize',
        'brand_name': request.brandName,
        'career_path': request.careerPath,
        'idempotency_key': request.userId,
      },
    );

    return SovereignGenesisResult.fromRpc(rpcResult);
  }
}
