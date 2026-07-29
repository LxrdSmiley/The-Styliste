import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/active_player_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/player.dart';
import '../../capsule/models/kingston_capsule.dart';
import '../../capsule/providers/capsule_foundation_provider.dart';
import '../repositories/first_objective_repository.dart';

class FirstObjectiveMarkers {
  const FirstObjectiveMarkers({
    this.atelierOpened = false,
    this.ledgerOpened = false,
    this.feedVisited = false,
    this.returnedToHq = false,
  });

  final bool atelierOpened;
  final bool ledgerOpened;
  final bool feedVisited;
  final bool returnedToHq;

  FirstObjectiveMarkers copyWith({
    bool? atelierOpened,
    bool? ledgerOpened,
    bool? feedVisited,
    bool? returnedToHq,
  }) {
    return FirstObjectiveMarkers(
      atelierOpened: atelierOpened ?? this.atelierOpened,
      ledgerOpened: ledgerOpened ?? this.ledgerOpened,
      feedVisited: feedVisited ?? this.feedVisited,
      returnedToHq: returnedToHq ?? this.returnedToHq,
    );
  }
}

class FirstObjectiveActions extends StateNotifier<FirstObjectiveMarkers> {
  FirstObjectiveActions() : super(const FirstObjectiveMarkers());

  void markAtelierOpened() {
    if (state.atelierOpened) return;
    state = state.copyWith(atelierOpened: true);
  }

  void markLedgerOpened() {
    if (state.ledgerOpened) return;
    state = state.copyWith(ledgerOpened: true);
  }

  void markFeedVisited() {
    if (state.feedVisited) return;
    state = state.copyWith(feedVisited: true);
  }

  void markReturnedToHq() {
    if (!state.feedVisited || state.returnedToHq) return;
    state = state.copyWith(returnedToHq: true);
  }
}

final StateNotifierProvider<FirstObjectiveActions, FirstObjectiveMarkers>
    firstObjectiveActionsProvider =
    StateNotifierProvider<FirstObjectiveActions, FirstObjectiveMarkers>(
  (Ref<FirstObjectiveMarkers> _) => FirstObjectiveActions(),
);

final Provider<FirstObjectiveRepository> firstObjectiveRepositoryProvider =
    Provider<FirstObjectiveRepository>(
  (Ref<FirstObjectiveRepository> _) => const SupabaseFirstObjectiveRepository(),
);

final StreamProviderFamily<List<FirstWeekObjective>, String>
    firstWeekObjectivesStreamProvider =
    StreamProvider.family<List<FirstWeekObjective>, String>(
  (Ref<AsyncValue<List<FirstWeekObjective>>> ref, String playerId) {
    if (playerId.isEmpty) return const Stream<List<FirstWeekObjective>>.empty();
    ref.watch(supabaseAuthRevisionProvider);
    return SupabaseService.guardRealtimeStream(
      ref.watch(firstObjectiveRepositoryProvider).watchObjectives(playerId),
    );
  },
);

class FirstObjectiveState {
  const FirstObjectiveState({
    required this.playerId,
    required this.path,
    required this.title,
    required this.description,
    required this.progressLabel,
    required this.ctaLabel,
    required this.ctaRoute,
    required this.isComplete,
  });

  final String playerId;
  final CareerPath path;
  final String title;
  final String description;
  final String progressLabel;
  final String ctaLabel;
  final String ctaRoute;
  final bool isComplete;
}

final FutureProviderFamily<FirstObjectiveState, Player> firstObjectiveProvider =
    FutureProvider.family<FirstObjectiveState, Player>(
  (Ref<AsyncValue<FirstObjectiveState>> ref, Player player) async {
    final String playerId = ref.watch(activeUidProvider);
    final CapsuleFoundationState capsuleState =
        ref.watch(capsuleFoundationProvider);
    final KingstonCapsule? capsule = capsuleState.capsule;
    final int completedLooks = capsule?.looks
            .where((KingstonCapsuleLook look) => look.isComplete)
            .length ??
        0;
    final bool briefConfirmed =
        capsule != null && capsule.stage != KingstonCapsuleStage.briefDraft;
    final int completedSteps = (briefConfirmed ? 1 : 0) + completedLooks;
    final bool complete = capsule?.samplingUnavailable ?? false;
    final String framing = player.path == CareerPath.designer
        ? 'Author the Collection Brief and shape all three garments. '
            'Your Artisan path changes the framing, not the gameplay ceiling.'
        : 'Position the Collection Brief and shape all three garments. '
            'Your Architect path changes the framing, not the gameplay ceiling.';

    return FirstObjectiveState(
      playerId: playerId.isEmpty ? player.id : playerId,
      path: player.path,
      title: complete
          ? 'Kingston capsule is ready for review'
          : 'Build your Kingston capsule',
      description: complete
          ? 'Readiness is server-confirmed. Sampling remains deliberately unavailable in Gate A.'
          : framing,
      progressLabel: complete ? '4/4' : '$completedSteps/4',
      ctaLabel: complete ? 'Review capsule' : 'Open capsule',
      ctaRoute: AppRouter.atelierCapsule,
      isComplete: complete,
    );
  },
);
