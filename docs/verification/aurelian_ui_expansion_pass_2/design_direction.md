# Aurelian UI Expansion Pass 2 — Design Direction

Date: 2026-07-29
Status: implementation direction; final visual approval remains pending Smiley

## Subject, audience, and job

The subject is a young founder building a luxury fashion House from Kingston.
The audience is young adults who should feel authorship, competence, glamour,
and commercially grounded ambition. Each screen has one job: help the player
understand the House’s present condition and make the next currently authorized
choice.

## Compact design plan

### Color

The existing canonical palette remains authoritative:

- **Obsidian** `#090909` — executive authority, night, and Feed depth.
- **Ivory** `#FFFCF4` — editorial clarity and House identity.
- **Champagne gold** `#D6A84F` — commitment, selection, and ceremony.
- **Deep gold** `#7C5800` — readable light-mode emphasis and tailoring lines.
- **Oxidized/warm structure** — existing bronze/warm-grey tokens for machinery,
  annotations, boundaries, and historical weight.
- **Semantic signals** — the existing profit, warning, danger, and information
  tokens, always paired with text or iconography.

Gold remains scarce. It is not used to make routine content look prestigious.

### Type

- **Space Grotesk** — House voice, editorial display, concise headlines.
- **Inter** — instructions, explanations, legal text, and readable body copy.
- **JetBrains Mono** — receipts, counts, stages, and authoritative evidence.

The type itself carries hierarchy; additional fonts are neither needed nor
authorized.

### Layout concepts

Onboarding uses a ceremonial editorial aperture:

```text
┌────────────────────────────┐
│ HOUSE / KINGSTON           │
│                            │
│ Singular invitation       │
│ with tailoring linework   │
│                            │
│ [ one primary action ]     │
│ grounded authority note   │
└────────────────────────────┘
```

Operational screens use a subject-and-evidence composition:

```text
┌────────────────────────────┐
│ Context / current stage    │
│ Primary subject            │
│ garment / House / store    │
│ ─ construction annotation │
│ [ one primary action ]     │
│                            │
│ Evidence / blockers        │
│ Secondary detail           │
└────────────────────────────┘
```

Reliability states use a stable state dossier:

```text
┌────────────────────────────┐
│ ICON  STATE                │
│ What is happening          │
│ What remains preserved     │
│ LOCAL / SERVER / RECEIPT   │
│ [ next safe action ]       │
└────────────────────────────┘
```

### Signature

The memorable element is the **Aurelian cut line**: restrained pattern-cutting
geometry that changes meaning by surface. It frames the opening as a garment
aperture, connects the three-look capsule, becomes a measured process line in
Empire, and acts as an editorial rule in Feed. It is built from canonical
tokens and lightweight custom painting, with a static reduced-motion form.

Kingston is communicated through language and material logic—tailoring, sound,
streetwear, resourceful studio practice, community proof, and global creative
authority—not through flags, tourist shorthand, invented patois, or unreviewed
imagery.

## Self-critique before implementation

The first generic option was a monochrome fashion landing page with oversized
type and a pink conversion button. It was rejected because it could belong to
any fashion product, conflicts with Aurelian Radiance, and treats a game screen
like marketing.

The revised direction is specific to The Styliste because structural marks
encode real garment roles, state provenance, readiness, and House authority.
Cards are retained only when they group actionable information; visual depth
comes from subject/evidence relationships and material contrast rather than
adding more panels.

The controlled risk is using asymmetric cut-line composition across multiple
screen families. It is justified by fashion authorship and remains quiet enough
not to obscure state, text scaling, or touch behavior.
