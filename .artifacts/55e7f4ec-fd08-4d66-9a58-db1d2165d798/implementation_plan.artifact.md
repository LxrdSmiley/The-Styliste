# Implementation Plan — HQ Error State & Session Recovery Pass 1

This plan addresses the "Session Expired" / "No Internet" blockers in the HQ. It implements a safe recovery UI with **RETRY** and **SIGN OUT** actions, ensuring players can recover from stale sessions or connection issues.

## User Review Required

> [!IMPORTANT]
> The **SIGN OUT** button will clear all local authentication states (Firebase & Supabase) and return the player to the **Aurelian Gate** (onboarding/login). This is the "hard reset" for session corruption.

> [!NOTE]
> I am expanding the error messages to be more specific (e.g., "No internet" vs "Session expired") to help the player understand what to do.

## Proposed Changes

### Core Component

#### [MODIFY] [supabase_service.dart](file:///C:/STN/The-Styliste/lib/core/services/supabase_service.dart)
- Update `playerSafeErrorMessage` to recognize `SocketException` and `HttpException` as connection errors.
- Add `static Future<void> signOut()`:
    - Calls `cleanupRealtimeChannels()`.
    - Signs out of `FirebaseAuth` (which triggers the bridge cleanup via `supabaseBridgeProvider`).
    - Signs out of `Supabase.auth`.
- Add a static constant for "No internet" message.

### HQ Component

#### [MODIFY] [hq_screen.dart](file:///C:/STN/The-Styliste/lib/features/hq/screens/hq_screen.dart)
- Replace the simple `Text` error state in the `build` method with a structured recovery UI:
    - Display the safe error message (Ivory/Champagne Gold styling).
    - **RETRY** button: calls `ref.invalidate(hqPlayerStreamProvider)` and `ref.invalidate(hqBrandStreamProvider)`.
    - **SIGN OUT** button: calls `SupabaseService.signOut()`.
- Ensure the error UI matches the "Obsidian" theme of the loading gate to avoid jarring flashes.

### Auth Component

#### [MODIFY] [auth_provider.dart](file:///C:/STN/The-Styliste/lib/core/providers/auth_provider.dart)
- Ensure `supabaseBridgeProvider` handles `null` user by fully clearing Supabase state.

## Verification Plan

### Automated Tests
- Run `dart format lib`.
- Run `flutter analyze` to check for type errors in the new recovery buttons.

### Manual Verification (for Smiley)
1. **Offline Test**:
    - Turn off Wi-Fi/Data.
    - Launch the app. HQ should show "No internet connection".
    - Tap **RETRY** with internet back on. HQ should load.
2. **Session Expiry Test**:
    - Trigger a session error (e.g., by manually clearing Supabase tokens if possible, or simulating an `InvalidJWTToken` error).
    - HQ should show "Session expired. Please sign in again."
    - Tap **SIGN OUT**.
    - Verify the app returns to the **Aurelian Gate**.
3. **Mogul/Designer Consistency**:
    - Verify the recovery UI appears correctly for both career paths.

## Manual Terminal Commands for Smiley
```bash
dart format lib
flutter analyze
flutter test
```
