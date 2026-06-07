# UI_UX_OUTPUT_TEMPLATES.md

Reusable UI/UX output templates for **The Styliste** design sessions.

Use these templates with `THE_STYLISTE_GDD_v6.md`, `PROJECT_RULES.md`, `VERIFICATION_PROTOCOL.md`, and the current Flutter/Dart codebase as source of truth. Do not invent existing files, providers, Supabase tables, routes, models, or assets.

All UI/UX design directives must preserve Flutter/Riverpod/Supabase architecture, avoid direct client-side economy mutation, and include loading/error/offline/reduced-motion states.

---

# SCREEN_SPEC.md Template

## 1. Screen Purpose
- What this screen does:
- Why the player opens it:
- GDD support: Cite GDD v6 §[section].

## 2. Player Fantasy
- Desired feeling:
- Designer/Mogul/Luxe tone:
- Premium noir treatment:

## 3. Information Architecture
List sections in vertical order:

1. Header:
2. Primary action area:
3. Secondary panels:
4. Feedback/status area:
5. Navigation/CTA area:

## 4. Layout Blueprint

```txt
+-------------------------------+
| Header / Status Context       |
+-------------------------------+
| Primary Hero / Player Focus   |
+-------------------------------+
| Key Metrics / Decision Cards  |
+-------------------------------+
| Feedback / State Messaging    |
+-------------------------------+
| Primary CTA / Bottom Nav Safe |
+-------------------------------+
```

## 5. Components Required

| Component | Purpose | Data Source | State |
| --------- | ------- | ----------- | ----- |
| [Component name] | [What it communicates or enables] | [Provider/model/table, or UNCERTAIN] | Loading / Empty / Success / Error / Offline / Locked |

## 6. UX States

- Loading:
- Empty:
- Success:
- Error:
- Offline:
- Locked:
- Insufficient resources:
- Server sync pending:

## 7. Interaction Design

| Interaction | Input | Feedback | Backend Action |
| ----------- | ----- | -------- | -------------- |
| [Action] | Tap / drag / long press / swipe | Visual, haptic, copy, disabled state | None / provider command / Supabase RPC through repository |

## 8. Motion / Animation Spec

| Animation | Trigger | Duration | Curve | Performance Rule |
| --------- | ------- | -------- | ----- | ---------------- |
| [Animation name] | [Trigger] | 120-220ms / 250-450ms / max 900ms | [Flutter curve] | Respect reduced motion; avoid heavy blur/shader loops |

## 9. Visual Style

- Color role:
- Typography role:
- Icon style:
- Depth/shadow/glass usage:
- Premium/noir treatment:
- Reusable design token needed: Yes / No. If yes, define role and usage only.

## 10. Accessibility

- Minimum tap target: 48x48.
- Text contrast:
- Reduced motion fallback:
- Screen reader labels:
- Number formatting readability:
- Haptic fallback off:

## 11. Flutter Implementation Notes

- Suggested widget structure:
- Riverpod provider usage:
- Supabase usage:
- Reusable components:
- Files likely affected:
- Must stay out of UI layer:
- Performance notes:

## 12. IDE_DIRECTIVES.md

Directive 1: In `[file]`, add/replace `[specific widget/component]` with `[implementation description]`. Use `[Riverpod/Supabase/domain pattern]`. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

Directive 2: Search the codebase for `[symbol/file/provider]`. If it exists, modify it. If it does not exist, create `[new file]` under `[correct folder]`. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

## 13. QA Checklist

- `flutter analyze`
- `flutter test`
- Manual portrait layout check
- Offline/error state check
- Reduced motion check
- No direct client economy mutation
- No hardcoded fake rewards unless explicitly marked mock/dev-only
- Server-authoritative values are displayed from providers/repositories only

---

# FEATURE_UX_SPEC.md Template

## 1. Feature Purpose
- Player problem solved:
- Game loop supported:
- GDD support: Cite GDD v6 §[section].

## 2. Player Fantasy
- Fantasy:
- Designer/Mogul/Luxe tone:
- Emotional beat:

## 3. User Flow

1. Entry point:
2. First decision:
3. Primary action:
4. Confirmation or result:
5. Recovery path:
6. Return path:

## 4. Layout Blueprint

```txt
+-------------------------------+
| Entry Context / Header        |
+-------------------------------+
| Feature Control Surface       |
+-------------------------------+
| Supporting Data / Preview     |
+-------------------------------+
| State Feedback / Risk Copy    |
+-------------------------------+
| CTA / Confirmation Area       |
+-------------------------------+
```

## 5. Components Required

| Component | Purpose | Data Source | State |
| --------- | ------- | ----------- | ----- |
| [Component name] | [Feature role] | [Provider/model/table, or UNCERTAIN] | Loading / Empty / Success / Error / Offline / Locked |

## 6. UX States

- Loading:
- Empty:
- Success:
- Error:
- Offline:
- Locked:
- Insufficient resources:
- Server sync pending:
- Permission denied:
- Conflict/stale data:

## 7. Interaction Design

| Interaction | Input | Feedback | Backend Action |
| ----------- | ----- | -------- | -------------- |
| [Action] | [Input] | [Immediate local feedback] | [Repository/provider call; never direct mutation inside widget] |

## 8. Motion / Animation Spec

| Animation | Trigger | Duration | Curve | Performance Rule |
| --------- | ------- | -------- | ----- | ---------------- |
| [Animation] | [Trigger] | [Duration] | [Curve] | [Reduced motion and 60fps guardrail] |

## 9. Visual Style

- Color role:
- Typography role:
- Icon style:
- Depth/shadow/glass usage:
- Premium/noir treatment:

## 10. Accessibility

- Minimum tap target: 48x48.
- Text contrast:
- Reduced motion fallback:
- Screen reader labels:
- Number formatting readability:
- Haptic fallback off:
- Error copy clarity:

## 11. Flutter Implementation Notes

- Suggested widget structure:
- Riverpod provider usage:
- Supabase usage:
- Reusable components:
- Files likely affected:
- Must stay out of UI layer:
- Cache/local persistence rules:

## 12. IDE_DIRECTIVES.md

Directive 1: Search the codebase for `[feature/provider/model]`. If it exists, extend it through the existing Riverpod/domain/data pattern. If it does not exist, create `[new file]` under `[folder]` with no direct Supabase mutations inside widgets. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

Directive 2: In `[screen/widget file]`, add `[feature UI]` with loading, empty, error, offline, locked, insufficient resources, and server sync pending states. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

## 13. QA Checklist

- `flutter analyze`
- `flutter test`
- Manual portrait layout check
- Offline/error state check
- Reduced motion check
- No direct client economy mutation
- No hardcoded fake rewards unless explicitly marked mock/dev-only
- Supabase writes go through repository/domain layer only
- Premium/convenience language avoids pay-to-win pressure

---

# ANIMATION_SPEC.md Template

## 1. Animation Purpose
- What comprehension or feeling this animation supports:
- Screen/feature:
- GDD support: Cite GDD v6 §[section].

## 2. Motion Principles
- Tone:
- Default duration:
- Max cinematic duration:
- Reduced motion behavior:

## 3. Layout Impact

```txt
+-------------------------------+
| Static Safe Area              |
+-------------------------------+
| Animated Element Zone         |
+-------------------------------+
| Non-animated Data/CTA Zone    |
+-------------------------------+
```

## 4. Components Required

| Component | Purpose | Data Source | State |
| --------- | ------- | ----------- | ----- |
| [Animated component] | [Motion role] | [Provider/model/table, or none] | Loading / Success / Error / Reduced motion |

## 5. UX States

- Loading:
- Empty:
- Success:
- Error:
- Offline:
- Locked:
- Insufficient resources:
- Server sync pending:
- Reduced motion:

## 6. Interaction Design

| Interaction | Input | Feedback | Backend Action |
| ----------- | ----- | -------- | -------------- |
| [Interaction] | [Input] | [Animation feedback] | None / provider action |

## 7. Motion / Animation Spec

| Animation | Trigger | Duration | Curve | Performance Rule |
| --------- | ------- | -------- | ----- | ---------------- |
| Micro response | Tap/state change | 120-220ms | easeOutCubic | Transform/opacity preferred; respect reduced motion |
| Screen transition | Route/screen change | 250-450ms | easeInOutCubic | Avoid rebuilding full dashboard on each frame |
| Cinematic reveal | First entry/key milestone | max 900ms | easeOutCubic | One-shot only; no blocking progression |

## 8. Performance Risk
- GPU risk:
- CPU/rebuild risk:
- Memory risk:
- Scroll risk:
- Mitigation:

## 9. Visual Style

- Color role:
- Typography role:
- Icon style:
- Depth/shadow/glass usage:
- Premium/noir treatment:

## 10. Accessibility

- Minimum tap target: 48x48.
- Text contrast:
- Reduced motion fallback:
- Screen reader labels:
- Number formatting readability:
- Haptic fallback off:

## 11. Flutter Implementation Notes

- Suggested widget structure:
- Riverpod provider usage:
- Supabase usage:
- Reusable components:
- Files likely affected:
- Must stay out of UI layer:
- Use `AnimationController`, implicit animation, or `CustomPainter`:
- Dispose/lifecycle notes:

## 12. IDE_DIRECTIVES.md

Directive 1: In `[file]`, add `[animation widget/controller]` around `[component]`. Use reduced-motion detection and avoid animation-driven economy changes. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

Directive 2: In `[test file]`, add/adjust tests for reduced motion and stable widget state. Test: `flutter test [path]`. Cite GDD v6 §`[section]`.

## 13. QA Checklist

- `flutter analyze`
- `flutter test`
- Manual portrait layout check
- Offline/error state check
- Reduced motion check
- No direct client economy mutation
- No hardcoded fake rewards unless explicitly marked mock/dev-only
- Confirm no infinite heavy shader loop
- Confirm scrolling remains smooth on mid-range Android target

---

# IDE_DIRECTIVES.md Template

Directive 1: Search the codebase for `[existing screen/provider/model/route]`. If it exists, modify it in place using existing Flutter, Riverpod, Supabase, domain, data, and core patterns. If it does not exist, create `[new file]` under `[folder]`. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

Directive 2: In `[file]`, add/replace `[specific widget/component]` with `[implementation description]`. Keep business logic and Supabase mutations outside widgets. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

Directive 3: In `[provider/repository/domain file]`, expose only the UI state needed by `[screen/feature]`. Do not invent economy values, rewards, followers, rank, XP, valuation, Luxe rewards, or idle earnings in the UI. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

Directive 4: Add UX states for loading, empty, success, error, offline, locked, insufficient resources, and server sync pending. Test: run the screen in portrait and force/mock each state. Cite GDD v6 §`[section]`.

Directive 5: Add reduced-motion handling for `[animation]`, with default animation duration `[duration]` and fallback `[fallback]`. Test: enable reduced motion and confirm no essential information is lost. Cite GDD v6 §`[section]`.

Directive 6: Verify accessibility: 48x48 tap targets, sufficient text contrast, readable number formatting, screen reader labels, and haptic fallback off. Test: manual accessibility inspection plus relevant widget tests. Cite GDD v6 §`[section]`.

Directive 7: Run `flutter analyze` and `flutter test`. Confirm no runtime code outside the intended files changed. Cite GDD v6 §`[section]`.

---

# UX_AUDIT.md Template

## 1. Audit Scope
- Screen/feature audited:
- Files inspected:
- GDD support: Cite GDD v6 §[section].

## 2. Current UX Summary
- What works:
- What is unclear:
- What risks player comprehension:

## 3. Layout Blueprint Observed

```txt
+-------------------------------+
| Current Header                |
+-------------------------------+
| Current Primary Area          |
+-------------------------------+
| Current Secondary Content     |
+-------------------------------+
| Current CTA / Navigation      |
+-------------------------------+
```

## 4. Components Audited

| Component | Purpose | Data Source | State |
| --------- | ------- | ----------- | ----- |
| [Component] | [Observed purpose] | [Observed provider/model/table, or UNCERTAIN] | [Observed states] |

## 5. UX States Audit

- Loading:
- Empty:
- Success:
- Error:
- Offline:
- Locked:
- Insufficient resources:
- Server sync pending:
- Missing states:

## 6. Interaction Audit

| Interaction | Input | Feedback | Backend Action |
| ----------- | ----- | -------- | -------------- |
| [Interaction] | [Observed input] | [Observed feedback] | [Observed action, or UNCERTAIN] |

## 7. Motion / Animation Audit

| Animation | Trigger | Duration | Curve | Performance Rule |
| --------- | ------- | -------- | ----- | ---------------- |
| [Observed animation] | [Trigger] | [Duration, or UNCERTAIN] | [Curve, or UNCERTAIN] | [Risk or pass] |

## 8. Visual Style Audit

- Color role:
- Typography role:
- Icon style:
- Depth/shadow/glass usage:
- Premium/noir treatment:
- Brand fit:

## 9. Accessibility Audit

- Minimum tap target: Pass / Fail / UNCERTAIN.
- Text contrast: Pass / Fail / UNCERTAIN.
- Reduced motion fallback: Pass / Fail / UNCERTAIN.
- Screen reader labels: Pass / Fail / UNCERTAIN.
- Number formatting readability: Pass / Fail / UNCERTAIN.
- Haptic fallback off: Pass / Fail / UNCERTAIN.

## 10. Flutter Implementation Findings

- Widget structure:
- Riverpod provider usage:
- Supabase usage:
- Reusable components:
- Files likely affected:
- What must stay out of UI layer:
- Performance concerns:

## 11. Recommendations

| Priority | Recommendation | Reason | Implementation Risk |
| -------- | -------------- | ------ | ------------------- |
| P0/P1/P2 | [Recommendation] | [Why it matters] | Low / Medium / High |

## 12. IDE_DIRECTIVES.md

Directive 1: In `[file]`, add/replace `[specific widget/component]` with `[implementation description]`. Use the existing Riverpod/Supabase/domain pattern. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

Directive 2: Add or verify `[missing UX state]` for `[component]`. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

Directive 3: Add or verify `[accessibility/performance fix]`. Test: `[specific test steps]`. Cite GDD v6 §`[section]`.

## 13. QA Checklist

- `flutter analyze`
- `flutter test`
- Manual portrait layout check
- Offline/error state check
- Reduced motion check
- No direct client economy mutation
- No hardcoded fake rewards unless explicitly marked mock/dev-only
- Confirm Supabase writes remain outside widgets
- Confirm recommendations do not rewrite unrelated systems
