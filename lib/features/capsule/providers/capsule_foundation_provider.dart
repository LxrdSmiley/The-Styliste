import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../models/kingston_capsule.dart';

enum CapsuleFoundationPhase {
  loading,
  empty,
  editing,
  submitting,
  confirmed,
  offline,
  retryableError,
  unavailable,
  restored,
}

class CapsuleFoundationState {
  const CapsuleFoundationState({
    this.phase = CapsuleFoundationPhase.loading,
    this.capsule,
    this.error,
  });

  final CapsuleFoundationPhase phase;
  final KingstonCapsule? capsule;
  final String? error;

  CapsuleFoundationState copyWith({
    CapsuleFoundationPhase? phase,
    KingstonCapsule? capsule,
    String? error,
    bool clearError = false,
  }) {
    return CapsuleFoundationState(
      phase: phase ?? this.phase,
      capsule: capsule ?? this.capsule,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

abstract interface class CapsuleFoundationGateway {
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent);
}

final Provider<CapsuleFoundationGateway> capsuleFoundationGatewayProvider =
    Provider<CapsuleFoundationGateway>(
  (Ref _) => _SupabaseCapsuleFoundationGateway(),
);

final class _SupabaseCapsuleFoundationGateway
    implements CapsuleFoundationGateway {
  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent) {
    return SupabaseService.invokeFunction(
      SupabaseConstants.fnCapsuleFoundation,
      body: intent,
    );
  }
}

class CapsuleFoundationNotifier extends StateNotifier<CapsuleFoundationState> {
  CapsuleFoundationNotifier(this._gateway)
      : super(const CapsuleFoundationState());

  final CapsuleFoundationGateway _gateway;
  final Uuid _uuid = const Uuid();
  final Map<String, _CapsuleIntent> _retryableIntents =
      <String, _CapsuleIntent>{};

  Future<void> restore() {
    return _submit(
      operation: 'initialize',
      payload: const <String, dynamic>{'action': 'initialize'},
      restoration: true,
    );
  }

  void beginEditing() {
    if (state.phase == CapsuleFoundationPhase.submitting ||
        state.phase == CapsuleFoundationPhase.unavailable) {
      return;
    }
    state = state.copyWith(
      phase: CapsuleFoundationPhase.editing,
      clearError: true,
    );
  }

  Future<void> saveBrief(CollectionBrief brief) {
    return _submit(
      operation: 'save_brief',
      payload: <String, dynamic>{
        'action': 'save_brief',
        'brief': brief.toJson(),
      },
    );
  }

  Future<void> saveLook({
    required String role,
    required CapsuleLookGrammar grammar,
  }) {
    return _submit(
      operation: 'save_look:$role',
      payload: <String, dynamic>{
        'action': 'save_look',
        'role': role,
        'grammar': grammar.toJson(),
      },
    );
  }

  Future<void> evaluateReadiness() {
    return _submit(
      operation: 'evaluate_readiness',
      payload: const <String, dynamic>{'action': 'evaluate_readiness'},
    );
  }

  Future<void> retry() async {
    final _CapsuleIntent? intent = _retryableIntents['last'];
    if (intent == null || state.phase == CapsuleFoundationPhase.submitting) {
      return;
    }
    await _submitIntent(intent, restoration: intent.restoration);
  }

  Future<void> _submit({
    required String operation,
    required Map<String, dynamic> payload,
    bool restoration = false,
  }) {
    final _CapsuleIntent intent = _retryableIntents.putIfAbsent(
      operation,
      () => _CapsuleIntent(
        payload: payload,
        idempotencyKey: _uuid.v4(),
        restoration: restoration,
      ),
    );
    _retryableIntents['last'] = intent;
    return _submitIntent(intent, restoration: restoration);
  }

  Future<void> _submitIntent(
    _CapsuleIntent intent, {
    required bool restoration,
  }) async {
    state = state.copyWith(
      phase: CapsuleFoundationPhase.submitting,
      clearError: true,
    );
    try {
      final Map<String, dynamic> receipt = await _gateway.submit(
        <String, dynamic>{
          ...intent.payload,
          'idempotency_key': intent.idempotencyKey,
        },
      );
      final KingstonCapsule capsule = KingstonCapsule.fromReceipt(receipt);
      final CapsuleFoundationPhase phase;
      if (capsule.samplingUnavailable) {
        phase = CapsuleFoundationPhase.unavailable;
      } else if (restoration && receipt['status'] == 'restored') {
        phase = CapsuleFoundationPhase.restored;
      } else if (receipt['status'] == 'initialized') {
        phase = CapsuleFoundationPhase.empty;
      } else {
        phase = CapsuleFoundationPhase.confirmed;
      }
      state = CapsuleFoundationState(phase: phase, capsule: capsule);
    } on Object catch (error) {
      final String safeMessage = SupabaseService.playerSafeErrorMessage(
        error,
        fallback:
            'Luxe could not confirm this capsule step. Your work is safe; retry when ready.',
      );
      state = state.copyWith(
        phase: safeMessage == SupabaseService.noInternetMessage
            ? CapsuleFoundationPhase.offline
            : CapsuleFoundationPhase.retryableError,
        error: safeMessage,
      );
    }
  }
}

class _CapsuleIntent {
  const _CapsuleIntent({
    required this.payload,
    required this.idempotencyKey,
    required this.restoration,
  });

  final Map<String, dynamic> payload;
  final String idempotencyKey;
  final bool restoration;
}

final StateNotifierProvider<CapsuleFoundationNotifier, CapsuleFoundationState>
    capsuleFoundationProvider =
    StateNotifierProvider<CapsuleFoundationNotifier, CapsuleFoundationState>(
  (Ref ref) => CapsuleFoundationNotifier(
    ref.watch(capsuleFoundationGatewayProvider),
  ),
);
