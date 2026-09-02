# LM-GPT56-4 — People, Promises, and Memory

**Build:** `0.3.0-alpha.363`

**Status:** Complete as a bounded specialist and obligation contract.

## People with mechanical stakes

[`content/people_promises.json`](../content/people_promises.json) declares all six implemented specialists in the same terms the game must communicate: capability, dependency or limitation, conflict or promise, and visible consequence. These are not parallel lore biographies. Each entry points to an existing system boundary:

| Specialist | Capability | Dependency and cost | Visible campaign consequence |
|---|---|---|---|
| Iven Pell | Exact immediate contact forecasts | Crew Quarters, twelve Ashmarks, sole berth | Exact route dossiers; choosing Mara removes that certainty |
| Mara Flint | One additional durability per workshop service | Ready, crew-connected Field Workshop | Recovery receipt and forge-core promise callback |
| Sela Vonn | One day saved and a contact feint | Ready Command Deck; four additional risk | Route and contact receipts show the trade |
| Nera Quill | One less crew/refuge damage | Ready Field Infirmary; no attack value | Contact receipt attributes triage |
| Orla Nine | One less fuel on long roads | Ready engine; one additional heat | Route dossier exposes both values before commitment |
| Tomas Reed | One less Lift Saboteur damage | Ready Field Workshop; one threat family | Impact profile attributes the rigging |

`LongMarchState.specialist_campaign_summary()` is the shared player-facing account of those effects. Debrief now carries that account as `Specialist consequence`, so a person selected before departure remains mechanically legible at the end of the journey. Mara's repair bonus now correctly turns off when her Field Workshop is disabled.

## Promises that survive the screen transition

The content contract preserves three distinct obligation results—completed, declined, and failed—and their later campaign changes. It also names Mara's berth choice, workbench choice, and fourth-road callback as one active-event chain. The deterministic tests prove the three obligation results produce distinct ending histories and that the Iven/Mara and Orla/baseline choices have different mechanical outcomes.

## Verification and evidence

- `tools/validate_people_promises.py` validates six complete, unique specialist contracts, all three obligation results, the active-event checkpoints, and replay comparisons.
- `tests/test_people_promises.gd` exercises every specialist summary through the live Debrief presenter, disables Mara's dependency, assigns Orla through the public state command, compares route forecasts, and distinguishes all three obligation endings.
- `tests/test_campaign_memory.gd` and `tests/test_lm_i5_memory_gate.gd` remain the broader persistence and campaign-memory regression gates.
- [`v0.3.0-alpha.363-gpt56-4-people-promises`](visual_evidence/v0.3.0-alpha.363-gpt56-4-people-promises/) records the crossroads, forge-core dilemma, callback, and Debrief in the playable flow.

## Honest boundary

This proves that six specialists have explicit system consequences and that selected promises survive into later state and Debrief. It does not claim six bespoke quest lines, voiced character scenes, or human-validated emotional impact. The visible summaries use authored text tied to deterministic state; broader narrative depth remains a content-production task.

## Next packet

Execute **LM-GPT56-5 — Early Access package** by making the 30–90 minute campaign, offline build, save migration, accessibility, asset provenance, rollback, and known-limitations claims machine-verifiable in the candidate manifest and final package gates.
