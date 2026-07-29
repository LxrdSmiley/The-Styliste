# Implementation commit inventory

Prepared: 2026-07-29
Scope: `feat(ui): redesign player-facing Aurelian experience for Gate A`

This is the explicit pre-stage publication inventory required by
`IDE_DIRECTIVES.md`. `T` means tracked and modified; `U` means untracked.
Every row records the repository-relative path, why it belongs, whether it is
generated output, whether it contains an absolute personal path, whether it
contains credential material, and its intended commit. All `Credential`
values are `No`: the final Gitleaks 8.30.1 working-tree scan reported zero
unsuppressed findings.

Excluded from both commits: `.env*`, credential replacements, Docker state,
temporary patches and tamper folders, `build/`, `.dart_tool/`,
`android/.kotlin/`, IDE caches, local database data, and unintended
screenshots. `.gitignore` explicitly ignores `android/.kotlin/`.

## Flutter source

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `lib/app.dart` | T | Application shell and session states | No | No / No | Implementation |
| `lib/core/constants/supabase_constants.dart` | T | Reviewed Supabase client constants | No | No / No | Implementation |
| `lib/core/providers/onboarding_provider.dart` | T | Onboarding state wiring | No | No / No | Implementation |
| `lib/core/services/supabase_service.dart` | T | Existing Supabase boundary integration | No | No / No | Implementation |
| `lib/domain/models/player.dart` | T | Founder identity presentation data | No | No / No | Implementation |
| `lib/domain/models/player.g.dart` | T | Checked-in model generator output | Yes, intended source | No / No | Implementation |
| `lib/features/atelier/screens/atelier_screen.dart` | T | Central Atelier visual redesign | No | No / No | Implementation |
| `lib/features/atelier/widgets/fabric_swatch_panel.dart` | T | Compact material inspector | No | No / No | Implementation |
| `lib/features/atelier/widgets/garment_canvas.dart` | T | Garment and pattern-cutting visual signature | No | No / No | Implementation |
| `lib/features/capsule/models/kingston_capsule.dart` | U | Immutable three-look capsule display DTO | No | No / No | Implementation |
| `lib/features/capsule/providers/capsule_foundation_provider.dart` | U | Riverpod retry/restoration state | No | No / No | Implementation |
| `lib/features/capsule/screens/capsule_workspace_screen.dart` | U | Collection Brief and capsule workspace | No | No / No | Implementation |
| `lib/features/feed/screens/feed_screen.dart` | T | Editorial Feed redesign | No | No / No | Implementation |
| `lib/features/feed/widgets/alpha_drop_feed_card.dart` | T | Responsive editorial card | No | No / No | Implementation |
| `lib/features/feed/widgets/mogul_power_feed_card.dart` | T | Feed card visual consolidation | No | No / No | Implementation |
| `lib/features/ftue/providers/first_objective_provider.dart` | T | Founder Trial handoff state | No | No / No | Implementation |
| `lib/features/ftue/widgets/first_objective_card.dart` | T | HQ next-action presentation | No | No / No | Implementation |
| `lib/features/ftue/widgets/luxe_first_objective_overlay.dart` | T | Luxe guidance reliability states | No | No / No | Implementation |
| `lib/features/hq/screens/hq_screen.dart` | T | HQ visual redesign | No | No / No | Implementation |
| `lib/features/hq/widgets/hq_architect_view.dart` | T | Architect presentation | No | No / No | Implementation |
| `lib/features/hq/widgets/hq_artisan_view.dart` | T | Artisan presentation | No | No / No | Implementation |
| `lib/features/hq/widgets/hq_foundation_view.dart` | U | Shared HQ foundation view | No | No / No | Implementation |
| `lib/features/ledger/screens/ledger_screen.dart` | T | Empire and Ledger redesign | No | No / No | Implementation |
| `lib/features/legal/screens/legal_document_screen.dart` | T | Legal surface visual consistency | No | No / No | Implementation |
| `lib/features/onboarding/providers/founder_trial_provider.dart` | U | Founder Trial server receipt state | No | No / No | Implementation |
| `lib/features/onboarding/screens/aurelian_gate_screen.dart` | T | Age-gate redesign | No | No / No | Implementation |
| `lib/features/onboarding/screens/founder_trial_screen.dart` | U | Founder Trial flow | No | No / No | Implementation |
| `lib/features/onboarding/screens/origin_script_screen.dart` | T | Luxe introduction redesign | No | No / No | Implementation |
| `lib/features/onboarding/screens/sovereign_registry_screen.dart` | T | House naming redesign | No | No / No | Implementation |
| `lib/features/profile/screens/profile_screen.dart` | T | House identity redesign | No | No / No | Implementation |
| `lib/features/reporting/widgets/report_modal.dart` | T | Shared reporting sheet styling | No | No / No | Implementation |
| `lib/features/settings/screens/settings_screen.dart` | T | Settings redesign | No | No / No | Implementation |
| `lib/main.dart` | T | App initialization and safe boundary startup | No | No / No | Implementation |

## UI design system

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `lib/core/theme/app_colors.dart` | T | Deprecated compatibility facade | No | No / No | Implementation |
| `lib/core/theme/app_theme.dart` | T | Theme compatibility handoff | No | No / No | Implementation |
| `lib/core/theme/aurelian_theme.dart` | T | Ivory and Obsidian theme integration | No | No / No | Implementation |
| `lib/core/theme/styliste_colors.dart` | T | Canonical semantic colors | No | No / No | Implementation |
| `lib/core/theme/styliste_motion.dart` | T | Reduced-motion-aware interaction tokens | No | No / No | Implementation |
| `lib/core/theme/styliste_radii.dart` | T | Canonical radius tokens | No | No / No | Implementation |
| `lib/core/theme/styliste_spacing.dart` | U | Canonical spacing tokens | No | No / No | Implementation |
| `lib/core/theme/styliste_typography.dart` | T | Canonical typography tokens | No | No / No | Implementation |
| `lib/core/widgets/aurelian_components.dart` | U | Cards, fields, sheets, status, and state panels | No | No / No | Implementation |
| `lib/core/widgets/styliste_buttons.dart` | U | Accessible action variants | No | No / No | Implementation |
| `lib/core/widgets/styliste_scaffold.dart` | T | Shared mobile-first scaffold | No | No / No | Implementation |

## Routes and navigation

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `lib/core/router/app_router.dart` | T | Feature-gated Gate A routing | No | No / No | Implementation |
| `lib/core/router/feature_unavailable_screen.dart` | U | Deferred-route containment state | No | No / No | Implementation |
| `lib/core/widgets/aurelian_navigation.dart` | U | Five-destination navigation component | No | No / No | Implementation |
| `lib/presentation/screens/main_shell.dart` | T | Canonical tab ordering and shell | No | No / No | Implementation |

## Flutter tests

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `test/core/router/deferred_drop_route_test.dart` | U | No-provider/no-request deferred deep-link test | No | No / No | Implementation |
| `test/core/router/first_loop_route_reachability_test.dart` | T | Gate A route scope test | No | No / No | Implementation |
| `test/core/widgets/aurelian_accessibility_test.dart` | U | Semantics, touch targets, text scale, motion | No | No / No | Implementation |
| `test/features/atelier/atelier_foundation_integration_test.dart` | T | Atelier and capsule handoff coverage | No | No / No | Implementation |
| `test/features/atelier/drop_preview_atelier_recovery_contract_test.dart` | T | Deferred drop recovery contract | No | No / No | Implementation |
| `test/features/capsule/capsule_foundation_provider_test.dart` | U | Capsule retry/replay/restoration provider coverage | No | No / No | Implementation |
| `test/features/capsule/capsule_workspace_screen_test.dart` | U | Three-look workspace states | No | No / No | Implementation |
| `test/features/feed/feed_screen_accessibility_test.dart` | U | Feed small-screen and semantic coverage | No | No / No | Implementation |
| `test/features/ftue/first_loop_scope_contract_test.dart` | T | FTUE scope boundary | No | No / No | Implementation |
| `test/features/hq/hq_foundation_integration_test.dart` | T | HQ foundation integration | No | No / No | Implementation |
| `test/features/ledger/open_first_store_contract_test.dart` | T | Existing first-store dialog boundary | No | No / No | Implementation |
| `test/features/onboarding/founder_trial_provider_test.dart` | U | Founder Trial retry and receipt coverage | No | No / No | Implementation |
| `test/features/onboarding/founder_trial_screen_test.dart` | U | Both path and confirmation states | No | No / No | Implementation |
| `test/features/reachable_surface_accessibility_test.dart` | U | Reachable-surface overflow and state coverage | No | No / No | Implementation |
| `test/visual/aurelian_review_capture_test.dart` | U | Deterministic source-render capture harness | No | No / No | Implementation |

## Supabase migrations

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `supabase/migrations/20260726185809_kingston_founder_trial_state_machine.sql` | U | Forward-only Founder Trial authority | No | No / No | Implementation |
| `supabase/migrations/20260726193612_quarantine_legacy_power_move_functions.sql` | U | Forward-only legacy authority quarantine | No | No / No | Implementation |
| `supabase/migrations/20260726231214_kingston_capsule_foundation.sql` | U | Forward-only capsule state machine and receipts | No | No / No | Implementation |

## Edge Functions

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `supabase/config.toml` | T | Reviewed local API/Edge boundary configuration | No | No / No | Implementation |
| `supabase/functions/_shared/kingston_routes.ts` | T | Bounded server-intent route registry | No | No / No | Implementation |
| `supabase/functions/capsule-foundation/index.ts` | U | Single Capsule Foundation Edge intent | No | No / No | Implementation |
| `supabase/functions/deno.lock` | U | Reviewed Edge dependency lock | Yes, intended lockfile | No / No | Implementation |
| `supabase/functions/tsconfig.json` | T | Edge type-check configuration | No | No / No | Implementation |

## Database and Edge tests

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `supabase/tests/authority_contract_matrix.json` | T | Exposed-operation authority matrix | No | No / No | Implementation |
| `supabase/tests/capsule_foundation_state_machine.test.sql` | U | Capsule ownership, replay, and stage pgTAP coverage | No | No / No | Implementation |
| `supabase/tests/execute_power_move_ownership_test.sql` | T | Retired authority containment coverage | No | No / No | Implementation |
| `supabase/tests/first_loop_rank_progression.sql` | T | Early-loop progression authority coverage | No | No / No | Implementation |
| `supabase/tests/founder_trial_state_machine.test.sql` | U | Founder Trial state-machine pgTAP coverage | No | No / No | Implementation |
| `supabase/tests/kingston_early_game_api_contract.test.sql` | T | Reviewed API contract coverage | No | No / No | Implementation |
| `supabase/tests/kingston_economic_concurrency.ps1` | T | Twenty-session replay/locking harness | No | No / No | Implementation |
| `supabase/tests/kingston_edge_identity_test.ts` | T | Edge actor and input contract coverage | No | No / No | Implementation |
| `supabase/tests/platform_auth_mappings_anonymous_access.test.sql` | T | Founder-trial identity containment | No | No / No | Implementation |
| `supabase/tests/platform_auth_mappings_identity_containment.test.sql` | T | Auth mapping containment | No | No / No | Implementation |
| `supabase/tests/progression_feed_migration_repair.test.sql` | T | Progression/feed authority regression coverage | No | No / No | Implementation |
| `supabase/tests/rls_authority_contract.sql` | T | RLS authority contract coverage | No | No / No | Implementation |

## Verification scripts

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `.github/workflows/flutter-ci.yml` | T | Source-level verification workflow definitions | No | No / No | Implementation |
| `scripts/check_authority_inventory.ps1` | U | Canonical authority inventory guard | No | No / No | Implementation |
| `scripts/check_authority_matrix.ps1` | T | Authority matrix guard | No | No / No | Implementation |
| `scripts/check_deferred_todos.ps1` | T | Deferred Feature-ID guard | No | No / No | Implementation |
| `scripts/check_early_game_api_contract.ps1` | T | API contract guard | No | No / No | Implementation |
| `scripts/check_early_game_edge_allowlist.ps1` | T | Edge allowlist guard | No | No / No | Implementation |
| `scripts/check_gdd_registry.ps1` | T | 160-ID registry guard | No | No / No | Implementation |
| `scripts/maintenance/check_repository_health.ps1` | T | Combined local repository-health gate | No | No / No | Implementation |

## Migration-integrity tooling

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `scripts/check_migration_hash_manifest.ps1` | U | Exact raw-byte migration-hash validator | No | No / No | Implementation |
| `scripts/generate_migration_hash_manifest.ps1` | U | Controlled manifest regeneration tool | No | No / No | Implementation |

## Gitleaks configuration

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `.gitleaksignore` | U | Reviewed exact-fingerprint-only scanner exceptions | No | No / No | Implementation |

## Deterministic visual evidence

All files in this section are intentional generated source renders, committed
review evidence rather than physical-device proof. They contain no absolute
personal path or credential material and belong in the implementation commit.

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `docs/verification/aurelian_ui_redesign/captures/before/atelier_workspace.png` | U | Before capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/before/capsule_collection_brief.png` | U | Before capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/before/founder_trial_entry.png` | U | Before capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/before/house_identity.png` | U | Before capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/before/hq_architect.png` | U | Before capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/before/hq_artisan.png` | U | Before capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/before/opening_manifesto.png` | U | Before capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/before/settings.png` | U | Before capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/age_gate.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/atelier_workspace.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/capsule_collection_brief.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/capsule_hero_piece.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/capsule_readiness_sampling_boundary.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/drop_route_unavailable.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/empire_projection.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/feed_comment_sheet.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/feed_projection.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/feed_request_sheet.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/first_store_dialog.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/five_tab_navigation.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/founder_trial_entry.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/founder_trial_restored.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/house_identity.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/house_naming.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/hq_architect.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/hq_artisan.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/legal_privacy.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/luxe_introduction.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/opening_sanctuary.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/session_loading.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/session_safe_failure.png` | U | After capture | Yes | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/captures/after/settings.png` | U | After capture | Yes | No / No | Implementation |

## Governance and audit records

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `Agent.md` | T | Inherited agent-governance evidence | No | No / No | Implementation |
| `PROJECT_RULES.md` | T | Updated project authority evidence | No | No / No | Implementation |
| `docs/RELEASE_PROCESS.md` | T | Release-evidence boundary | No | No / No | Implementation |
| `docs/ui_reference/STITCH_SCREEN_INVENTORY.md` | T | Reachable-surface source inventory | No | No / No | Implementation |
| `docs/verification/api_schema_inventory.txt` | T | Reviewed generated API snapshot | Yes, intended evidence | No / No | Implementation |
| `docs/verification/authority_inventory.json` | U | Generated authority snapshot | Yes, intended evidence | No / No | Implementation |
| `docs/verification/early_game_readiness.md` | T | Feature readiness evidence | No | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/CAPTURE_INDEX.md` | U | Deterministic capture index | No | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/IMPLEMENTATION_COMMIT_INVENTORY.md` | U | Explicit pre-stage publication inventory | No | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/SECURITY_KEY_REMEDIATION.md` | U | Redacted Gitleaks remediation register | No | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/SURFACE_INVENTORY.md` | U | Route, sheet, provider, and reachability inventory | No | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/UI_REDESIGN_AUDIT.md` | U | UI skill, accessibility, and visual audit | No | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/baseline_hashes.csv` | U | Generated baseline evidence | Yes, intended evidence | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/MIGRATION_HASH_CONTRACT.md` | U | Published-migration immutability contract | No | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/migration_hash_inventory.csv` | U | Generated migration inventory | Yes, intended evidence | No / No | Implementation |
| `docs/verification/aurelian_ui_redesign/migration_hash_manifest.csv` | U | Generated raw-byte hash manifest | Yes, intended evidence | No / No | Implementation |

## Fonts and licenses

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `assets/fonts/Inter-Variable.ttf` | U | Approved Inter family asset | No | No / No | Implementation |
| `assets/fonts/JetBrainsMono-Variable.ttf` | U | Approved JetBrains Mono asset | No | No / No | Implementation |
| `assets/fonts/SpaceGrotesk-Variable.ttf` | U | Approved Space Grotesk asset | No | No / No | Implementation |
| `assets/fonts/LICENSE-Inter-OFL.txt` | U | Inter license | No | No / No | Implementation |
| `assets/fonts/LICENSE-JetBrainsMono-OFL.txt` | U | JetBrains Mono license | No | No / No | Implementation |
| `assets/fonts/LICENSE-SpaceGrotesk-OFL.txt` | U | Space Grotesk license | No | No / No | Implementation |
| `pubspec.yaml` | T | Declares approved bundled fonts | No | No / No | Implementation |

## Repository hygiene

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `.gitignore` | T | Ignores generated `android/.kotlin/` output | No | No / No | Implementation |

## Historical evidence

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `docs/governance/GDD_V7_CODE_ALIGNMENT_MATRIX.md` | T | Clearly historical v7 alignment record | No | No / No | Implementation |
| `docs/superpowers/plans/2026-07-26-gdd-v8-kingston-governance-transition.md` | U | Clearly labelled historical, non-authoritative governance plan | No | No / No | Implementation |

## Documentation commit reservation

The following tracked governance records are intentionally left unstaged for
the documentation commit after the implementation push. They will be replaced
or updated with the final SHA, push observation, and human-only review tasks.

| Path | Status | Inclusion reason | Generated | Absolute / credential | Commit |
|---|---|---|---|---|---|
| `IDE_DIRECTIVES.md` | T | Final repository-wide handoff report | No | No / No | Documentation |
| `MANUAL_TASKS.md` | T | Human-only remaining work | No | No / No | Documentation |
| `DEVELOPMENT_STATE.md` | T | Final branch/publication state | No | No / No | Documentation |
| `CHANGELOG.md` | T | Player-facing change record | No | No / No | Documentation |
| `BOTTLENECK_LOG.md` | T | Superseding verification prevention record | No | No / No | Documentation |
