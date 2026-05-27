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
        unawaited(
          _prepareRealtimeForAuthEvent(state.event).then((_) {
            if (!controller.isClosed) {
              controller.add(++revision);
            }
          }).catchError((Object error) {
            if (!controller.isClosed) {
              controller.addError(_safeSessionError(error));
            }
          }),
        );
      }
    },
    onError: (Object error) {
      controller.addError(_safeSessionError(error));
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
  controller.add(
    SupabaseService.hasFreshSession
        ? SupabaseService.client.auth.currentUser?.id
        : null,
  );

  final StreamSubscription<AuthState> subscription =
      SupabaseService.client.auth.onAuthStateChange.listen(
    (AuthState state) {
      if (_shouldRecreateRealtimeStreams(state.event)) {
        if (state.event == AuthChangeEvent.signedOut) {
          controller.add(null);
          return;
        }
        unawaited(
          SupabaseService.ensureFreshSession().then((Session session) {
            if (!controller.isClosed) {
              controller.add(session.user.id);
            }
          }).catchError((Object error) {
            if (!controller.isClosed) {
              controller.addError(_safeSessionError(error));
            }
          }),
        );
      }
    },
    onError: (Object error) {
      controller.addError(_safeSessionError(error));
    },
  );

  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });

  return controller.stream.distinct();
});

final Provider<String> activeUidProvider = Provider<String>((Ref ref) {
  final AsyncValue<Session> session =
      ref.watch(supabaseRealtimeSessionProvider);
  return session.maybeWhen(
    data: (Session session) => session.user.id,
    orElse: () => '',
  );
});

Future<void> _prepareRealtimeForAuthEvent(AuthChangeEvent event) async {
  if (event == AuthChangeEvent.signedOut) {
    await SupabaseService.cleanupRealtimeChannels();
    return;
  }

  if (event == AuthChangeEvent.signedIn ||
      event == AuthChangeEvent.tokenRefreshed ||
      event == AuthChangeEvent.userUpdated) {
    await SupabaseService.recreateRealtimeChannels();
    return;
  }

  if (event == AuthChangeEvent.initialSession) {
    await SupabaseService.ensureFreshSession();
  }
}

Object _safeSessionError(Object error) {
  return SupabaseService.isRecoverableAuthError(error)
      ? const SupabaseSessionExpiredException()
      : error;
}

bool _shouldRecreateRealtimeStreams(AuthChangeEvent event) {
  return event == AuthChangeEvent.initialSession ||
      event == AuthChangeEvent.signedIn ||
      event == AuthChangeEvent.tokenRefreshed ||
      event == AuthChangeEvent.userUpdated ||
      event == AuthChangeEvent.signedOut;
}
