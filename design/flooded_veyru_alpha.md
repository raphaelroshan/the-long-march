# Flooded Veyru — Isolated Alpha Chapter

## Player question

Can the fortress carry a fragile public obligation through rising water without letting mass, lower-hull damage, or lost information close every road?

## Scope and entry

Flooded Veyru is a separately selectable five-encounter chapter. It reuses the chassis, dependencies, doctrines, intervention commands, combat timeline, save system, event card, map contract, and debrief. It does not continue an Ashgate save and does not add a campaign meta-map.

The title screen gains **Start Flooded Veyru** beside the Ashgate start. A new run begins at **Lantern Quay** with the standard finite module inventory and a Veyru-specific prepared layout. The run ends at **The Dry Archive**.

## Regional pressure: rising water

Use one visible integer, `regional_pressure`, with a region-owned label and thresholds:

| Band | Water | Effect |
|---|---:|---|
| Low water | 0–2 | Both forward branches remain available. |
| Flooding | 3–4 | Flood damage gains one pressure; the low tram shortcut becomes unsafe. |
| Breach | 5+ | The low tram closes, but the **Pilgrim Gantry** recovery road opens and cannot close. |

Travel days, retreat, opening sluices, and noisy salvage raise water. Pump work and abandoning optional salvage can lower it. The pressure may change route costs or contacts, but it never deletes the only forward or recovery path.

## Authored graph

```text
Lantern Quay
├─ Pump Gallery ───────┐
└─ Sunken Tramworks ───┤
                       v
                Evacuation Camp
                ├─ Archive Causeway ─┐
                ├─ Drowned Registry ─┤
                └─ Pilgrim Gantry* ──┘
                                     v
                              Dry Archive Gate
                                     v
                                Dry Archive

* Opens as the guaranteed lower-value recovery path at Breach water.
```

The chapter resolves exactly five encounters:

1. Pump Gallery or Sunken Tramworks.
2. The remaining approach pressure before Evacuation Camp.
3. Archive Causeway, Drowned Registry, or the recovery Gantry.
4. Flood-and-contact combination encounter at Dry Archive Gate.
5. Civic Guardian final encounter after the archive commitment.

## Start contract: the sealed medicines

Lantern Quay asks the fortress to carry sealed medicine cases to the Dry Archive.

- **Accept:** reserves the Refugee Bunk or one cargo-capable system as the medicine hold. Raiders and flood contacts value that target. Delivery earns 28 Ashmarks and 2 trust.
- **Decline:** preserves capacity and raises Mobility by 1. The chapter remains completable, but Evacuation Camp offers only basic recovery.
- **Failure:** losing the reserved carrier marks the contract failed; it never ends the run.

The UI names the exact carrier before acceptance and shows its condition throughout the chapter.

## First branch

### Pump Gallery — isolated teaching encounter

Known, two days, one fuel, water +2. Introduces **Flood Surge** alone.

Flood Surge targets lower-hull, cargo, or sustain systems. Its impact gains one damage when the fortress is over the mass limit or water is already Flooding. Visible counters are a Ready Water Condenser, Side Armor Skirt, Seal Compartment, or the slower **Drain Pumps** node decision after contact.

### Sunken Tramworks — fast structural shortcut

Forecast, one day, one fuel, water +1. Reuses Burrowers against lower-hull and engine dependencies. Heavy builds pay one additional hull damage after the encounter; lighter builds preserve the day advantage. This road teaches that speed and mass change flood exposure without adding another resource.

Both branches remain viable with the prepared layout. Neither requires the Water Condenser.

## Recovery anchor: Evacuation Camp

This is a compact camp, not a second full vendor UI. Arrival grants one guaranteed service action:

- repair one module by 2 durability for 8 Ashmarks;
- restore 2 hull for 10 Ashmarks; or
- take 1 fuel at no cost if fuel is below 2.

The free emergency fuel prevents a technically surviving fortress from becoming stranded. Contract acceptance adds a second action only while the medicine carrier remains operational. Refit remains available.

## Second branch

### Archive Causeway

Known, two days, one fuel, water +1. Signal coverage reveals the exact combination encounter and reduces its route risk. The road is slower but protects fragile cargo.

### Drowned Registry

Unscouted, one day, one fuel, water +2. Offers six Ashmarks of salvage after contact, but the Flood Surge and Climbers appear together. This is the first combination encounter: flood pressure attacks the lower hull while Climbers test exposed signal or crew systems.

### Pilgrim Gantry

Known recovery road, two days, one fuel, no reward, water -1. It appears only at Breach water or after a retreat and cannot close. The encounter contains Flood Surge alone at reduced damage.

## Final commitment: what the archive broadcasts

At Dry Archive Gate the player must choose before the final encounter:

- **Broadcast the archive:** Knowledge +1 and trust +1; the signal remains exposed and adds Climbers to the final contact.
- **Seal the archive:** reduce water by 1 and protect the medicine carrier; exact final targeting becomes forecast rather than known.

The final encounter uses the existing combat engine: a Civic Guardian contact tests armor and the medicine carrier, combined with Climbers only after broadcast. The choice changes real targets and information rather than only ending prose.

## Results and recovery

- **Archive Kept:** reach the archive with the medicine carrier operational and hull at 6+.
- **Archive Scarred:** reach it with the fortress mobile but lose the carrier, contract, or substantial hull.
- **Veyru Lost:** fail the final encounter.

Non-final failure retreats to Evacuation Camp after it has been reached, otherwise to Lantern Quay. Retreat adds water +2, one day, and an Ashmark charge, then restores a limping movement chain through the existing recovery rule.

The debrief names route, final water band, contract/carrier state, final commitment, retreats, and the system that determined the result.

## State and IDs

- Region: `flooded_veyru`.
- Nodes: `lantern_quay`, `pump_gallery`, `sunken_tramworks`, `veyru_evacuation_camp`, `archive_causeway`, `drowned_registry`, `pilgrim_gantry`, `dry_archive_gate`, `dry_archive`.
- Threat: `flood_surge`; final contact: `civic_guardian`.
- Contract: `veyru_medicine_delivery`.
- Decisions: `drain_pumps`, `registry_salvage`, `archive_broadcast`.
- Persist region ID, regional pressure, contract state, carrier module ID, final commitment, and chapter result through the existing save envelope.

## Required tests

- Both opening branches are viable from the prepared layout.
- Water thresholds change routes but never remove every option.
- Pilgrim Gantry opens at Breach and after retreat.
- Flood Surge targeting and damage are deterministic and expose at least two counters.
- The teaching encounter contains Flood Surge alone.
- The combination encounter contains Flood Surge and Climbers.
- Contract carrier loss fails the contract without ending the run.
- Evacuation Camp can restore a legal movement state.
- Save/load works at route choice, active battle, camp recovery, final decision, and result.
- Same seed and command sequence reproduce the same route, targets, damage, and result.
- Title selection, map, contract, camp, final commitment, and debrief have UI coverage.
- Capture the opening map, Flood Surge contact, camp recovery, and final commitment at 1280×720.

## Non-goals

- Connecting Ashgate and Veyru into one continuous campaign.
- A general water inventory or individual thirst simulation.
- Divers, relic economy, Brother Caldus recruitment, or faction reputation bars.
- Procedural map generation.
- A second combat engine.
- More than one new ordinary threat and one final contact.
