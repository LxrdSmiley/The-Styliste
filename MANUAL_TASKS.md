# MANUAL_TASKS.md — The Styliste Dev/Ops Requirements



## 1. Credentials & Configuration

- **Firebase Config**: Ensure `PLAY_GAMES_CLIENT_ID` and all `FIREBASE_*` keys are correctly set in the environment using `--dart-define-from-file`.

- **Supabase Edge Functions**: Deploy the `trend-decay` and `process-idle-income` Edge Functions to Supabase.

- **App Check Whitelisting**: Manually whitelist the Debug Tokens printed in the console during dev runs at `console.firebase.google.com`.



## 2. Legal Document Verification

- **GDD §10.1 Audit**: Manually verify that all URLs in `SettingsScreen` point to finalized, legally-reviewed documents.

  - [ ] Privacy Policy

  - [ ] Terms of Service

  - [ ] EULA

  - [ ] Community Guidelines

  - [ ] Cookie Policy

  - [ ] DMCA / Copyright

  - [ ] Refund Policy

  - [ ] Children's Privacy (COPPA)

  - [ ] Accessibility Statement

- **Compliance**: Ensure all documents mention "SkinTeethNerd Studios" as the developer and are GDPR/CCPA compliant.



## 3. Security & Anti-Cheat

- **Rate Limiting**: Configure Cloudflare WAF or Supabase Kong rate-limiting for the `/rest/v1/rpc/increment_post_hype` endpoint.

- **Audit Logs**: Periodically review the `player_reports` table in Supabase for high-severity flags.



## 4. Feature Implementation (Phase 4)

- **World Map**: Implement the 2.5D globe view and city node sweeps as per GDD §4.

- **Profile Screen**: Complete the player profile view with Brand Rank history and achievement badges.

- **Events Screen**: Implement the seasonal calendar and Fashion Week participation logic.

- **Reporting Modal**: Finalize the screenshot attachment and category selection logic in `ReportModal`.



## 5. Static Analysis

- **Full Run**: Run `flutter analyze` on a build machine with the full Flutter SDK to catch platform-specific warnings in `ios/` and `android/` folders.

- **Build Runner**: Run `dart run build_runner build --delete-conflicting-outputs` to ensure all `.g.dart` and `.freezed.dart` files are in sync with models.

