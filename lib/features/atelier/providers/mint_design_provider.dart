// GDD §4.1 — Mint Alpha design via server-authoritative Edge Function.
// FutureProvider.family: parameterised by fabricColorHex string.
// Each unique hex param gets its own provider; disposes when no longer watched.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/design.dart';

final FutureProviderFamily<Design, String> mintDesignProvider =
    FutureProvider.family<Design, String>(
  (Ref<AsyncValue<Design>> ref, String fabricColorHex) async {
    final Map<String, dynamic> response = await SupabaseService.invokeFunction(
      SupabaseConstants.fnMintDesign,
      body: <String, dynamic>{'fabric_color_hex': fabricColorHex},
    );
    return Design.fromJson(response);
  },
);
