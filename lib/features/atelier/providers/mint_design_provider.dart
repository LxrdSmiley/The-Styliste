// GDD §4.1 — Mint Alpha design via server-authoritative Edge Function.
// FutureProvider.family: parameterised by the full pre-mint design brief.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/design.dart';

class MintDesignInput {
  const MintDesignInput({
    required this.fabricColorHex,
    required this.styleTags,
    this.materialQuality = 72,
    this.aestheticAlignment = 78,
  });

  final String fabricColorHex;
  final List<String> styleTags;
  final int materialQuality;
  final int aestheticAlignment;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MintDesignInput) return false;
    if (fabricColorHex != other.fabricColorHex ||
        materialQuality != other.materialQuality ||
        aestheticAlignment != other.aestheticAlignment ||
        styleTags.length != other.styleTags.length) {
      return false;
    }
    for (int i = 0; i < styleTags.length; i++) {
      if (styleTags[i] != other.styleTags[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        fabricColorHex,
        materialQuality,
        aestheticAlignment,
        Object.hashAll(styleTags),
      );
}

final FutureProviderFamily<Design, MintDesignInput> mintDesignProvider =
    FutureProvider.family<Design, MintDesignInput>(
  (Ref<AsyncValue<Design>> ref, MintDesignInput input) async {
    final Map<String, dynamic> response = await SupabaseService.invokeFunction(
      SupabaseConstants.fnMintDesign,
      body: <String, dynamic>{
        'fabric_color_hex': input.fabricColorHex,
        'material_quality': input.materialQuality,
        'aesthetic_alignment': input.aestheticAlignment,
        'style_tags': input.styleTags,
      },
    );
    return Design.fromJson(response);
  },
);
