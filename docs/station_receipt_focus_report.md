# Station Receipt Focus Report

**Build:** `0.3.0-alpha.334`

## Problem

Purchases checkpoint immediately. Once an action button disappeared after success, generic focus recovery treated that control as invalid and moved the player to the settlement's required assignment. State was correct, but the visual receipt was easy to miss.

## Change

`SettlementHubView.focus_station()` now restores a named station and, when appropriate, its next valid primary or secondary action.

- Buying Side Armor keeps the Quartermaster open and focuses the remaining Shell Cannon sale.
- Selling the cannon keeps the completed trade receipt open and focuses **Review Fortress Stores**.
- Buying the Orchard report keeps the Signal Broker receipt open and focuses its bazaar landmark because no further broker action remains.
- Blocked transactions return to the command that can be retried.

The required assignment still receives default focus when the player first enters or deliberately returns to the bazaar. This change applies only to the immediate aftermath of a station transaction.

## Verification

Settlement-flow coverage asserts both selected-station identity and exact focus owner after each transaction, then continues through assignment, mastery selection, route planning, travel, save, and restore.

## Visual evidence

- [`Quartermaster receipt with store review focused`](visual_evidence/v0.3.0-alpha.334-station-receipt-focus/02a_quartermaster_trade.png)
- [`Signal Broker receipt with station landmark focused`](visual_evidence/v0.3.0-alpha.334-station-receipt-focus/02b_signal_report.png)
