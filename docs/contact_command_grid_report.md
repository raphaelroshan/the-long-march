# Contact Command Grid Report

**Build:** `0.3.0-alpha.323`

## Player question

Can the player see the complete emergency-order set while reading the richer threat dossier, without treating the contact screen like a scrolling debug panel?

## Change

The four encounter orders now use a compact two-by-two grid in the contact dock:

```text
SHIFT POWER       SEAL COMPARTMENT
VENT HEAT         CUT LOOSE CARGO
```

The buttons use concise stable names. Focusing or hovering an action still replaces the help text with its exact live benefit and cost, including heat, damage, redirect, exposure, or permanent cargo loss. Controller focus follows the grid spatially while Tab order remains deterministic.

No intervention command, legality rule, cost, save state, or combat result changed.

## Verification

- The road-contact test requires a two-column, four-command grid.
- The complete prototype flow checks the compact labels in the real battle UI.
- Responsive 1280×720 and 1600×900 journey profiles pass.
- The full repository verification suite remains the merge gate.

## Evidence

- [All four emergency orders visible](visual_evidence/v0.3.0-alpha.323-contact-command-grid/08_road_contact.png)

SHA-256: `ea2440e3bf4158588ddd322543447c72a61401687f37a494f7801fa8c32e7694`
