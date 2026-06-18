# Walkthrough — HQ Error State & Session Recovery

I have implemented a safe recovery flow for the HQ, addressing the "Session Expired" and "No Internet" blockers.

## Changes Made

### Core Recovery Logic
- **[SupabaseService](file:///C:/STN/The-Styliste/lib/core/services/supabase_service.dart)**:
    - Updated `playerSafeErrorMessage` to detect connection failures (SocketException, HttpException) and provide a friendly "No internet" message.
    - Added a fail-safe `signOut()` method that clears Realtime channels, signs out of Firebase, and signs out of Supabase.

### HQ Recovery UI
- **[HqScreen](file:///C:/STN/The-Styliste/lib/features/hq/screens/hq_screen.dart)**:
    - Replaced the previous dead-end error text with a structured `_HqErrorView`.
    - Added a **RETRY** button that invalidates the HQ providers to force a data refresh.
    - Added a **SIGN OUT** button that triggers the full auth cleanup, allowing the player to return to the onboarding/login flow.

## Verification

### Automated Checks
- Ensured code follows project standards and uses `AurelianPalette` for a luxury feel.
- Verified provider names in `hq_provider.dart` before invalidating.

### Manual Verification Steps for Smiley
1. **Offline Test**: Launch the app without internet. Confirm the "No internet connection" screen appears.
2. **Retry Test**: Re-enable internet and tap **RETRY**. Confirm the HQ loads.
3. **Sign Out Test**: Tap **SIGN OUT**. Confirm you are returned to the **Aurelian Gate**.

## Manual Terminal Commands for Smiley
```bash
dart format lib
flutter analyze
flutter test
```
