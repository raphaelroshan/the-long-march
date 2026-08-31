# Threat Risk Preview Report

**Build:** `0.3.0-alpha.319`

## Player question

Before advancing contact, can the player state what the current threat will put at risk if it is not answered?

## Change

Each implemented threat family now carries a concise `RISK IF IGNORED` statement in the live contact dossier. The statement sits between the authored counter and the current-fortress readiness receipt, creating a direct sequence:

```text
approach and preferred target
→ general counter
→ risk if ignored
→ counter ready on this fortress
```

The copy describes existing target and damage behavior. It does not alter encounter timing, targeting, damage, intervention legality, or random streams.

## Verification

- Presentation coverage requires all seven threat families to expose the risk line before and after arrival.
- The complete prototype flow checks the Road Raider's specific cargo/exterior consequence before the first step.
- The full repository verification suite passes.

## Evidence

- [Road Raider response with risk and readiness](visual_evidence/v0.3.0-alpha.319-threat-risk-preview/08_road_contact.png)

This capture verifies that the information remains readable beside the fortress and emergency orders. It does not establish human prediction accuracy.
