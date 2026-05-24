import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final StreamProvider<String?> supabaseUserIdProvider =
    StreamProvider<String?>((Ref ref) {
  final StreamController<String?> controller = StreamController<String?>();
  controller.add(Supabase.instance.client.auth.currentUser?.id);

  final StreamSubscription<AuthState> subscription =
      Supabase.instance.client.auth.onAuthStateChange.listen((AuthState state) {
    controller.add(state.session?.user.id);
  });

  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });

  return controller.stream.distinct();
});

final Provider<String> activeUidProvider = Provider<String>((Ref ref) {
  final AsyncValue<String?> supabaseUid = ref.watch(supabaseUserIdProvider);
  return supabaseUid.maybeWhen(
    data: (String? uid) => uid ?? '',
    orElse: () => Supabase.instance.client.auth.currentUser?.id ?? '',
  );
});
