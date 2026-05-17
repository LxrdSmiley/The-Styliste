# Implementation Plan — IDE_DIRECTIVES.md Review Fixes

This plan outlines the implementation of security fixes, bug fixes, and cleanup tasks as specified in `IDE_DIRECTIVES.md`.

## User Review Required

- **Item 4 (Idle Income Ticker)**: The codebase already appears to use `brand.idleRevenuePerHour.toInt()`. I will double-check if there are any other providers that need this fix, but otherwise, this may already be completed.
- **Items 8-11 (Feature Completion TODOs)**: I will replace the generic TODOs with more descriptive ones mentioning Phase 4 and the specific requirements (e.g., Brand Rank history, achievement badges) as requested in the directives.

## Proposed Changes

### [Supabase Migrations]

#### [010_crisis_engine.sql](file:///C:/STN/The-Styliste-1/supabase/migrations/010_crisis_engine.sql)
- Add authorization checks to `apply_kintsugi_repair` and `apply_public_apology`.
```sql
IF auth.uid() != p_player_id THEN
  RAISE EXCEPTION 'UNAUTHORIZED: Cross-player modification attempt';
END IF;
```

#### [014_supply_chain.sql](file:///C:/STN/The-Styliste-1/supabase/migrations/014_supply_chain.sql)
- Add authorization checks to `execute_liquidation`, `upgrade_logistics`, `add_inventory`, and `process_idle_income`.

#### [011_sovereign_talent.sql](file:///C:/STN/The-Styliste-1/supabase/migrations/011_sovereign_talent.sql)
- Add authorization check to `execute_casting_pull`.

#### [017_mini_game_rewards.sql](file:///C:/STN/The-Styliste-1/supabase/migrations/017_mini_game_rewards.sql)
- Add authorization checks to `inject_capital_bonus`, `apply_idle_multiplier`, and `reset_talent_stamina`.

#### [015_aurelian_storefront.sql](file:///C:/STN/The-Styliste-1/supabase/migrations/015_aurelian_storefront.sql)
- Revoke `EXECUTE` on `verify_and_grant_luxe` from `authenticated`.
- Add comment explaining it should only be called by service role.

#### [NEW] [020_rate_limiting.sql](file:///C:/STN/The-Styliste-1/supabase/migrations/020_rate_limiting.sql)
- Create table `post_reactions`.
- Add RLS policies for `post_reactions`.
- Implement `increment_post_hype` with deduplication and authorization checks.

---

### [Flutter Backend & Providers]

#### [auth_service.dart](file:///C:/STN/The-Styliste-1/lib/core/services/auth_service.dart)
- Replace broken `GoogleAuthProvider.credential` call with `throw UnimplementedError` and detailed comment about the required Edge Function.

#### [supply_chain_provider.dart](file:///C:/STN/The-Styliste-1/lib/features/supply_chain/providers/supply_chain_provider.dart)
- Remove unused imports: `app_colors.dart` (if found) and `supabase_constants.dart`.

---

### [Feature Completion & TODOs]

#### [world_map_screen.dart](file:///C:/STN/The-Styliste-1/lib/features/world_map/screens/world_map_screen.dart)
- Update TODO to mention Phase 4+ and 2.5D globe view.

#### [events_screen.dart](file:///C:/STN/The-Styliste-1/lib/features/events/screens/events_screen.dart)
- Update TODO to mention Phase 4 and specific event types.

#### [profile_screen.dart](file:///C:/STN/The-Styliste-1/lib/features/profile/screens/profile_screen.dart)
- Update TODO to mention Phase 4, Brand Rank history, and achievement badges.

#### [report_modal.dart](file:///C:/STN/The-Styliste-1/lib/features/reporting/widgets/report_modal.dart)
- Update TODO to mention Phase 4, category selection, and screenshot capture.

---

## Verification Plan

### Automated Tests
- Run `flutter analyze lib` to ensure no new issues are introduced and unused imports are gone.
- Run `dart fix --apply` to automatically apply `const` and other minor fixes.
- Run `dart run build_runner build --delete-conflicting-outputs` to ensure generated files are up to date.

### Manual Verification
- Review SQL changes for syntax correctness.
- Verify that `auth_service.dart` no longer attempts to use the invalid `serverAuthCode` parameter.
- Confirm TODO updates in UI files.
