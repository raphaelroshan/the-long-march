# Authored Route Intel Report

**Build:** `0.3.0-alpha.331`

## Player-facing change

Ashgate Depot's Signal Broker now sells the **Orchard Weather Report** for 8 Ashmarks. Before purchase, the Soot Orchard retains its normal forecast-level warning. After purchase, the route dossier names the exact Storm Front contact, its authored preparation guidance, the **Ashgate Signal Reader** source, and **Reliable** confidence.

The purchase explicitly changes no fuel, time, pressure, route risk, or encounter difficulty. Those mechanical benefits remain the domain of an operational forecast system or Iven Pell. Information and mitigation are therefore separate, legible decisions.

The required Morrowline contract still owns the assignment board until answered. Once recorded, that desk becomes the Marchmaster's Orders station and retains both optional mastery experiments; the new broker offer does not delete an existing replay goal.

## Authority and persistence

- `FortressState` owns the offer definition, eligibility, price, acquired stable IDs, and route reveal.
- Purchase is atomic: invalid location, insufficient funds, or duplicate purchase leaves money and intel unchanged.
- Save schema 9 persists acquired intel; schema-8 saves migrate with an empty ledger rather than inventing a purchase.
- Unknown, duplicate, or cross-region intel records are rejected during restore.
- Presenters and UI consume copied state and never infer a mechanical discount from the report.

## Verification contract

Deterministic tests cover purchase cost, duplicate and insufficient-funds rejection, exact reveal fields, unchanged route mechanics, save/load, migration, and malformed records. Settlement coverage follows the visible flow from broker purchase to sourced Soot Orchard dossier while preserving the assignment and field-order sequence.

## Visual evidence

- [`Signal Broker acquired report`](visual_evidence/v0.3.0-alpha.331-authored-route-intel/02b_signal_report.png)
- [`Sourced Soot Orchard route dossier`](visual_evidence/v0.3.0-alpha.331-authored-route-intel/03b_route_selected.png)
