import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/active_player_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/supabase_service.dart';
import '../../../domain/models/player.dart';
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
    final AsyncValue<List<FirstWeekObjective>> objectivesAsync =
        ref.watch(firstWeekObjectivesStreamProvider(playerId));
    final List<FirstWeekObjective> objectives =
        objectivesAsync.valueOrNull ?? const <FirstWeekObjective>[];
    final List<String> sequence = player.path == CareerPath.designer
        ? <String>[
            'designer_first_design',
            'designer_first_drop',
            'designer_react_to_result',
            'shared_feed_participation',
          ]
        : <String>[
            'mogul_first_store',
            'mogul_first_store_decision',
            'mogul_react_to_sales',
            'shared_feed_participation',
          ];
    final List<FirstWeekObjective> ordered = sequence
        .map(
          (String key) => objectives.where(
            (FirstWeekObjective objective) => objective.objectiveKey == key,
          ),
        )
        .expand((Iterable<FirstWeekObjective> matches) => matches)
        .toList(growable: false);
    final int completed = ordered
        .where((FirstWeekObjective objective) => objective.isComplete)
        .length;
    FirstWeekObjective? next;
    for (final FirstWeekObjective objective in ordered) {
      if (!objective.isComplete) {
        next = objective;
        break;
      }
    }
    final FirstWeekObjective fallback = FirstWeekObjective(
      playerId: playerId.isEmpty ? player.id : playerId,
      objectiveKey: sequence.first,
      path: player.path == CareerPath.designer ? 'designer' : 'mogul',
      title: player.path == CareerPath.designer
          ? 'Create your first design'
          : 'Open your first store',
      description: player.path == CareerPath.designer
          ? 'Make a design decision in the Atelier.'
          : 'Choose a city, format, and operating strategy.',
      status: 'pending',
    );
    final FirstWeekObjective current = next ?? fallback;
    final bool complete = ordered.isNotEmpty && completed == ordered.length;
    final String route = switch (current.objectiveKey) {
      'shared_feed_participation' ||
      'designer_react_to_result' =>
        AppRouter.feed,
      'designer_first_design' || 'designer_first_drop' => AppRouter.atelier,
      _ => AppRouter.ledger,
    };
    final String cta = switch (current.objectiveKey) {
      'shared_feed_participation' || 'designer_react_to_result' => 'Open Feed',
      'designer_first_design' => 'Open Atelier',
      'designer_first_drop' => 'Release Drop',
      'mogul_first_store' => 'Open Ledger',
      'mogul_first_store_decision' => 'Set Strategy',
      _ => 'Review Ledger',
    };
    return FirstObjectiveState(
      playerId: current.playerId,
      path: player.path,
      title: current.title,
      description: current.description,
      progressLabel:
          '$completed/${ordered.isEmpty ? sequence.length : ordered.length}',
      ctaLabel: cta,
      ctaRoute: route,
      isComplete: complete,
    );
  },
);
