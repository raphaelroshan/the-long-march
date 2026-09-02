# LM-I5 Campaign Memory and Endings Gate

**Build:** `0.3.0-alpha.361`
**Status:** Repository gate complete; human comprehension and balance remain unvalidated.

## Player-facing result

The Morrowline parts-guard obligation no longer ends with Ashgate. Its final state is stored separately from the player's best regional result and changes a later Flooded Veyru decision:

| Ashgate obligation | Persistent memory | Veyru consequence | Ending contribution |
|---|---|---|---|
| Completed | Morrowline Supply Line | Evacuation Camp grants one additional service action. | Industrial corridor |
| Declined | Free Carters' Chart | Sunken Tramworks adds one less regional pressure. | Fast corridor |
| Failed | Wreckers' Warning | Pump Gallery route risk falls by six percentage points. | Shelter chain |

Each consequence is disclosed in the selected-road dossier before commitment. The completed path is also visible in the recovery allowance and road log; all three histories appear in terminal Debrief commitments and ending causes.

## Evidence

- [`00_completed_camp_dossier.png`](visual_evidence/v0.3.0-alpha.361-memory-gate/00_completed_camp_dossier.png) attributes the extra service to Morrowline before commitment.
- [`01_completed_camp_service.png`](visual_evidence/v0.3.0-alpha.361-memory-gate/01_completed_camp_service.png) shows the resulting two-action recovery state after the current medicine carrier was declined.
- [`02_declined_tram_chart.png`](visual_evidence/v0.3.0-alpha.361-memory-gate/02_declined_tram_chart.png) shows the Free Carters' chart reducing the selected route from one pressure to zero.
- [`03_failed_pump_warning.png`](visual_evidence/v0.3.0-alpha.361-memory-gate/03_failed_pump_warning.png) turns failure into an attributed six-point risk warning instead of erasing progression.

The deterministic gate completes a full Veyru journey with inherited history, crosses ten exact save checkpoints, compares baseline and modified route values, rejects malformed obligation state, migrates version-15 saves without inventing history, and proves the three histories yield three distinct ending titles. The UI flow repeats the affected planner and recovery states at 1600×900 and at 1280×720 with large text, high contrast, reduced motion, and alternate controller layout.

## Implementation boundary

`CampaignProgress` owns the durable cross-run obligation ledger. `LongMarchState` validates a copy in each run and remains authoritative for route cost, risk, pressure, service capacity, and ending composition. UI code only renders those read models and invokes existing commands. Save schema 16 persists the ledger; versions 4–15 remain supported and default to no inherited obligation.

The gate proves deterministic causality, persistence, presentation, and layout coverage. It does not prove that an uncoached player notices the connection, values the three outcomes equally, or understands the ending language. Those are explicit human-playtest questions.

## Next task

Execute **LM-I6 Early Access hardening**: validate clean-install and recovery behavior across the complete campaign, enforce the declared performance and compatibility budgets in packaged cohorts, and produce the final private-alpha manifest without claiming public-release approval.
