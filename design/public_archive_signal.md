# Public Archive Signal — Regional Development Slice

## Player-facing question

Does sharing dangerous information now make a later march more legible without making the fortress numerically stronger?

## Trigger

Flooded Veyru earns `veyru_public_archive_signal` when the fortress:

- chooses `broadcast_archive` at Dry Archive Gate;
- survives the final encounter with `archive_kept` or `archive_scarred`.

Sealing the archive or losing the final encounter does not establish the signal.

## Persistent effect

The development is stored in a small local progression record separate from the replaceable Continue checkpoint. New runs copy its stable IDs into the authoritative fortress state, and active saves preserve that snapshot for deterministic replay.

On later Flooded Veyru runs, Drowned Registry changes from **Unscouted** to **Known**. Its Flood Surge and Climber contacts and their counters become visible before commitment. The signal grants no risk discount, damage bonus, resource reward, route shortcut, or automatic choice; live forecasting equipment remains valuable for its normal risk and pressure benefits.

## Visible evidence

- The earning debrief names Public Archive Signal and its future Registry effect.
- The title overview states that the development is active.
- The Veyru run status retains the development name.
- Drowned Registry's map label, comparison row, route detail, and commit intelligence attribute its Known information to Public Archive Signal.

## Persistence and failure behavior

- Profile schema: `2`; schema 1 migrates the development with no invented chapter result.
- Run save schema: `8`; schema 4–7 saves migrate with no invented development.
- Unknown, duplicate, malformed, or future profile entries are rejected without partially restoring progress.
- A corrupt profile does not block either chapter. The title explains that the regional record is unavailable, and a later qualifying completion can rebuild it.

## Required tests

- No prior development leaves Drowned Registry Unscouted.
- Public Archive Signal reveals the exact Registry composition without the live forecasting risk discount.
- Broadcast plus a surviving Veyru result earns the development; Seal does not.
- The development survives profile reload and run save/load.
- A schema-7 run migrates without inventing the development.
- Invalid development IDs and duplicate profile entries are rejected.
- Replay after earning the development remains in Veyru and receives its effect.
- Title, debrief, map status, route comparison, and route detail expose the cause and effect.

## Non-goals

- A campaign meta-map.
- Multiple currencies, experience points, or permanent stat growth.
- Unlocking new combat power.
- Connecting Ashgate and Veyru into one continuous save.
- More than one regional development in this slice.
