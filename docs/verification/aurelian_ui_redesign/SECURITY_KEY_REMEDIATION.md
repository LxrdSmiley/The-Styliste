# Historical key-remediation register

Status: **Blocked — no Gitleaks exceptions have been added**

Authority: `THE_STYLISTE_GDD_v8.md` §§19, 21–22 and
`VERIFICATION_PROTOCOL.md`.

## 2026-07-29 security-verification update

Publication remains `Blocked` solely by the historical-secret verification
gate. The original 20 redacted scanner occurrences remain preserved, and no
exception, suppression, rule disablement, or broad path exclusion has been
created.

- Findings 1–8 are each classified as `Documentation placeholder`.
- Findings 9–14 are each classified as `Matrix test value`.
- Findings 15–20 are each classified as `Confirmed historical credential`.
- The final provider disposition for findings 15–20 is still unknown; these
  six occurrences remain unresolved pending Smiley's redacted console review.

The legacy table below is the immutable one-occurrence register. Its
`Example`, `Matrix fixture`, and `Confirmed key` labels are superseded by the
three classifications above. Its fields map to the required register data as
follows: `Rule / fingerprint` contains the rule ID and fingerprint;
`Commit / path` contains the commit SHA and repository-relative path;
`Provider/project`, `Remediation`, `Exception eligibility`, and `Redacted
evidence` are respectively the external-provider/project status, required
remediation, exception eligibility, and evidence state.

### Fourteen static classifications

| Findings | Classification | Static evidence | Provider/project status | Evidence state | Exception eligibility |
|---|---|---|---|---|---|
| 1, 2, 3, 4, 5, 6, 7, 8 | Documentation placeholder | Each cited historical line exists in a Markdown instruction file, is inside a code fence, and is in Figma file-key or node-id teaching context. None matches the checked GCP, AWS, GitHub, Slack, or JWT credential grammar. | No provider project or authentication field. | Static inspection passed; no provider authentication was attempted or needed. Current references are documentation/skill-lock records only. | Conditional on the later exact-fingerprint review; no exception is active. |
| 9, 10, 11, 12, 13, 14 | Matrix test value | Each cited historical line is an `auth_mode` property in a JSON authority-contract matrix that parses successfully. Current readers are local PowerShell guards; no Dart or Edge runtime reader exists and neither guard performs network I/O. None matches the checked credential grammar. | Local test metadata, not provider authentication material. | Static inspection passed; no provider authentication was attempted or needed. | Conditional on the later exact-fingerprint review; no exception is active. |

This is a static classification, not an external-provider-validity assertion.
The values were not submitted to a provider, and their lack of a repository
authentication sink is the counterevidence supporting their noncredential
purpose. Replacing historical literals would not remove the Git-history
findings, so no source change was made and no security test was weakened.

### Gitleaks 8.30.1 restoration receipt

- Download source: `https://github.com/gitleaks/gitleaks/releases/tag/v8.30.1`
- Filename: `gitleaks_8.30.1_windows_x64.zip`
- Expected SHA-256: `D29144DEFF3A68AA93CED33DDDF84B7FDC26070ADD4AA0F4513094C8332AFC4E`
- Observed SHA-256: `D29144DEFF3A68AA93CED33DDDF84B7FDC26070ADD4AA0F4513094C8332AFC4E`
- Version output: `8.30.1`
- Binary path: temporary checksum-verified local location; intentionally not
  recorded because it was a personal workstation path.

The archive checksum matched before extraction. Final scans are recorded in
the 2026-07-29 completion receipt below.

### Temporary migration-tamper fixture cleanup

All three exact tamper folders were rechecked under the operating-system
temporary directory. They were outside the repository; contained only `.sql`
and `.csv` copied migration/manifest fixtures; contained no `.git` metadata,
credential material, junctions, or symlinks; and had no path resolving into the
repository. The execution environment denied the reviewed targeted deletion.

```text
Location: system temporary directory
Repository content: None
Credential content: None
Publication impact: None
Cleanup status: Manual operating-system cleanup pending
```

## 2026-07-29 external provider dispositions

Smiley supplied redacted external-console evidence for all historical
Firebase/GCP credential groups. No key value, replacement key, or console
screenshot containing credential material was provided or recorded.

| Credential group | Findings | Project | Project exists | Key active | Final action | Evidence reviewed | Complete key included |
|---|---|---|---|---|---|---|---|
| A | 16, 20 | `the…ste` | Yes | No | Deleted | Yes | No |
| B | 15, 17 | `the…ste` | Yes | No | Deleted | Yes | No |
| C | 18, 19 | `the…ste` | Yes | No | Deleted | Yes | No |

Deletion makes application restrictions, API restrictions, and recent usage
inapplicable to these historical credentials. This resolves external risk for
findings 15–20; it does not alter their historical-credential classification.

### Exact-fingerprint exception basis

The following reviews confirm the existing classifications without changing
them:

| Findings | Synthetic or historical basis | Provider-valid credential resemblance | Replacement decision | Exact exception still required |
|---|---|---|---|---|
| 1–8 | Markdown Figma file-key/node-id teaching literals in a historical instruction file. | No checked GCP, AWS, GitHub, Slack, or JWT credential grammar. | No current runtime source exists to replace; changing history would not remove the finding. | Yes, for each historical scanner fingerprint only. |
| 9–14 | JSON `auth_mode` contract-test values; current PowerShell guards parse the matrix locally and make no network call. | No checked GCP, AWS, GitHub, Slack, or JWT credential grammar. | Retain: changing these semantic contract labels could weaken or obscure the reviewed test matrix and would not remove historical findings. | Yes, for each historical fingerprint and, if emitted, each current working-tree fingerprint only. |
| 15–20 | Historical Firebase/GCP client credentials. | GCP API-key structure; provider disposition is now deleted/inactive. | Do not replace history; the current application has no tracked Firebase configuration or GCP key shape. | Yes, for each historical scanner fingerprint only. |

No exception permits a rule, path, extension, directory, commit range, or
reduced scan depth. The final history and working-tree scans determine whether
any additional exact current-working-tree fingerprints are required.

## Scope and safety boundary

This register is the one-finding-per-row disposition of the checksum-verified
Gitleaks 8.30.1 full-history scan. It records redacted metadata only. It never
contains a complete credential, replacement credential, source excerpt with a
credential, or unredacted provider-console evidence.

- Scan input: 97 Git commits; 20 findings.
- Current repository policy evidence: no `SECURITY.md` was found. Product rules
  and current source retire Firebase from the client, but they cannot establish
  whether a historical Google Cloud key remains active.
- Static counterevidence: no tracked Firebase configuration, generated
  `firebase_options.dart`, Google Services file, or Firebase package remains in
  the current application.
- Preservation snapshot: the pre-security-remediation patch was deliberately
  kept outside the repository and is not part of the publication inventory.
- Exception state: **none**. Every `Yes` below is conditional on completed
  provider remediation and a later exact-fingerprint-only review.

## Credential correlation without credential disclosure

The six `gcp-api-key` findings are three distinct historical client-key
credentials, all structurally associated with redacted project `the…ste`:

| Credential group | Findings | Static association | Current validity |
|---|---:|---|---|
| A | 16, 20 | Web and Windows generated options | Unknown — provider review required |
| B | 15, 17 | Android Google Services and Android generated options | Unknown — provider review required |
| C | 18, 19 | iOS and macOS generated options | Unknown — provider review required |

This correlation does not deduplicate the findings. Each scanner occurrence is
retained below and must receive its own final disposition.

## Finding register

| # | Rule / fingerprint | Commit / path | Classification | Provider/project | Current validity | Remediation | Exception eligibility | Reviewer | Redacted evidence |
|---:|---|---|---|---|---|---|---|---|---|
| 1 | `generic-api-key`<br>`d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f:.agents/skills/figma-implement-design/SKILL.md:generic-api-key:51` | `d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f`<br>`.agents/skills/figma-implement-design/SKILL.md:51` | Example | Figma instructional text; no provider project | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | Instructional file-key label; no GCP prefix or runtime consumer. |
| 2 | `generic-api-key`<br>`d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f:.agents/skills/figma-implement-design/SKILL.md:generic-api-key:171` | `d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f`<br>`.agents/skills/figma-implement-design/SKILL.md:171` | Example | Figma instructional text; no provider project | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | Button-component example uses a Figma file-key/node-id teaching literal; no GCP prefix. |
| 3 | `generic-api-key`<br>`d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f:.agents/skills/figma-implement-design/SKILL.md:generic-api-key:172` | `d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f`<br>`.agents/skills/figma-implement-design/SKILL.md:172` | Example | Figma instructional text; no provider project | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | Button-component example instruction; no credential-shaped provider key. |
| 4 | `generic-api-key`<br>`d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f:.agents/skills/figma-implement-design/SKILL.md:generic-api-key:173` | `d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f`<br>`.agents/skills/figma-implement-design/SKILL.md:173` | Example | Figma instructional text; no provider project | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | Button-component example instruction; no credential-shaped provider key. |
| 5 | `generic-api-key`<br>`d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f:.agents/skills/figma-implement-design/SKILL.md:generic-api-key:188` | `d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f`<br>`.agents/skills/figma-implement-design/SKILL.md:188` | Example | Figma instructional text; no provider project | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | Dashboard example uses Figma file-key/node-id teaching text; no GCP prefix. |
| 6 | `generic-api-key`<br>`d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f:.agents/skills/figma-implement-design/SKILL.md:generic-api-key:189` | `d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f`<br>`.agents/skills/figma-implement-design/SKILL.md:189` | Example | Figma instructional text; no provider project | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | Dashboard example uses Figma file-key/node-id teaching text; no GCP prefix. |
| 7 | `generic-api-key`<br>`d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f:.agents/skills/figma-implement-design/SKILL.md:generic-api-key:191` | `d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f`<br>`.agents/skills/figma-implement-design/SKILL.md:191` | Example | Figma instructional text; no provider project | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | Dashboard example instruction; no credential-shaped provider key. |
| 8 | `generic-api-key`<br>`d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f:.agents/skills/figma-implement-design/SKILL.md:generic-api-key:192` | `d3799bccdbf746b5eb3ba6e4625bdc9ab94a588f`<br>`.agents/skills/figma-implement-design/SKILL.md:192` | Example | Figma instructional text; no provider project | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | Dashboard example instruction; no credential-shaped provider key. |
| 9 | `generic-api-key`<br>`f61d874eaa539d59c45ea90c2afd06e63999aafd:supabase/tests/authority_contract_matrix.json:generic-api-key:9` | `f61d874eaa539d59c45ea90c2afd06e63999aafd`<br>`supabase/tests/authority_contract_matrix.json:9` | Matrix fixture | Supabase local authority-contract metadata | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | JSON `auth_mode` text; human-readable authentication-contract field, no provider key structure. |
| 10 | `generic-api-key`<br>`f61d874eaa539d59c45ea90c2afd06e63999aafd:supabase/tests/authority_contract_matrix.json:generic-api-key:28` | `f61d874eaa539d59c45ea90c2afd06e63999aafd`<br>`supabase/tests/authority_contract_matrix.json:28` | Matrix fixture | Supabase local authority-contract metadata | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | JSON `auth_mode` text; human-readable authentication-contract field, no provider key structure. |
| 11 | `generic-api-key`<br>`f61d874eaa539d59c45ea90c2afd06e63999aafd:supabase/tests/authority_contract_matrix.json:generic-api-key:47` | `f61d874eaa539d59c45ea90c2afd06e63999aafd`<br>`supabase/tests/authority_contract_matrix.json:47` | Matrix fixture | Supabase local authority-contract metadata | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | JSON `auth_mode` text; human-readable authentication-contract field, no provider key structure. |
| 12 | `generic-api-key`<br>`f61d874eaa539d59c45ea90c2afd06e63999aafd:supabase/tests/authority_contract_matrix.json:generic-api-key:66` | `f61d874eaa539d59c45ea90c2afd06e63999aafd`<br>`supabase/tests/authority_contract_matrix.json:66` | Matrix fixture | Supabase local authority-contract metadata | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | JSON `auth_mode` text; human-readable authentication-contract field, no provider key structure. |
| 13 | `generic-api-key`<br>`f61d874eaa539d59c45ea90c2afd06e63999aafd:supabase/tests/authority_contract_matrix.json:generic-api-key:85` | `f61d874eaa539d59c45ea90c2afd06e63999aafd`<br>`supabase/tests/authority_contract_matrix.json:85` | Matrix fixture | Supabase local authority-contract metadata | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | JSON `auth_mode` text; human-readable authentication-contract field, no provider key structure. |
| 14 | `generic-api-key`<br>`f61d874eaa539d59c45ea90c2afd06e63999aafd:supabase/tests/authority_contract_matrix.json:generic-api-key:104` | `f61d874eaa539d59c45ea90c2afd06e63999aafd`<br>`supabase/tests/authority_contract_matrix.json:104` | Matrix fixture | Supabase local authority-contract metadata | N/A — noncredential literal | After Directive 3, review this exact fingerprint only. | Yes — conditional | Codex | JSON `auth_mode` text; human-readable authentication-contract field, no provider key structure. |
| 15 | `gcp-api-key`<br>`554be9e3032b337df4bc0b174579a2062ec076bc:android/app/google-services.json:gcp-api-key:18` | `554be9e3032b337df4bc0b174579a2062ec076bc`<br>`android/app/google-services.json:18` | Confirmed key | Google Cloud/Firebase `the…ste` | Unknown | Smiley: identify project and key; check existence, status, API/application restrictions, and recent usage; restrict, rotate, revoke, or record deletion. | No — pending provider remediation | Smiley | `google-services.json` `api_key.current_key` has GCP API-key structure; credential group B. |
| 16 | `gcp-api-key`<br>`554be9e3032b337df4bc0b174579a2062ec076bc:lib/firebase_options.dart:gcp-api-key:44` | `554be9e3032b337df4bc0b174579a2062ec076bc`<br>`lib/firebase_options.dart:44` | Confirmed key | Google Cloud/Firebase `the…ste` | Unknown | Smiley: identify project and key; check existence, status, API/application restrictions, and recent usage; restrict, rotate, revoke, or record deletion. | No — pending provider remediation | Smiley | Historical generated `FirebaseOptions.web` has GCP API-key structure; credential group A. |
| 17 | `gcp-api-key`<br>`554be9e3032b337df4bc0b174579a2062ec076bc:lib/firebase_options.dart:gcp-api-key:54` | `554be9e3032b337df4bc0b174579a2062ec076bc`<br>`lib/firebase_options.dart:54` | Confirmed key | Google Cloud/Firebase `the…ste` | Unknown | Smiley: identify project and key; check existence, status, API/application restrictions, and recent usage; restrict, rotate, revoke, or record deletion. | No — pending provider remediation | Smiley | Historical generated `FirebaseOptions.android` has GCP API-key structure; credential group B. |
| 18 | `gcp-api-key`<br>`554be9e3032b337df4bc0b174579a2062ec076bc:lib/firebase_options.dart:gcp-api-key:62` | `554be9e3032b337df4bc0b174579a2062ec076bc`<br>`lib/firebase_options.dart:62` | Confirmed key | Google Cloud/Firebase `the…ste` | Unknown | Smiley: identify project and key; check existence, status, API/application restrictions, and recent usage; restrict, rotate, revoke, or record deletion. | No — pending provider remediation | Smiley | Historical generated `FirebaseOptions.ios` has GCP API-key structure; credential group C. |
| 19 | `gcp-api-key`<br>`554be9e3032b337df4bc0b174579a2062ec076bc:lib/firebase_options.dart:gcp-api-key:71` | `554be9e3032b337df4bc0b174579a2062ec076bc`<br>`lib/firebase_options.dart:71` | Confirmed key | Google Cloud/Firebase `the…ste` | Unknown | Smiley: identify project and key; check existence, status, API/application restrictions, and recent usage; restrict, rotate, revoke, or record deletion. | No — pending provider remediation | Smiley | Historical generated `FirebaseOptions.macos` has GCP API-key structure; credential group C. |
| 20 | `gcp-api-key`<br>`554be9e3032b337df4bc0b174579a2062ec076bc:lib/firebase_options.dart:gcp-api-key:80` | `554be9e3032b337df4bc0b174579a2062ec076bc`<br>`lib/firebase_options.dart:80` | Confirmed key | Google Cloud/Firebase `the…ste` | Unknown | Smiley: identify project and key; check existence, status, API/application restrictions, and recent usage; restrict, rotate, revoke, or record deletion. | No — pending provider remediation | Smiley | Historical generated `FirebaseOptions.windows` has GCP API-key structure; credential group A. |

## Required provider evidence for findings 15–20

Smiley must provide a redacted disposition for each credential group without
including a key value:

```text
Finding fingerprint:
Project: redacted identifier
Status: restricted / rotated / revoked / project deleted
Evidence reviewed: Yes
Complete key exposed in report: No
```

The only acceptable next states are:

- active and insufficiently restricted — restrict immediately and rotate where
  practical;
- active but no longer needed — revoke or delete;
- deleted project — record deletion evidence; or
- cannot identify or verify — remain `Blocked`.

After provider remediation is evidenced, re-run the checksum-verified binary
with `gitleaks git --redact --verbose` and `gitleaks dir . --redact --verbose`.
Only then may exact fingerprints, and no broader exclusions, be considered.

## 2026-07-29 completed provider remediation and final scan receipt

Status: `Passed` for the local secret-history and working-tree verification
gate. This is not remote-provider, device, CI, or release-readiness evidence.

- Smiley's redacted provider-console disposition confirms that the three
  credential groups are deleted and inactive: findings 15/17, 16/20, and
  18/19. The project identifier remains redacted as `the...ste`; no key value
  or display name was recorded.
- The final, checksum-verified Gitleaks 8.30.1 history scan completed across
  97 commits with no leaks found.
- The final Gitleaks 8.30.1 working-tree scan completed after generated
  Flutter output was cleared, with no leaks found.
- `.gitleaksignore` contains only 45 reviewed, exact fingerprints: 20
  historical findings and 25 current false positives. It does not disable a
  rule or exclude a path, extension, directory, commit range, or scan depth.
- Seven unused local Firebase configuration fields were removed before the
  final scan. Static inspection continues to find no Firebase runtime package,
  generated options file, Google Services file, or Firebase initialization in
  current source; Supabase remains the application identity boundary.

The historical register below remains intact as audit evidence. This receipt
supersedes its earlier pending-provider language and authorizes no commit,
push, deployment, remote Supabase action, or readiness promotion.

### Exact-fingerprint cross-reference

The reviewed `.gitleaksignore` inventory has 45 unique entries and no broad
path, rule, commit-range, history, or scan-depth exclusion. Each exact entry
is accounted for by one of these register categories; no credential value is
present in this document or the ignore file.

| Entries | Register mapping | Current purpose |
|---:|---|---|
| 8 historical + 8 current | Findings 1-8 | Documentation placeholders in the Figma instruction file. |
| 6 historical + 7 current | Findings 9-14 | Authority-matrix test values; the seventh current occurrence is the additional reviewed matrix line. |
| 6 historical | Findings 15-20 | Externally deleted or inactive historical Firebase/GCP credentials. |
| 3 current | Baseline-hash record | SHA-256 evidence values that resemble generic-key syntax. |
| 6 current | Migration-hash manifest | SHA-256 evidence values that resemble generic-key syntax. |
| 1 current | Local environment compatibility value | Reviewed public legacy Supabase anonymous-token fallback; not a service-role credential. |

The 20 historical entries correspond one-for-one with the immutable finding
register. The 25 current entries are the exact reviewed locations described
above. This table is the cross-reference used by the publication inventory and
does not weaken future scans for new occurrences.

## 2026-07-29 local verification companion record

Docker Desktop recovery completed without deleting local Supabase volumes,
images, or database state. The local-only verification sequence then completed
with these observed results:

| Check | Result | Evidence |
|---|---|---|
| Docker engine / Supabase CLI | `Passed` | Docker Engine 29.6.2; Supabase CLI 2.104.0. |
| `supabase stop` then `supabase start` | `Passed` | Core local services became healthy; no remote project was linked or accessed. |
| `supabase db reset --local --no-seed` | `Passed` | 61 local migrations applied. |
| `supabase db lint --local` | `Passed` with warnings | Six non-fatal warnings in legacy public functions. |
| `supabase test db` | `Passed` | 12 test files, 108 assertions. |
| Kingston economic concurrency harness | `Passed` | Four 20-session mutation/replay-lock scenarios. |
| API inventory comparison | `Passed` | 19 generated API entries exactly matched the reviewed inventory. |
| Migration hash verification | `Passed` | Dedicated manifest now covers all 61 files; validator and tamper tests passed. |

This does not alter any Gitleaks disposition. No exception was added, no key
value was recorded, and the provider-remediation gate for findings 15–20 remains
`Blocked`. The previously checksum-verified scanner is no longer present in its
temporary location, so no new Gitleaks scan was substituted for the recorded
20-finding history result.
