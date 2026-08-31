# Bounded Quartermaster Market Report

**Build:** `0.3.0-alpha.332`

## Player-facing change

Ashgate Depot's Quartermaster now offers two explicit transactions:

- buy one fixed-stock **Spare Side Armor Skirt** for 18 Ashmarks;
- sell one **stored, uninstalled Shell Cannon** for 14 Ashmarks.

The station previews money and storage before and after each trade. It also states the bought armor's footprint, mass, power use, and protective role, and the cannon's footprint, exterior requirement, power draw, and ammunition dependency. Buying places the module in storage; installation remains a separate Workshop action. Selling cannot select or remove anything installed on the fortress.

## Authority and persistence

- `FortressState` owns offer identity, eligibility, prices, inventory mutation, and receipts.
- Fixed stock has a stable purchase ID and can be bought once.
- Insufficient funds, duplicate purchases, unavailable stored inventory, the wrong settlement, and active travel/contact all fail without partial mutation.
- Save schema 10 persists consumed fixed stock; schema-9 saves migrate with no invented purchase.
- Stored-module removal itself remains the durable sale record.

## Scope boundary

This is deliberately not a procedural economy, rotating shop, rarity ladder, or generalized dismantling interface. It proves the complete buy/sell contract with one meaningful defensive purchase and one consequential weapon sale before broader stock or a dedicated market screen is justified by playtest evidence.

## Verification

Deterministic tests cover exact prices, storage deltas, unchanged installed modules, repeat attempts, insufficient funds, save/load, migration, and malformed records. Settlement coverage executes both trades through visible controls before continuing through the existing Signal Broker, assignment, mastery, and route-planning flow.

## Visual evidence

- [`Exact buy/sell preview`](visual_evidence/v0.3.0-alpha.332-quartermaster-market/02a_quartermaster_offer.png)
- [`Completed transaction state`](visual_evidence/v0.3.0-alpha.332-quartermaster-market/02a_quartermaster_trade.png)
