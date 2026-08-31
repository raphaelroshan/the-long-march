# Route Cost Receipt Report

**Build:** `0.3.0-alpha.317`

## Player question

After selecting a road, can the player tell what is merely previewed, what the journey will cost, and that nothing has been spent until Commit?

## Change

The regional map now keeps a compact receipt in its center stage. While browsing it states that no road is selected. After activation it names the selected destination and projects the exact day, fuel, pressure, risk, and heat result beside the highlighted node.

The receipt is presentation-only. It is derived from `FortressState.campaign_node_preview`, and Commit remains the only command that changes campaign resources or begins travel.

## Verification

- Route presenter coverage checks both the empty browse state and the selected Rill Crossing projection.
- Settlement flow coverage checks exact `DAY 1→2`, `FUEL 6→5`, `PRESSURE 0→1`, and `LOW RISK 14%` copy before Commit.
- The full repository verification suite passes.
- The selected-road capture uses the 1280×720 high-contrast path and keeps the map, dossier, and Commit action visible.

## Evidence

- [Cost-free browse state](visual_evidence/v0.3.0-alpha.317-route-cost-receipt/03_route_browse.png)
- [Selected-road cost receipt](visual_evidence/v0.3.0-alpha.317-route-cost-receipt/03b_route_selected.png)

These captures verify hierarchy and fit. They do not establish uncoached human comprehension.
