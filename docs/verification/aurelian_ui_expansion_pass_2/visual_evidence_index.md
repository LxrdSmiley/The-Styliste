# Aurelian UI Expansion Pass 2 — Visual Evidence Index

Status: **Deterministic source render — not physical-device evidence**

Capture date: 2026-07-29
Baseline source commit: `c4405414195f5bcdff87b31848c3425a17e76e85`
After-render source: expansion-pass working tree derived from the baseline above.
The immutable implementation commit is recorded in the final handoff after
publication because a commit cannot contain its own SHA.

These renders are review fixtures, not Android, iOS, Web, device-accessibility,
or performance evidence. Unless a row says otherwise, the fixture uses the
Obsidian Aurelian theme, a 390 × 844 logical-pixel portrait viewport, text scale
1.0, motion enabled, fixed local display data, and a 1.5× PNG capture ratio.
No fixture grants gameplay authority or simulates a successful economic
mutation.

## After-render manifest

Every image below visibly includes:
`Deterministic source render — not physical-device evidence`.

| File | Screen / route | Fixed fixture and state | Viewport / accessibility |
|---|---|---|---|
| `age_gate.png` | Opening Sanctuary age gate / onboarding gate | Local legal age decision pending | Default |
| `atelier_reduced_motion_412.png` | Atelier `/atelier` | Local garment study; no active trend data | 412 × 844; reduced motion |
| `atelier_workspace.png` | Atelier `/atelier` | Local garment study; server submission boundary | Default |
| `capsule_collection_brief.png` | Collection Brief `/atelier/capsule` | New bounded brief draft | Default |
| `capsule_commercial_anchor.png` | Commercial Anchor `/atelier/capsule` | Hero confirmed; commercial role editing | Default; scrolled to active role |
| `capsule_experimental_piece.png` | Experimental Piece `/atelier/capsule` | First two roles confirmed; experimental role editing | Default; scrolled to active role |
| `capsule_hero_piece.png` | Hero Piece `/atelier/capsule` | Brief confirmed; hero role editing | Default; scrolled to active role |
| `capsule_readiness_review.png` | Readiness `/atelier/capsule` | Three roles confirmed; readiness pending | Default; scrolled to readiness action |
| `capsule_readiness_sampling_boundary.png` | Sampling boundary `/atelier/capsule` | Server-derived readiness restored; sampling unavailable | Default; scrolled to boundary |
| `capsule_restored_receipt.png` | Capsule receipt `/atelier/capsule` | Stable restored brief receipt | Default |
| `drop_route_unavailable.png` | Deferred drop `/atelier/drop-preview` and `/atelier/drop-launch` | Shared unavailable state; no provider or request started | Default |
| `empire_projection.png` | Empire `/empire` | Read-only brand projection; no fabricated stores | Default |
| `feed_comment_sheet.png` | Comment sheet over `/feed` | Read-only comment boundary | Default |
| `feed_projection.png` | Feed `/feed` | One fixed House editorial projection | Default |
| `feed_request_sheet.png` | Request sheet over `/feed` | Held request boundary | Default |
| `first_store_dialog.png` | Existing first-store dialog | Local selection state; balance 2,500 | Default |
| `five_tab_navigation.png` | Five-destination shell | HQ selected; confirmed restored-House state | Default |
| `founder_trial_entry.png` | Founder Trial `/founder-trial` | Shared garment; Artisan/Architect decision pending | Default |
| `founder_trial_restored.png` | Founder Trial `/founder-trial` | Restored server receipt; Artisan path | Default |
| `house_identity.png` | House `/house` | Verified House Meridian identity | Default |
| `house_identity_large_text_320.png` | House `/house` | Verified House Meridian identity | 320 × 844; text scale 1.6 |
| `house_naming.png` | House naming `/sovereign-registry` | Local name draft; server authority explained | Default |
| `hq_architect.png` | HQ `/hq` | Architect framing with fixed confirmed indicators | Default |
| `hq_artisan.png` | HQ `/hq` | Artisan framing with fixed confirmed indicators | Default |
| `legal_privacy.png` | Privacy document `/house/legal/privacy` | Repository legal copy; launch approval pending | Default |
| `luxe_introduction.png` | Luxe introduction `/origin-script` | Concise Kingston founder guidance | Default |
| `opening_sanctuary.png` | Opening Sanctuary `/opening` | Initial authorship and House context | Default |
| `session_loading.png` | Application session gate | Saved Supabase session resolution | Default |
| `session_safe_failure.png` | Application session gate | Player-safe authentication failure | Default |
| `settings.png` | Settings `/house/settings` | Local presentation preferences | Default |
| `state_confirmed.png` | Shared reliability component | Confirmed | Default |
| `state_disabled.png` | Shared reliability component | Disabled | Default |
| `state_editing.png` | Shared reliability component | Editing | Default |
| `state_empty.png` | Shared reliability component | Empty | Default |
| `state_loading.png` | Shared reliability component | Loading | Default |
| `state_maintenance.png` | Shared reliability component | Maintenance | Default |
| `state_offline.png` | Shared reliability component | Offline with safe retry | Default |
| `state_permission_denied.png` | Shared reliability component | Permission denied | Default |
| `state_restored.png` | Shared reliability component | Restored receipt | Default |
| `state_retryable_error.png` | Shared reliability component | Retryable error with safe retry | Default |
| `state_session_expired.png` | Shared reliability component | Session expired | Default |
| `state_submitting.png` | Shared reliability component | Submitting | Default |
| `state_terminal_error.png` | Shared reliability component | Terminal error | Default |
| `state_unavailable.png` | Shared reliability component | Unavailable boundary | Default |

## Before-render manifest

The 24 baseline files under `captures/before/` use the same screen, route,
fixture, mode, viewport, text scale, state, and capture date as the matching
after-render row unless the filename itself identifies a distinct path or
state. Their source commit is the baseline SHA above. They were intentionally
captured before the expansion watermark was added; this manifest supplies the
required evidence label without altering the baseline pixels.

```text
age_gate.png
atelier_workspace.png
capsule_collection_brief.png
capsule_hero_piece.png
capsule_readiness_sampling_boundary.png
drop_route_unavailable.png
empire_projection.png
feed_comment_sheet.png
feed_projection.png
feed_request_sheet.png
first_store_dialog.png
five_tab_navigation.png
founder_trial_entry.png
founder_trial_restored.png
house_identity.png
house_naming.png
hq_architect.png
hq_artisan.png
legal_privacy.png
luxe_introduction.png
opening_sanctuary.png
session_loading.png
session_safe_failure.png
settings.png
```

## Contact sheets and manual inspection

`contact_sheet_1.png` through `contact_sheet_4.png` are review aids assembled
from the 44 after-renders. They do not replace the individual source files.

All 44 after-renders were manually inspected at source-capture resolution.
The first review identified three issues: unreadable dark receipt evidence,
role captures positioned above their active editors, and cramped House facts
at 320 px with large text. Source and fixtures were corrected, the affected
renders were regenerated, and the contact sheets were inspected again.

Final deterministic review result:

- no Flutter overflow warning stripe was visible;
- the three capsule roles show distinct garment/pattern-cutting linework;
- the sampling boundary and deferred drop routes remain explicit;
- confirmed and restored receipts are readable and non-color-dependent;
- the 320 px / 1.6× House fixture uses a stacked fact layout;
- the 412 px Atelier fixture preserves its hierarchy with reduced motion;
- Ivory/Obsidian token use remains within the canonical Aurelian system; and
- final visual approval remains **Pending Smiley review of expansion-pass
  renders**.
