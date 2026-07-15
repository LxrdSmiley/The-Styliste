// GDD v7 §§19.1–19.3, 22 — verified platform restoration is deferred.

enum PlatformRestorationStatus { unavailable }

final class PlatformRestorationResult {
  const PlatformRestorationResult.unavailable()
      : status = PlatformRestorationStatus.unavailable;

  static const String safeMessage =
      'Verified platform restoration is not available yet.';

  final PlatformRestorationStatus status;
}

/// Compatibility shell for the deferred platform-restoration milestone.
class AuthService {
  AuthService._();

  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  /// Deprecated until a server-verified restoration flow is authorized.
  @Deprecated('Deferred to the server-verified platform restoration milestone.')
  Future<String?> signInSilently() async {
    await getPlatformRestorationStatus();
    return null;
  }

  /// Typed status for callers that need to distinguish unavailable restoration
  /// from a failed or authenticated platform flow.
  Future<PlatformRestorationResult> getPlatformRestorationStatus() async {
    return const PlatformRestorationResult.unavailable();
  }

  /// Compatibility shim; verified cloud-save discovery is deferred.
  @Deprecated('Deferred to the server-verified platform restoration milestone.')
  Future<bool> hasCloudSave() async => false;

  /// Compatibility shim; platform display-name discovery is deferred.
  @Deprecated('Deferred to the server-verified platform restoration milestone.')
  Future<String?> getPlatformName() async => null;

  /// Compatibility shim; platform sign-out is owned by the active auth layer.
  @Deprecated('Use the active authentication provider for sign-out.')
  Future<void> signOut() async {}
}
