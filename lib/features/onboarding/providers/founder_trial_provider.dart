import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/services/supabase_service.dart';

enum FounderTrialStage {
  notStarted,
  sharedStarterGarment,
  artisanSample,
  architectSample,
  resultVisible,
  revisionOrBusinessResponse,
  completed,
}

FounderTrialStage _stageFromApi(Object? value) {
  return switch (value) {
    'shared_starter_garment' => FounderTrialStage.sharedStarterGarment,
    'artisan_sample' => FounderTrialStage.artisanSample,
    'architect_sample' => FounderTrialStage.architectSample,
    'result_visible' => FounderTrialStage.resultVisible,
    'revision_or_business_response' =>
      FounderTrialStage.revisionOrBusinessResponse,
    'specialization_selected' ||
    'main_quest_handoff' ||
    'completed' =>
      FounderTrialStage.completed,
    _ => FounderTrialStage.notStarted,
  };
}

class FounderTrialState {
  const FounderTrialState({
    this.stage = FounderTrialStage.notStarted,
    this.nextAction,
    this.specialization,
    this.receiptId,
    this.restored = false,
    this.isSubmitting = false,
    this.error,
  });

  final FounderTrialStage stage;
  final String? nextAction;
  final String? specialization;
  final String? receiptId;
  final bool restored;
  final bool isSubmitting;
  final String? error;

  FounderTrialState copyWith({
    FounderTrialStage? stage,
    String? nextAction,
    String? specialization,
    String? receiptId,
    bool? restored,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return FounderTrialState(
      stage: stage ?? this.stage,
      nextAction: nextAction ?? this.nextAction,
      specialization: specialization ?? this.specialization,
      receiptId: receiptId ?? this.receiptId,
      restored: restored ?? this.restored,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

abstract interface class FounderTrialGateway {
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent);
}

final Provider<FounderTrialGateway> founderTrialGatewayProvider =
    Provider<FounderTrialGateway>(
  (Ref _) => _SupabaseFounderTrialGateway(),
);

final class _SupabaseFounderTrialGateway implements FounderTrialGateway {
  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> intent) {
    return SupabaseService.invokeFunction(
      SupabaseConstants.fnFounderTrial,
      body: intent,
    );
  }
}

class FounderTrialNotifier extends StateNotifier<FounderTrialState> {
  FounderTrialNotifier(this._gateway) : super(const FounderTrialState());

  final FounderTrialGateway _gateway;
  final Uuid _uuid = const Uuid();
  final Map<String, String> _idempotencyKeys = <String, String>{};
  String? _lastOperation;
  Map<String, dynamic>? _lastPayload;

  Future<void> initialize({required String brandName}) {
    return _submit(
      operation: 'initialize',
      payload: <String, dynamic>{
        'action': 'initialize',
        'brand_name': brandName.trim(),
      },
    );
  }

  Future<void> chooseArtisanSample(String choice) {
    return _advance(
      operation: 'complete_artisan_sample',
      nextStage: 'complete_artisan_sample',
      field: 'artisan_choice',
      value: choice,
    );
  }

  Future<void> chooseArchitectSample(String choice) {
    return _advance(
      operation: 'complete_architect_sample',
      nextStage: 'complete_architect_sample',
      field: 'architect_choice',
      value: choice,
    );
  }

  Future<void> revealSharedResult() {
    return _advance(
      operation: 'reveal_shared_result',
      nextStage: 'reveal_shared_result',
    );
  }

  Future<void> chooseResponse(String choice) {
    return _advance(
      operation: 'choose_revision_or_business_response',
      nextStage: 'choose_revision_or_business_response',
      field: 'response_choice',
      value: choice,
    );
  }

  Future<void> chooseSpecialization(String specialization) {
    return _advance(
      operation: 'select_founder_path',
      nextStage: 'select_founder_path',
      field: 'specialization',
      value: specialization,
    );
  }

  Future<void> retry() {
    final String? operation = _lastOperation;
    final Map<String, dynamic>? payload = _lastPayload;
    if (operation == null || payload == null) return Future<void>.value();
    return _submit(
      operation: operation,
      payload: Map<String, dynamic>.from(payload),
    );
  }

  Future<void> _advance({
    required String operation,
    required String nextStage,
    String? field,
    String? value,
  }) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'action': 'advance',
      'next_stage': nextStage,
    };
    if (field != null && value != null) payload[field] = value;
    return _submit(operation: operation, payload: payload);
  }

  Future<void> _submit({
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    if (state.isSubmitting) return;
    _lastOperation = operation;
    _lastPayload = Map<String, dynamic>.from(payload);
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final String idempotencyKey = _idempotencyKeys.putIfAbsent(
        operation,
        _uuid.v4,
      );
      final Map<String, dynamic> result = await _gateway.submit(
        <String, dynamic>{
          ...payload,
          'idempotency_key': idempotencyKey,
        },
      );
      final String status = result['status'] as String? ?? '';
      state = FounderTrialState(
        stage: _stageFromApi(result['stage']),
        nextAction: result['next_action'] as String?,
        specialization: result['specialization'] as String?,
        receiptId: result['idempotency_key'] as String? ?? idempotencyKey,
        restored: status == 'resumed',
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error:
            'Luxe could not confirm that step. Your Founder Trial is safe; retry when you are ready.',
      );
    }
  }
}

final StateNotifierProvider<FounderTrialNotifier, FounderTrialState>
    founderTrialProvider =
    StateNotifierProvider<FounderTrialNotifier, FounderTrialState>(
  (Ref ref) => FounderTrialNotifier(ref.watch(founderTrialGatewayProvider)),
);
