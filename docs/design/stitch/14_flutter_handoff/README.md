# Flutter Handoff Notes

Implementation order for this branch:

1. Flutter CI and organized docs-only Stitch references.
2. Luxe recovery and Vex visual primitives.
3. Drop Preview and Atelier recovery polish.
4. Power-move RPC ownership SQL test.

Keep all gameplay state server-authoritative. Client UI may style or recover from results; it must not mint rewards, mutate economy state, or invent final metrics.
