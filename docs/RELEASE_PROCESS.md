# The Styliste Release Process

> Active release authority is GDD v8 §§21–22 and
> `docs/verification/authority_inventory.json`. Any v7 wording retained below
> is historical release-process context only and must not govern a release.

## Purpose

The repository uses the useful parts of the Street Food Empire workflow—clear
README status, a maintained changelog, semantic versions, version-specific
release notes, and GitHub Releases—without treating every commit as a public
game release.

## Version sources

| Item | Authority | Example |
|---|---|---|
| Application version | `pubspec.yaml` | `0.1.0-alpha.1+1` |
| GitHub tag | Application version without build number | `v0.1.0-alpha.1` |
| Android/iOS build number | Suffix after `+` | `1` |
| GDD version | Product/design document only | `v8` |
| Database version | Chronological Supabase migration | `202607...` |

Do not call the application “v8.” GDD v8 and application releases are separate.

## After each implementation

1. Update `DEVELOPMENT_STATE.md` with exact scope, evidence, blockers, and next
   safe action.
2. Add applicable changes under `[Unreleased]` in `CHANGELOG.md`.
3. Update `README.md` only if support, status, evidence, run instructions, or
   milestone scope changed.
4. Update `BOTTLENECK_LOG.md` when a repeatable failure mode was discovered.
5. Update the current file under `docs/releases/` when the pending release's
   user-visible contents or known limitations changed.
6. Run `scripts/check_release_metadata.ps1`.

## Semantic Versioning before 1.0

- `0.x.y-alpha.n`: internal or closed-test build with known blockers.
- `0.x.y-beta.n`: controlled external test after applicable Beta gates pass.
- `0.x.y-rc.n`: release candidate with no known release-blocking defect.
- `1.0.0`: first public launch only after GDD v8 §§21–22 and the verification
  protocol permit that claim.

A feature commit does not automatically require a version bump. Bump the
version when a coherent testable slice is cut, a prerelease is superseded, or a
published release needs a patch.

## Draft release workflow

The `Create GitHub Draft Prerelease` workflow is manual. It:

1. requires the exact confirmation text `CREATE DRAFT`;
2. verifies the requested tag matches `pubspec.yaml`;
3. runs the release-metadata guard;
4. requires a successful `Early Game Readiness CI` run for the same commit; and
5. creates a draft prerelease using `docs/releases/<tag>.md`.

The workflow does not publish the release and does not attach an unsigned or
debug mobile binary. An authorized person reviews and publishes the draft only
after the evidence required for that release type exists.

## Deferred Web publication

Flutter Web and GitHub Pages are not current release targets. Do not configure,
build, or dispatch them as part of the Android/iOS milestone. A later Web
publication decision requires separate authorization and restored browser,
hosting, authentication, and security gates.
