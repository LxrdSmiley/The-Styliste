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
      return FirstObjectiveState(
        playerId: activeUid.isEmpty ? player.id : activeUid,
        path: player.path,
        title: 'Mint your first Alpha Drop',
        description: 'Open the Atelier, mint an Alpha, then drop it to Feed.',
        progressLabel: hasServerConfirmedAlphaDrop ? '1/1' : '0/1',
        ctaLabel: 'Open Atelier',
        ctaRoute: AppRouter.atelier,
        isComplete: hasServerConfirmedAlphaDrop,
      );
    }

    final bool mogulComplete =
        markers.ledgerOpened && markers.feedVisited && markers.returnedToHq;
    final String ctaLabel = markers.ledgerOpened && !markers.feedVisited
        ? 'Check Feed'
        : 'Open Ledger';
    final String ctaRoute = markers.ledgerOpened && !markers.feedVisited
        ? AppRouter.feed
        : AppRouter.ledger;

    return FirstObjectiveState(
      playerId: player.id,
      path: player.path,
      title: 'Review your first empire move',
      description: 'Open the Ledger, review your economy, then check Feed.',
      progressLabel: mogulComplete ? '1/1' : '0/1',
      ctaLabel: ctaLabel,
      ctaRoute: ctaRoute,
      isComplete: mogulComplete,
    );
  },
);
