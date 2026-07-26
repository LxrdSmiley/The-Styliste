import 'package:flutter_test/flutter_test.dart';
import 'package:the_styliste/core/services/supabase_service.dart';

void main() {
  group('Supabase session error classification', () {
    test('invalid refresh tokens require explicit session recovery', () {
      expect(
        SupabaseService.isRecoverableAuthError(
          Exception('Invalid Refresh Token: Refresh Token Not Found'),
        ),
        isTrue,
      );
    });

    test('temporary connectivity failures do not destroy session identity', () {
      expect(
        SupabaseService.isRecoverableAuthError(
          Exception('SocketException: Failed host lookup'),
        ),
        isFalse,
      );
    });
  });
}
