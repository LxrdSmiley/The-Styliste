# Human-only verification tasks

## Immediate Galaxy A55 Founder Trial retry

With the existing debug session still open, tap **Begin the Founder Trial** or
**Retry the same step** once on the Founder Trial error panel. No rebuild is
required because the missing remote Function, migrations, and reviewed Data
API schema boundary are now active server-side.

Confirm that:

- the screen advances from step 0/6 to step 1/6;
- the House name remains unchanged;
- no raw backend error is shown; and
- retrying does not create a duplicate House or duplicate receipt.

Current status:

```text
Pre-deployment A55 attempts: Failed — remote Founder Trial endpoint returned 404
First post-deployment retry: Failed — remote Data API rejected the api schema
Post-Data-API-correction retry: Blocked — awaiting Smiley observation
```

## Smiley's expansion-pass visual review

Review the committed deterministic renders in:

`docs/verification/aurelian_ui_expansion_pass_2/captures/after/`

Start with `contact_sheet_1.png` through `contact_sheet_4.png`, then open any
individual source render that needs closer review.

Confirm whether the complete reachable experience feels:

- luxurious, editorial, and distinctly Aurelian;
- fashion-industry specific rather than a generic dashboard;
- coherent across Ivory and Obsidian presentation;
- clear at a glance with one meaningful next action;
- respectful of Kingston's tailoring, sound, streetwear, community, and global
  creative authority;
- equally aspirational for Artisan and Architect;
- visually centered on the garment/capsule in Atelier; and
- honest about loading, preservation, authority, retry, and unavailable states.

Pay particular attention to:

- Opening Sanctuary and age gate;
- Luxe introduction and House naming;
- both Founder Trial paths and restored receipt;
- Artisan and Architect HQ;
- Atelier, Collection Brief, and all three look roles;
- readiness and sampling-unavailable boundary;
- Empire and first-store dialog;
- Feed and read-only sheets;
- House at 390 px and 320 px / 1.6× text;
- Settings and legal documents;
- five-tab selection; and
- all 14 reliability states.

Return one of:

```text
Approved

Approved with revisions:
1. ...
2. ...

Rejected with blocking revisions:
1. ...
2. ...
```

Current status:

```text
Final visual approval: Pending Smiley review of expansion-pass renders
```

## Still required before release

- Android and iOS compilation, signing, installation, and runtime review
- Physical-device TalkBack, text scaling, reduced motion, and keyboard review
- Galaxy A55-class performance and sustained-frame evidence
- Flutter Web review if Web returns to an authorized milestone
- Staging Supabase Auth/RLS/Realtime/Storage/Edge verification
- Deployment rehearsal and CI on a release-eligible workflow
- Legal and privacy review
- Jamaican/Caribbean cultural review
- Fashion-industry review
- Final commissioned art and audio review
- Representative young-adult playtesting and first-session comprehension
- Retention and monetization validation
- Final release authorization

The committed images are deterministic source renders, not physical-device
evidence.
