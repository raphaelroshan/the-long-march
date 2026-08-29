# Fortress Visual-State Inventory

## Purpose

This inventory is the presentation contract for the shared side-on fortress. It translates authoritative module and journey state into a small, consistent visual language without adding simulation rules. The same hull proportions, roof block, legs, module order, signal mast, and forward mount must remain recognizable in settlement, travel, contact, recovery, arrival, and Debrief.

The renderer follows three layers of information:

1. **Identity:** stable silhouette, family pictograms, timber braces, patched plate, canvas, engine housing, signal hardware, and cargo restraint lines.
2. **Condition:** one primary mark inside each module bay. Competing damage, dependency, and intervention marks are reduced by the precedence below.
3. **Intent and place:** target brackets remain outside the bay; Ashgate dust/heat and Veyru rain/water treatment sit on the hull rather than replacing module state.

## Module-condition precedence

Only one primary condition is drawn inside a family bay. This prevents an offline, damaged, sealed, and targeted system from becoming a pile of crosses, cracks, labels, borders, and circles.

| Priority | Condition | Authoritative input | Treatment |
|---:|---|---|---|
| 1 | Breached | dependency `offline` plus damaged durability | Large red break across the bay; target intent, if present, stays outside. |
| 2 | Disabled | dependency `offline` | One red diagonal; dim family color. |
| 3 | Damaged | durability below definition maximum | One bright durability fracture. |
| 4 | Strained | dependency `strained` | Amber top edge and compact warning mark. |
| 5 | Protected | active `sealed` intervention | Warm inner brace; no word inside the bay. |
| 6 | Repaired | optional presentation receipt flag | Three pale repair stitches. Never infer this from full durability. |
| 7 | Ready | dependency `ready` | Stable family pictogram and normal family color. |

Selected and targeted are not competing conditions. Selected uses an exterior cyan outline in inspection contexts. Targeted uses four exterior red corner brackets and is derived from the authoritative target module ID.

## Journey and machine states

| State | Source | Required visual cue | Current support |
|---|---|---|---|
| Idle | settlement/recovery mode | Planted legs, low dark exhaust, steady lights | Implemented. |
| Selected | presentation-only focused module ID | Cyan exterior outline; family pictogram remains visible | Renderer input supported; detailed chassis remains the primary selector. |
| Strained | dependency status | Amber top edge and warning mark | Implemented. |
| Disabled | dependency status | Dim bay and single diagonal | Implemented. |
| Damaged | module durability | Single fracture and aggregate hull status | Implemented. |
| Overheated | current heat above safe limit | Warm stack smoke, heat arcs, `OVERHEAT` status when no breach dominates | Implemented from the presentation snapshot. |
| Breached | damaged and offline | Large red break and `BREACH` aggregate status | Implemented. |
| Repaired | service/event presentation receipt | Pale stitches that expire after the receipt handoff | Renderer input supported; caller handoff remains future work. |
| Departing | journey presentation phase | First gait cycle while the origin recedes | Mode reserved; uses moving leg contract. |
| Traveling | travel phase and posture | Repeating gait, drifting exhaust, unchanged module anchors | Implemented by `travel`; named `traveling` is also supported. |
| Under contact | active encounter | Braced silhouette, exterior target intent, impact offset | Implemented. |
| Retreating | recoverable defeat transition | Uneven/reversed travel treatment and persistent damage | Mode reserved; uses moving leg contract. |
| Arrived | resolved arrival | Planted damaged fortress beside destination treatment | Implemented. |

## Place treatment

### Ashgate Lowlands

- Exposed ochre edge metal, timber braces, dark industrial engine housing.
- Dust streaks remain low on the hull.
- Heat reads near exhaust and engine structure, not as a full-screen tint.
- Canvas and patchwork suggest a working depot machine rather than a military vehicle.

### Flooded Veyru

- Blue-green edge metal and darker damp hull plate.
- Rain streaks descend from the upper hull.
- A visible waterline crosses the lower body.
- The same engine housing, module order, roof, mast, weapon, and legs preserve fortress identity.

Place treatment is presentation-only. Region title, route rules, flood pressure, heat, damage, and services remain authoritative elsewhere.

## Accessibility and scale contract

- Condition meaning must survive without color: breach uses two diagonals, disabled one diagonal, damage one fracture, strain a top edge plus `!`, protection an inner brace, targeting external corners.
- High contrast brightens frames and wear marks but does not change precedence.
- Reduced motion freezes gait, smoke drift, and impact interpolation without removing state marks.
- At 1280×720 each family pictogram and primary condition must remain distinguishable at normal play distance.
- At 2560×1440 the same proportional layout is used; no extra labels appear only at the larger size.
- Raw logs and detail docks may explain a condition, but they are not required to locate the affected family bay.

## Implementation boundary

`src/ui/fortress_silhouette.gd` owns this visual reduction and code-native drawing. `src/ui/main.gd` supplies a presentation snapshot derived from `FortressState`: installed modules, dependency state, damage, sealing, target ID, region, heat, and heat limit. The renderer never chooses targets, applies damage, changes heat, repairs modules, or writes saves.
