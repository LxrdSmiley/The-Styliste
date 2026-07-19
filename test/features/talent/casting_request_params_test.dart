import 'package:flutter_test/flutter_test.dart';

import 'package:the_styliste/features/talent/providers/casting_provider.dart';

void main() {
  test('Casting request does not accept a client-supplied player identity', () {
    final Map<String, dynamic> params =
        castingPullRequestParams(isTenPull: true);

    expect(params, <String, dynamic>{
      'p_banner_id': 'standard',
      'p_is_ten_pull': true,
    });
    expect(params, isNot(contains('p_player_id')));
  });
}
