# Mara Flint Recovery Chain

## Design card

| Field | Decision |
|---|---|
| Stable specialist ID | `mara_flint` |
| Primary facility | Field Workshop |
| Player question | Do I use one recoverable forge core to keep the machine intact now, accepting delay, or protect refugee space for a later human obligation? |
| Entry point | Morrowline Camp after the third encounter, before services and departure. |
| Recruitment requirement | Free specialist berth, installed operational Field Workshop, and installed operational Crew Quarters. |
| Mechanical specialty | While recruited, Mara adds one durability to field-workshop repairs and to each paid Morrowline module-repair action. The extra point does not increase the Ashmark price. |
| Opportunity cost | Recruiting Mara occupies the one current specialist berth, excluding Iven Pell. Her immediate repair choice adds one day and one blockade pressure. |
| Persistent state | Existing `specialist_id`, `campaign_event_pending`, and validated `campaign_decisions`; no relationship meter or dialogue tree. |
| Save compatibility | Older saves default to no Mara decisions. Active Mara event IDs and choices are validated before state mutation. |
| Presentation | Existing event card, specialist line, service preview, battle repair report, and debrief decision record. |
| Determinism | The weakest damaged module uses durability, then installed order, as the stable tie-break. The same state and command sequence produce the same target and callback. |

## Three-event chain

### 1. The Forge Without a Roof — meeting

After the Morrowline approach, Mara is repairing convoy axles in an open yard. She offers to join only if the fortress has a working Field Workshop, staffed through operational Crew Quarters, and an empty specialist berth.

- **Bring Mara aboard:** assigns `mara_flint`; workshop repairs gain one durability; immediately opens the forge-core decision.
- **Leave Mara with Morrowline:** keeps the berth open and ends the chain for this run.

The decline is a valid strategic choice, particularly for a run that plans to recruit Iven Pell or does not want Mara’s delay pressure.

### 2. One Sound Core — repair versus refuge

Mara recovers one intact core from the convoy wreckage. It can support exactly one commitment.

- **Rebuild the weakest system:** restores up to two durability to the most damaged installed module, adds one day, and adds one blockade pressure. This option is disabled when no installed module is damaged. The delay is the visible price of repair-first play.
- **Brace the Refugee Bunk:** permanently reduces damage to an installed Refugee Bunk by one per hit, to a minimum of zero. The brace can be prepared while the bunk is stored, but the option is disabled if no recoverable Refugee Bunk remains. It gives no immediate repair and no hidden trust reward.

Choosing one consumes the core by resolving the event; the other option cannot be taken later.

### 3. What Held — road callback

After the fourth encounter, before Meridian Pass, Mara inspects the earlier commitment.

- If the repaired system remains operational, the avoided roadside delay reduces blockade pressure by one. If it failed, no pressure is removed.
- If the Refugee Bunk is operational, Morrowline hears that the protected berth remained usable: settlement trust and Shelter tendency each rise by one. If the bunk is absent, sealed, or destroyed, no reward is granted.

The callback has one acknowledge action because the meaningful choice happened at the workbench. Its event card previews the exact outcome from current authoritative state before the player confirms it.

## Counterplay and failure

- A player may decline Mara and retain the specialist berth.
- A player may choose immediate repair, accepting a visible day and pressure increase.
- A player may choose refuge bracing, accepting no immediate restoration and spending two chassis cells if the protection is to pay off.
- The braced bunk can still be damaged by pressure-amplified hits; the brace reduces damage rather than granting immunity.
- If Mara’s Field Workshop or Crew Quarters goes offline, her field-repair bonus cannot act because the underlying workshop action is unavailable.

## Required tests

- Meeting eligibility, disabled requirement text, acceptance, and decline.
- One-core scarcity and deterministic weakest-module selection.
- Mara’s field and settlement repair bonus, including unchanged service price.
- Refugee Bunk mitigation and impact-report explanation.
- Context-sensitive fourth-road callback for successful and failed commitments.
- Active meeting, workbench, and callback save/load.
- Rejection of unknown event IDs, choices, and specialist IDs.
- Same-seed replay equality through the callback.
- Event-card UI smoke, controller focus, service preview, and debrief causal line.
- 1280×720 visual capture of the workbench choice and later callback.

## Explicit non-goals

- No general dialogue system, affection score, approval meter, or faction reputation framework.
- No random event scheduler in this slice.
- No second specialist slot or crew inventory.
- No automatic “best” choice, free repair without a timing cost, or invulnerable refugee module.
- No new region, route, module, enemy, or combat engine.
