# Route-Map Visual Grammar Report

**Build:** `0.3.0-alpha.305`

## Purpose

The route planner already exposed exact costs and threat intelligence, but much of the graph still depended on color and repeated status words. This pass makes the chart's position, history, choices, and active obligations readable before the player studies the dossier.

## Visual grammar

| State | Node treatment | Route treatment |
|---|---|---|
| Current | Diamond | Active outgoing routes begin here |
| Available | Hollow circle | Solid directional route |
| Selected | Filled circle | Bright route with restrained halo and direction |
| Secured | Check | Solid green historical route with direction |
| Future | Hollow diamond | Dashed muted route |
| Closed | Cross | Red route with midpoint closure mark |
| Locked or blocked | Exclamation | Amber route |
| Bypassed | Dash | Muted historical branch |

Assignment destinations receive a compact badge derived from existing contract state: `OFFER`, `ACCEPTED`, `FULFILLED`, or `FAILED`. Ashgate attaches the convoy obligation to Morrowline Camp; Veyru attaches the medicine obligation to the Dry Archive.

## Architecture boundary

`RoutePresenter` projects the authoritative contract status into read-only marker data. `CampaignMapView` renders that data and derives every route treatment from its existing map configuration. No route availability, contract result, costs, save fields, or command behavior changed.

## Verification

- Presenter tests cover offered and accepted marker projection without state mutation.
- Prototype-flow tests cover node glyphs, available/selected/secured route signatures, and the accepted destination badge.
- The complete 1280×720 journey capture confirms the map, dossier, and commit controls remain inside the reference frame.

## Remaining human question

Ask an uncoached player to identify where the fortress is, which roads can be selected, which road is currently previewed, and where the accepted assignment resolves without hovering. Repeated failure should drive the next map revision.
