# Water Condenser Teaching Slice

## Design card

| Field | Decision |
|---|---|
| ID | `water_condenser` |
| Display name | Water Condenser |
| Content type | Interior sustain module plus one authored Ashgate route |
| Player question | Is one fuel saved on a dry road worth two chassis cells, one power draw, two heat, and a workshop-maintenance dependency? |
| Where it occurs | Stored at Ashgate; its route payoff appears at Morrowline through the Dry Cistern Cut. |
| What it changes | A ready condenser unlocks the Dry Cistern Cut and reduces that route's fuel cost by one, to a minimum of one. |
| Visible counter | The route card names the required ready condenser; the module inspector names power and adjacent-workshop maintenance. |
| Visible cost | 2×1 interior footprint, mass 2, power draw 1, heat 2, durability 3. |
| Failure or weakness | Without an adjacent operational Field Workshop it is strained and provides no route benefit. Storm Fronts target sustain systems; a disabled condenser removes the route benefit. |
| Eligibility | The Dry Cistern Cut is offered only from Morrowline while an installed condenser is Ready. |
| Repeat/cooldown policy | Not applicable; this is a deterministic route gate and module relationship. |
| Seed stream | No new stream. Existing deterministic encounter scheduling and targeting apply. |
| Save fields | None. Existing installed/stored module serialization and stable IDs carry all required state. |
| UI surface | Module picker, dependency card, chassis grid, Morrowline route comparison, map node, contact target rationale, recovery services, and debrief route record. |
| Teaching scenario | Install and maintain the condenser before Morrowline, compare the unlocked Dry Cistern Cut with Lower Ash Road and Signal Causeway, then survive its Storm Front contact. |
| Focused tests | Definition and placement; maintained versus strained states; route lock/unlock and fuel discount; Storm targeting; settlement/field repair; save round-trip; deterministic replay; UI card and route comparison. |
| Full verification command | `PATH=/tmp/godot441-bin:$PATH bash scripts/verify.sh` and `PATH=/tmp/long-march-bin:$PATH bash scripts/verify.sh` |
| Explicit non-goals | No water currency, survival meters, procedural routes, new region, generic utility inventory, or alternate combat engine. |

## Authoritative behavior

`LongMarchState` owns condenser readiness, route eligibility, fuel cost, targeting, repair, and persistence. UI code may only render the resulting module status, route preview, and command receipts.

The condenser is **Ready** only when it has shared power and touches an operational Field Workshop. Losing maintenance makes it **Strained**, not offline: the machinery still exists, but it cannot safely produce journey water and therefore provides no route unlock or fuel reduction.

The Dry Cistern Cut is a fourth-road teaching encounter, parallel to Lower Ash Road and Signal Causeway. It leads to Meridian Pass, preserving the five-encounter chapter structure. It is a short, comparatively controlled road only when the condenser is Ready; otherwise it remains visibly locked rather than disappearing.

## Counter matrix

| Pressure | Counter 1 | Counter 2 | Recovery |
|---|---|---|---|
| Workshop adjacency competes for chassis space | Rotate or reposition the 2×1 condenser beside the workshop | Rebuild around a smaller weapon or cargo commitment | Refit freely at Morrowline before selecting the road |
| Two added heat can push Run Hot over limit | Choose a protective doctrine | Reduce another heat-producing module | Vent Heat during contact, accepting exterior exposure |
| Storm Front targets the sustain system | Place adjacent armor | Use Seal Compartment after target assignment | Field Workshop or Morrowline module repair restores durability |

## Balance fixtures

- **Cool/light:** Steam Lance Engine, Coal Cell, Generator Core, Field Workshop, Crew Quarters, and Water Condenser. It keeps heat within limit and earns the dry-route fuel saving, but gives up weapon coverage.
- **Heavy/safe:** Starter fortress plus Water Condenser and protective armor after removing cargo or a secondary system. It can resist the Storm Front but approaches or exceeds mass and heat limits.

Neither fixture is the declared correct build. The tests should prove that both remain legal and that their visible costs differ.
