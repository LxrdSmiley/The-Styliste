// GDD §4.1 — Server-owned Atelier session and authoritative Alpha mint.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/design.dart';

class MintDesignInput {
  const MintDesignInput({
    required this.sessionId,
    required this.fabricColorHex,
    required this.styleTags,
  });

  final String sessionId;
  final String fabricColorHex;
  final List<String> styleTags;

  @override
  bool operator ==(Object other) =>
      other is MintDesignInput &&
      other.sessionId == sessionId &&
      other.fabricColorHex == fabricColorHex &&
      _sameTags(other.styleTags, styleTags);

  @override
  int get hashCode =>
      Object.hash(sessionId, fabricColorHex, Object.hashAll(styleTags));
}

bool _sameTags(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (int index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

Future<String> startAtelierSession({
  required String fabricColorHex,
  required List<String> styleTags,
}) async {
  final Map<String, dynamic> response = await SupabaseService.invokeFunction(
    SupabaseConstants.fnMintDesign,
    body: <String, dynamic>{
      'action': 'start',
      'fabric_color_hex': fabricColorHex,
      'style_tags': styleTags,
    },
  );
  final String? sessionId = response['session_id'] as String?;
  if (sessionId == null || sessionId.isEmpty) {
    throw const FormatException('Atelier session was not created.');
  }
  return sessionId;
}

final FutureProviderFamily<Design, MintDesignInput> mintDesignProvider =
    FutureProvider.family<Design, MintDesignInput>(
  (Ref<AsyncValue<Design>> ref, MintDesignInput input) async {
    final Map<String, dynamic> response = await SupabaseService.invokeFunction(
      SupabaseConstants.fnMintDesign,
      body: <String, dynamic>{
        'action': 'mint',
        'session_id': input.sessionId,
        'idempotency_key': input.sessionId,
      },
    );
    return Design.fromJson(response);
  },
);
