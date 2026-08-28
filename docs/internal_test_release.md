# The Long March — Playable Journey Test Release

## Purpose

This is a testable two-chapter alpha for The Long March. It proves separate five-encounter runs through **Ashgate Lowlands** and **Flooded Veyru**, with dependency-driven refitting, incomplete route information, regional contracts and pressure, deterministic encounters, recoverable failure, mid-run recovery, and explicit results. The chapters share one simulation and interface but remain isolated rather than pretending the full campaign layer exists.

## Ashgate test flow

1. Start at Ashgate Depot with the prepared fortress modules visible in the chassis grid.
2. Select an installed module to move, rotate, or remove it. Select a module from the palette, then choose an empty cell with the pointer or with arrows and A/Enter to install it. Exterior-tagged modules consume one of two mount slots.
3. Confirm that invalid overlap, bounds, mass, and exterior-capacity placements show a blocked preview without changing the old layout.
4. Move the Coal Cell away from the Steam Lance Engine and confirm the engine turns offline; reconnect it before departure. Move the Ammunition Lift away from the weapon and confirm the weapon becomes strained rather than silently retaining full damage.
5. Accept or decline the **Morrowline Parts Guard**, then compare the known/forecast/unscouted information for **Rill Crossing** and **The Soot Orchard**.
6. Select a doctrine—protect cargo, protect crew, or run hot—and begin the first encounter. Refit controls lock during travel and battle.
7. Advance the battle one step at a time. Compare each active contact's **Next Hit** value with the result. Use **Inspect Chassis** to select a Seal Compartment target without a mouse, or use **Shift power to weapons** once if the weapon system needs priority, then read the causal report.
8. If a seeded road occurrence appears, verify that its complete cost is visible, resolve it, and confirm the debrief later records the chosen response. A quiet phase is also a valid deterministic result.
9. Choose **Broken Relay** or **Red Wheel Toll Bridge** for the second encounter. Resolve the node decision and verify its money, trust, risk, or pressure consequence.
10. If the relay was restored, inspect Iven Pell's crew-space and supply requirements; recruit him when the build permits and confirm exact threat names replace broad forecasts.
11. Complete the Morrowline approach as encounter three. If the guard contract was accepted, confirm its extra endurance and the 30-Ashmark/two-trust payment.
12. At Morrowline, inspect Mara Flint's requirements. Recruit or decline her; if recruited, spend the one forge core on delayed machine repair or Refugee Bunk bracing and verify both costs are visible before choosing.
13. Spend up to two service actions on module repair, hull repair, or fuel. With Mara aboard, confirm a three-point module repair still costs the two-point price. Refit and compare **Lower Ash Road**, the condenser-gated **Dry Cistern Cut**, and **Signal Causeway**.
14. Complete the fourth encounter, resolve Mara's **What Held** callback if active, then depart for **Meridian Pass** and resolve the fifth encounter against the Siege Beast.
15. Verify a **Decisive March**, **Scarred March**, or **March Failed** result and confirm the debrief card includes path, pressure, contract, specialist, road occurrences, Mara's causal result when applicable, surviving systems, missed thresholds, and a concrete replay goal.
16. On another attempt, allow a non-final encounter to disable the engine or hull. Confirm the fortress retreats to the last secured node with stated time, money, and pressure costs instead of ending the run.
17. Save and load during a map decision, active occurrence, active Mara event, or Morrowline recovery and confirm the graph position, phase, resources, module state, event stream, pressure, damage, and reports are preserved.
18. Open **Playtest feedback** after the result, confirm the modal cleanly separates the form from the debrief beneath it, answer the two short prompts, and save the local JSON bundle if the tester agrees to share it.

## Flooded Veyru test flow

1. Choose **Start Flooded Veyru · Rising Water** and confirm the run opens at Lantern Quay without the Ashgate-specific briefing.
2. Accept or decline the sealed-medicine contract. If accepted, confirm the UI names the exact Parts Crate or Refugee Bunk carrying it.
3. Compare Pump Gallery with Sunken Tramworks. Confirm the former names Flood Surge and its counters while the latter exposes its faster but mass-sensitive structural risk.
4. During Flood Surge contact, compare the named target and next-hit damage with the Water Condenser, workshop, armor, doctrine, and Seal Compartment options.
5. Reach Evacuation Camp and confirm the service budget is one action, or two while the accepted medicine carrier remains operational. With fuel below two, verify the free emergency-fuel option.
6. Compare Archive Causeway, Drowned Registry, and—when Breach water or retreat makes it available—Pilgrim Gantry. Confirm rising water can close the Registry but never every recovery path.
7. At Dry Archive Gate, verify both Broadcast and Seal show their complete mechanical consequences before selection.
8. Resolve the Civic Guardian final contact and confirm Archive Kept, Archive Scarred, or Veyru Lost names the carrier, water, final commitment, and decisive system state.
9. Save and Continue at a route choice, battle, camp, or final decision. Confirm the title, pause menu, restart warning, and replay warning all identify Flooded Veyru rather than Ashgate.
10. Complete a run after choosing **Broadcast the archive**. Confirm the debrief earns **Public Archive Signal**, then start another Veyru run and verify Drowned Registry is Known while its risk remains unchanged.
11. From either debrief, choose **March On**. Confirm the destination and Continue-slot explanation, cancel once to verify focus returns, then confirm and verify the other chapter starts normally. Return to the title and confirm the March Charter retains each region's best result.
12. Change an unsaved decision, then close the game window. Confirm **Save before quitting?** names the chapter and location. Choose **Keep Playing** once, then repeat and choose **Save & Quit**; relaunch and verify Continue restores that decision.

The first-run Marchmaster briefing explains the complete loop, while the phase-specific CURRENT ORDER keeps guidance available without hiding the current state. The refit interaction remains the input foundation for the spatial engineering loop. Fuel, ammunition, crew, parts, power, and visibility dependencies are evaluated explicitly and displayed as ready, strained, or offline.

## Implemented units and behaviors

| Module | Behavior |
|---|---|
| Steam Lance Engine | Enables movement and represents the critical engine dependency targeted by Burrowers |
| Shell Cannon | Burst damage against Road Raiders and Siege Beasts; stronger when weapon priority is selected; increases heat |
| Field Workshop | Repairs the weakest damaged operational module after contact |
| Signal Coil | Reveals the encounter target class before contact |
| Water Condenser | Opens and discounts Dry Cistern Cut while powered beside an operational Field Workshop |
| Existing modules | Generator, armor, cargo, crew, repeater, wall lamp, and other authored modules remain available to the original prototype APIs |

## Visual kit

The integrated kit includes a Long March visual reference, Ashgate journey background, Steam Lance Engine icon, Shell Cannon icon, Field Workshop icon, and Signal Coil icon. Each is original generated project content and is registered in `assets/ASSETS.md`. Enemy presentation remains procedural and uses readable threat labels and route markers in this first test slice.

## Scope boundaries

This release includes two authored FTL-like regional graphs, two mutually exclusive recruitable Ashgate specialists, one Veyru medicine obligation, one information-only regional development, a bounded scheduler for four authored Ashgate occurrences, and a small two-chapter Charter/replay shell. It does not implement the planned five-region campaign, carry numerical resources between chapters, add procedural prose or maps, implement a complete cargo economy, or include final sound, sprite animation, Steam/Epic adapters, or commercial storefront packaging. Both chapters remain deterministic and inspectable so agents and testers can tune their distinct preparation and route decisions before adding campaign breadth.
