import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/features/gala/providers/gala_provider.dart';
import 'package:the_styliste/features/gala/services/gala_scoring_engine.dart';
import 'package:the_styliste/features/maison/providers/district_provider.dart';

void main() {
  test('district siege does not send a client authority mutation', () async {
    final DistrictSiegeNotifier notifier = DistrictSiegeNotifier();

    await notifier.initiateSiege(
      maisonId: 'maison-id',
      districtId: 'district-id',
      capitalBid: 500,
    );

    expect(notifier.state.isSieging, isFalse);
    expect(notifier.state.result, isNull);
    expect(notifier.state.errorMessage, kDistrictSiegesUnavailableMessage);
  });

  test('Gala vote submission remains locally quarantined', () async {
    final VoteCastingNotifier notifier = VoteCastingNotifier();

    await notifier.castVote('submission-id', VoteTier.adore);

    expect(notifier.state.isCasting, isFalse);
    expect(notifier.state.lastResult, isNull);
    expect(notifier.state.errorMessage, kGalaVotingUnavailableMessage);
  });
}
