# Validation Format Diff Manifest

## Provenance

- Repository branch at audit: `codex/gdd-v7-kingston-alignment-20260722`
- Candidate HEAD at audit: `150f344f410f18dd3c6d086fd111df80f31f8452`
- Command operator: Smiley/user PowerShell session; complete outputs were supplied to Codex.
- Codex did not execute any Dart or Flutter command during this validation cycle.
- The original `dart format --output=none --set-exit-if-changed .` invocation was check-only. It reported files that would change but did not overwrite them.
- Every listed file had a non-whitespace working-tree delta before the authorized compilation repair. Those functional changes are pre-existing work and are excluded from any compilation-fix commit.

## File Classification

| File | Pre-existing functional delta | Formatting action | Included in compilation-fix commit |
|---|---:|---|---:|
| `lib/core/constants/supabase_constants.dart` | Yes | Explicitly write-formatted by Smiley | No |
| `lib/core/services/idle_engine_service.dart` | Yes | Explicitly write-formatted by Smiley | No |
| `lib/core/services/supabase_service.dart` | Yes | Explicitly write-formatted by Smiley | No |
| `lib/data/repositories/supabase_feed_repository.dart` | Yes | Explicitly write-formatted by Smiley | No |
| `lib/features/atelier/providers/drop_design_provider.dart` | Yes | Explicitly write-formatted by Smiley | No |
| `lib/features/atelier/providers/mint_design_provider.dart` | Yes | Explicitly write-formatted by Smiley | No |
| `lib/features/feed/providers/feed_provider.dart` | Yes | Targeted write-format applied by Smiley | No; restored import now matches `HEAD`, and all remaining Feed hunks are pre-existing |
| `lib/features/ledger/providers/ledger_provider.dart` | Yes | Explicitly write-formatted by Smiley | No |
| `lib/features/onboarding/providers/sovereign_genesis_provider.dart` | Yes | Explicitly write-formatted by Smiley | No |

## Preservation and Commit Boundary

- Formatting changed layout only; it did not authorize or reclassify the underlying functional changes.
- None of the eight broader files may be staged in a compilation-recovery commit.
- `lib/features/feed/providers/feed_provider.dart` contains substantial pre-existing functional changes. The restored provider import now matches `HEAD`, so no independent import-repair hunk remains to commit.
- `lib/features/settings/screens/settings_screen.dart` was not among the files reported by the original format check. The invalid Expert Mode `const` removal now matches `HEAD`.
- The optional static Notifications `const` is not independently stageable against `HEAD`: the static Notifications tile itself is part of pre-existing, unrelated working-tree work. Staging only `const` would produce an invalid commit against the `HEAD` version's runtime fields.
- This manifest is provenance evidence and is not part of the scoped compilation-fix commit unless separately authorized.

## Formatting Evidence

Smiley first write-formatted the two authorized source targets:

```text
dart format lib/features/feed/providers/feed_provider.dart lib/features/settings/screens/settings_screen.dart
TARGET_FORMAT_EXIT_CODE=0
Formatted 2 files (1 changed)
```

Two later repository-wide check-only runs each reported the same eight files and exited `1`. This was expected because `--output=none` does not write.

Smiley then explicitly write-formatted those eight files:

```text
dart format <the eight classified files above>
EIGHT_FILE_FORMAT_EXIT_CODE=0
Formatted 8 files (8 changed)
```

The final repository-wide verification passed:

```text
dart format --output=none --set-exit-if-changed .
FINAL_FORMAT_VERIFY_EXIT_CODE=0
Formatted 206 files (0 changed)
```

The repository formatting gate is satisfied.

## Other Validation Evidence

- `dart analyze`: exit code `0`; no issues found.
- `flutter analyze`: exit code `0`; no issues found.
- Unit/widget suite: exit code `0`; all 51 tests passed.
- Debug APK: exit code `0`; built successfully.
- Initial profile APK: exit code `1`; Gradle JVM native-memory allocation failure.
- Profile APK retry: exit code `0`; built `app-profile.apk` (62.9 MB) using a temporary lower-memory Gradle configuration.
- Android integration: explicitly deferred because `flutter devices` listed Windows, Chrome, and Edge but no Android target.
- Android SDK XML version warning: repeated during the successful profile build; nonblocking for this repair and retained for later tooling remediation.
