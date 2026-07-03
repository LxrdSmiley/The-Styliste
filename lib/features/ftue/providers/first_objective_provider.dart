import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/active_player_provider.dart';
import '../../../core/router/app_router.dart';
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
    if ((!state.feedVisited && !state.ledgerOpened) || state.returnedToHq) {
      return;
    }
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
    final FirstObjectiveMarkers markers =
        ref.watch(firstObjectiveActionsProvider);

    if (player.path == CareerPath.designer) {
      final String activeUid = ref.watch(activeUidProvider);
      final FirstObjectiveRepository repository =
          ref.watch(firstObjectiveRepositoryProvider);
      final bool hasServerConfirmedAlphaDrop = activeUid.isNotEmpty &&
          await repository.hasServerConfirmedAlphaDrop(activeUid);
      final bool designerComplete =
          hasServerConfirmedAlphaDrop && markers.returnedToHq;
      final bool needsHqReturn =
          hasServerConfirmedAlphaDrop && !markers.returnedToHq;
      return FirstObjectiveState(
        playerId: activeUid.isEmpty ? player.id : activeUid,
        path: player.path,
        title: 'Launch your first Alpha Drop',
        description:
            'Open Atelier, mint an Alpha, drop it to Feed, then return HQ.',
        progressLabel: designerComplete ? '1/1' : '0/1',
        ctaLabel: needsHqReturn ? 'Return HQ' : 'Open Atelier',
        ctaRoute: needsHqReturn ? AppRouter.hq : AppRouter.atelier,
        isComplete: designerComplete,
      );
    }

    final FirstObjectiveRepository repository =
        ref.watch(firstObjectiveRepositoryProvider);
    final bool hasServerConfirmedStarterStore =
        await repository.hasServerConfirmedStarterStore(player.id);
    final bool mogulComplete =
        hasServerConfirmedStarterStore && markers.returnedToHq;
    final bool needsHqReturn =
        hasServerConfirmedStarterStore && !markers.returnedToHq;

    return FirstObjectiveState(
      playerId: player.id,
      path: player.path,
      title: 'Open your first store',
      description: 'Open Ledger, launch a starter store, then return HQ.',
      progressLabel: mogulComplete ? '1/1' : '0/1',
      ctaLabel: needsHqReturn ? 'Return HQ' : 'Open Ledger',
      ctaRoute: needsHqReturn ? AppRouter.hq : AppRouter.ledger,
      isComplete: mogulComplete,
    );
  },
);
