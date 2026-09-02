# LM-I1 — Creative vertical lock report

**Build:** `0.3.0-alpha.357`

LM-I1 is complete as a repository-verifiable gate. A fresh player-facing run now links the First Watch tutorial to a legal Ashgate refit, route commitment, animated travel, mandatory road interruption, staged contact, visible damage, Morrowline recovery, a fourth-road consequence, Meridian Pass, and the terminal Debrief.

The authored spine no longer hides Mara Flint when Iven Pell occupies the specialist berth. Morrowline stops the fortress at **Two Hands, One Berth** and states the actual trade: retain Iven's exact nearby forecasts or leave him with the relay crews and assign Mara's workshop recovery. Choosing Mara opens **One Sound Core**, where the player commits the recovered core to a damaged machine or the Refugee Bunk. **What Held** checks that physical promise after the fourth road. The Debrief names the berth exchange and its forge-core result before secondary campaign records.

The canonical investment fixture also performs a physical loadout trade. It exchanges the heavy Steam Lance for the lighter Ash Runner, reconnects fuel, retains the crew-connected Field Workshop and Ammunition Lift, and adds a Wall Lamp within the fourteen-mass chassis limit. This makes Iven recruitable without deleting the workshop Mara later needs, so the specialist choice changes capability rather than prose alone.

## Automated evidence

- `tests/test_fortress_state.gd` covers both specialist choices, invalid state rejection, the chained forge-core decision, and exact save/load round trips before and after reassignment.
- `tests/test_early_access_anchor_runs.gd` preserves the original reliable Iven plan and now requires an explicit Morrowline choice instead of silently bypassing Mara.
- `tests/test_complete_journey_handoff.gd` adds `LONG_MARCH_INVESTMENT_PROFILE=1`, runs the clean-save title-to-Debrief journey, relaunches at the unresolved crossroads, verifies the fourth-road callback, and checks the causal Debrief.
- The same investment fixture runs at 1280×720 with 110% text, high contrast, reduced motion, muted interface cues, and the alternate controller layout.
- `tests/test_roadside_event_presentation.gd` checks the unique two-specialist tableau, capability labels, focus, and choice visibility.
- `scripts/verify.sh` makes both the standard and responsive investment fixtures mandatory.

## Visual evidence

The tracked evidence was captured by the deterministic fixture at 1600×900 from this exact build:

- [`00_title.png`](visual_evidence/v0.3.0-alpha.357-investment-vertical/00_title.png)
- [`07b_road_in_motion.png`](visual_evidence/v0.3.0-alpha.357-investment-vertical/07b_road_in_motion.png)
- [`08_road_contact.png`](visual_evidence/v0.3.0-alpha.357-investment-vertical/08_road_contact.png)
- [`11_specialist_crossroads.png`](visual_evidence/v0.3.0-alpha.357-investment-vertical/11_specialist_crossroads.png)
- [`11b_forge_core_dilemma.png`](visual_evidence/v0.3.0-alpha.357-investment-vertical/11b_forge_core_dilemma.png)
- [`11e_forge_core_callback.png`](visual_evidence/v0.3.0-alpha.357-investment-vertical/11e_forge_core_callback.png)
- [`13_debrief.png`](visual_evidence/v0.3.0-alpha.357-investment-vertical/13_debrief.png)

## Honest boundary

Automation proves that the authored flow is reachable, deterministic, persistent, input-accessible under the tested profiles, and visually contained at the target sizes. It does not prove that a new player understands the specialist trade, enjoys the pacing, notices every causal link, or finds the current code-drawn art commercially distinctive. The captured run deliberately ends **Scarred** when its Refugee Bunk fails and an available recovery action goes unused; the game explains that outcome rather than silently upgrading it.

## Next task

Run three consented, uncoached sessions on the exact `0.3.0-alpha.357` cohort and record whether players can explain the Iven-versus-Mara trade and the final causal Debrief without prompting.
