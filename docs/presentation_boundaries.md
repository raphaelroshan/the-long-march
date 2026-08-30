# Presentation Boundaries

The playable stage uses five read-only view-model builders in `src/presentation/`:

| Builder | Owns | Does not own |
|---|---|---|
| `settlement_presenter.gd` | Bazaar labels, station cards, action IDs, regional identity | Contract mutation, refit, route commitment |
| `route_presenter.gd` | Planner ledger and departure receipt | Route availability, cost application, encounter creation |
| `contact_presenter.gd` | Contact dossier, bounded report, target projection | Target choice, damage, intervention effects, encounter timing |
| `recovery_presenter.gd` | Service receipt and local road context | Prices, action budget, repairs, refuel, hull restoration |
| `debrief_presenter.gd` | Timeline, promises, condition summary, replay framing | Outcome calculation, unlocks, regional progress |

`src/ui/main.gd` gathers already-authoritative state plus current control labels, asks a presenter for a dictionary, and passes that dictionary to the existing view. The view emits the same stable command IDs back to `main.gd`; no presenter handles commands or writes state.

## Contract rules

- Builders must be deterministic and side-effect free.
- Inputs derived from controls are display strings and enabled flags only.
- Every mutable collection returned to a view is copied.
- Save fields and migration remain in `LongMarchState` and the application shell.
- Adding a new output field requires a focused assertion and an existing-flow assertion.
- Moving a gameplay decision into a presenter is an architecture regression.
