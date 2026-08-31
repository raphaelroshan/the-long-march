# Inhabited Fortress-at-Rest Report

**Build:** `0.3.0-alpha.304`

## Purpose

The starting bazaars already framed the fortress as the center of settlement work, but the machine itself remained visually frozen. This pass makes it feel inhabited and serviceable before departure without inventing a maintenance simulation.

## Presentation changes

- Three crew-scale workers establish the fortress's physical scale.
- A rail-side service crane and restrained hoist motion connect the machine to workshop labor.
- A grounded parts cart makes routine maintenance visible at leg level.
- Pressure-valve exhaust and a low lamp cycle keep the settled hull alive without suggesting travel.
- Ashgate and Lantern Quay retain their existing regional material and weather treatments.
- Reduced Motion freezes all ambient movement while preserving the crane, crew, cart, and service-readable composition.

## Architecture boundary

The settlement canvas owns one presentation-only idle phase and passes it to the shared silhouette. `FortressState`, resource budgets, service costs, save data, route timing, and command results are unchanged. No visual activity implies that a repair or transaction has occurred.

## Verification

- Fortress presentation tests cover the stable activity signature and Reduced Motion treatment.
- Settlement tests cover accessibility propagation and confirm normal departure motion resumes after the isolated accessibility check.
- Application-shell tests verify a persisted Reduced Motion preference reaches the settlement, road, and contact canvases.
- Both starting bazaars were captured at 1280×720 and visually inspected.

## Remaining human question

An uncoached player should be asked what they believe the fortress is and what happens at rest. The desired answer is a working settlement being maintained for the next road, not a static combat vehicle or a background building.
