import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/providers/active_player_provider.dart';
import 'package:the_styliste/core/theme/styliste_visual_mode.dart';
import 'package:the_styliste/core/widgets/glass_metric_card.dart';
import 'package:the_styliste/core/widgets/styliste_scaffold.dart';
import 'package:the_styliste/domain/models/brand.dart';
import 'package:the_styliste/domain/models/player.dart';
import 'package:the_styliste/features/ftue/providers/first_objective_provider.dart';
import 'package:the_styliste/features/ftue/repositories/first_objective_repository.dart';
import 'package:the_styliste/features/hq/providers/hq_provider.dart';
import 'package:the_styliste/features/hq/widgets/hq_architect_view.dart';
import 'package:the_styliste/features/hq/widgets/hq_artisan_view.dart';
import 'package:the_styliste/features/supply_chain/models/supply_chain_models.dart';
import 'package:the_styliste/features/supply_chain/providers/supply_chain_provider.dart';

void main() {
  testWidgets('Artisan HQ uses editorialLight mode and renders foundation UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _hqHarness(child: HqArtisanView(player: _player(CareerPath.designer))),
    );
    await tester.pump();
    await tester.pump();

    final AurelianScaffold scaffold =
        tester.widget<AurelianScaffold>(find.byType(AurelianScaffold));
    expect(scaffold.mode, StylisteVisualMode.editorialLight);
    expect(find.byType(GlassMetricCard), findsWidgets);
    expect(find.text('FIRST OBJECTIVE'), findsOneWidget);
  });

  testWidgets('Architect HQ uses executiveObsidian mode and renders metrics', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _hqHarness(child: HqArchitectView(player: _player(CareerPath.mogul))),
    );
    await tester.pump();
    await tester.pump();

    final AurelianScaffold scaffold =
        tester.widget<AurelianScaffold>(find.byType(AurelianScaffold));
    expect(scaffold.mode, StylisteVisualMode.executiveObsidian);
    expect(find.byType(GlassMetricCard), findsWidgets);
    expect(find.text('FIRST OBJECTIVE'), findsOneWidget);
  });

  testWidgets('both HQ lenses survive 320px portrait at large text', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final CareerPath path in CareerPath.values) {
      final Widget view = path == CareerPath.designer
          ? HqArtisanView(player: _player(path))
          : HqArchitectView(player: _player(path));
      await tester.pumpWidget(
        _hqHarness(
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 700),
              textScaler: TextScaler.linear(2),
            ),
            child: view,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('EQUAL GAMEPLAY CEILING'), findsWidgets);
      expect(tester.takeException(), isNull, reason: path.name);
    }
  });

  testWidgets('brand projection errors stay inside player-safe metric states', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _hqHarness(
        child: HqArtisanView(player: _player(CareerPath.designer)),
        brandStream: Stream<Brand>.error(
          const FormatException('projection fixture rejected'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Projection unavailable'), findsNWidgets(3));
    expect(find.textContaining('FormatException'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Widget _hqHarness({
  required Widget child,
  Stream<Brand>? brandStream,
}) {
  final Player designer = _player(CareerPath.designer);
  final Brand brand = _brand();

  return ProviderScope(
    overrides: <Override>[
      activeUidProvider.overrideWith((Ref ref) => designer.id),
      firstObjectiveRepositoryProvider.overrideWith(
        (Ref ref) => const _FakeFirstObjectiveRepository(),
      ),
      hqPlayerStreamProvider.overrideWith(
        (Ref ref) => Stream<Player>.value(designer),
      ),
      hqBrandStreamProvider.overrideWith(
        (Ref ref) => brandStream ?? Stream<Brand>.value(brand),
      ),
      latestAlphaDropProvider.overrideWith(
        (Ref ref) async => const LatestAlphaDropSummary(
          feedPostId: 'drop-1',
          designName: 'Obsidian Bias',
          hypeScore: 84.0,
          marketReaction: 'Rising',
          followersDelta: 12,
        ),
      ),
      supplyChainProvider.overrideWith(
        (Ref ref) => Stream<SupplyChainState>.value(
          const SupplyChainState(currentInventoryValue: 1200),
        ),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

Player _player(CareerPath path) {
  return Player(
    id: 'player-1',
    brandName: 'Aurelian',
    path: path,
    hqCity: HqCity.kingston,
    brandRank: 7,
    onboardingComplete: true,
  );
}

Brand _brand() {
  return const Brand(
    playerId: 'player-1',
    heat: 72,
    hypeScore: 4200,
    followers: 12800,
    idleRevenuePerHour: 860,
    totalRevenue: 124000,
  );
}

class _FakeFirstObjectiveRepository implements FirstObjectiveRepository {
  const _FakeFirstObjectiveRepository();

  @override
  Future<bool> hasServerConfirmedAlphaDrop(String playerId) async => false;

  @override
  Future<bool> hasServerConfirmedStarterStore(String playerId) async => false;

  @override
  Stream<List<FirstWeekObjective>> watchObjectives(String playerId) {
    return Stream<List<FirstWeekObjective>>.value(
      const <FirstWeekObjective>[],
    );
  }

  @override
  Future<void> recordValidatedEvent(
    String eventKey, {
    String? entityId,
  }) async {}
}
