import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

final StreamProvider<int> supabaseAuthRevisionProvider =
    StreamProvider<int>((Ref ref) {
  final StreamController<int> controller = StreamController<int>();
  int revision = 0;
  controller.add(revision);

  final StreamSubscription<AuthState> subscription =
      SupabaseService.client.auth.onAuthStateChange.listen(
    (AuthState state) {
      if (_shouldRecreateRealtimeStreams(state.event)) {
        controller.add(++revision);
      }
    },
    onError: (Object error) {
      controller.addError(
        SupabaseService.isRecoverableAuthError(error)
            ? const SupabaseSessionExpiredException()
            : error,
      );
    },
  );

  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });

  return controller.stream;
});

final FutureProvider<Session> supabaseRealtimeSessionProvider =
    FutureProvider<Session>((Ref ref) async {
  ref.watch(supabaseAuthRevisionProvider);
  return SupabaseService.ensureFreshSession();
});

final StreamProvider<String?> supabaseUserIdProvider =
    StreamProvider<String?>((Ref ref) {
  final StreamController<String?> controller = StreamController<String?>();
  controller.add(SupabaseService.client.auth.currentUser?.id);

  final StreamSubscription<AuthState> subscription =
      SupabaseService.client.auth.onAuthStateChange.listen(
    (AuthState state) {
      if (_shouldRecreateRealtimeStreams(state.event)) {
        controller.add(state.session?.user.id);
      }
    },
    onError: (Object error) {
      controller.addError(
        SupabaseService.isRecoverableAuthError(error)
            ? const SupabaseSessionExpiredException()
            : error,
      );
    },
  );

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
    orElse: () => SupabaseService.client.auth.currentUser?.id ?? '',
  );
});

bool _shouldRecreateRealtimeStreams(AuthChangeEvent event) {
  return event == AuthChangeEvent.initialSession ||
      event == AuthChangeEvent.signedIn ||
      event == AuthChangeEvent.tokenRefreshed ||
      event == AuthChangeEvent.userUpdated ||
      event == AuthChangeEvent.signedOut;
}
