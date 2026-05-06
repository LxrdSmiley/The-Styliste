// GDD §3.3 — Idle Engine Riverpod provider
// Owns the IdleEngineService lifecycle (create, dispose).
// State: last IdleIncomeResult from the edge function, or null before first call.
// Watched in HqArchitectView + HqArtisanView to surface earned deltas.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/idle_engine_service.dart';

class IdleEngineNotifier extends StateNotifier<IdleIncomeResult?> {
  IdleEngineNotifier(Ref<IdleIncomeResult?> ref) : super(null) {
    _service = IdleEngineService(
      onResult: (IdleIncomeResult result) {
        // Guard: do not set state after disposal (timer could fire during teardown).
        if (mounted) state = result;
      },
    );
    ref.onDispose(_service.dispose);
  }

  late final IdleEngineService _service;

  // Expose for testing / manual trigger if needed.
  IdleEngineService get service => _service;
}

final StateNotifierProvider<IdleEngineNotifier, IdleIncomeResult?>
    idleEngineProvider =
    StateNotifierProvider<IdleEngineNotifier, IdleIncomeResult?>(
  (Ref<IdleIncomeResult?> ref) => IdleEngineNotifier(ref),
);
