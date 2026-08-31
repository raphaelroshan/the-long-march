# Target-Effective Counter Label Report

**Build:** `0.3.0-alpha.322`

## Player question

Does `READY NOW` mean that the named counter will affect this threat and its current target, rather than merely existing somewhere on the chassis?

## Change

After an enemy arrives and receives an authoritative target, the contact presenter compares installed counter readiness with the encounter's exact defense projection. A ready module or specialist keeps `READY NOW` when it contributes automatic damage or an impact buffer. If it is operational but its current position produces neither effect, the badge becomes:

```text
AVAILABLE · [system] · NO DIRECT EFFECT ON TARGET
```

The corresponding posture directs the player to inspect positioning and compare emergency orders. Before target assignment, the forecast retains ordinary readiness because positional applicability is not yet known.

## Verification

- Presenter tests cover effective, non-applying, offline, missing, and forecast states.
- Fortress-state tests cover automatic damage, adjacent armor, and direct front-plate bracing.
- Road-contact tests cover the caution badge and posture together.
- The full repository verification suite remains the release gate.

## Evidence

- [Civic Guardian with non-applying Front Armor](visual_evidence/v0.3.0-alpha.322-effective-counter/09_counter_available.png)

SHA-256: `958613f1bd13cc0d5e5bce97c8a417660553ef08406d59dd5810c382a2ca1f42`
