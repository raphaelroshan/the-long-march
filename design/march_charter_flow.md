# March Charter — Two-Chapter Replay Flow

## Player-facing question

After a chapter ends, can the player see what the wider march remembers and move directly into the other proven region without mistaking one Continue slot for campaign history?

## Evidence and scope

The local `0.3.0-alpha.235` journal records a complete five-encounter Flooded Veyru run, while the terminal UI currently offers only same-region replay or a return to the title. This slice connects the two playable chapters without pretending that the planned five-region campaign exists.

## Durable record

The local March Charter stores:

- the best terminal result reached in Ashgate Lowlands;
- the best terminal result reached in Flooded Veyru;
- existing stable regional development IDs.

Results are ordered within their own region. A decisive or intact result can replace a scarred result, and any survival can replace a failure. A later weaker attempt never erases a stronger record. The Charter remains separate from the replaceable Continue checkpoint.

## March On flow

Every debrief offers one prominent action for the other playable region:

- Ashgate points to Flooded Veyru;
- Flooded Veyru points to Ashgate;
- if the other region has already been survived, the action says **Revisit** rather than implying unfinished progress.

The action opens a confirmation that names the destination and explains the difference between durable Charter history and the local Continue slot. Confirming creates a normal fresh run with the same briefing, autosave, deterministic seed, and regional-development rules as starting that chapter from the title.

## Visible evidence

- The title shows `0/2`, `1/2`, or `2/2` regions survived.
- Each region shows its best named result or an em dash when unattempted.
- The title recommends the unfinished region, or states that both roads remain open for replay.
- The debrief names the exact destination before leaving the completed run.

## Persistence and failure behavior

- Profile schema advances to `2`.
- Schema-1 profiles migrate with their development IDs and no invented chapter results.
- Unknown regions, mismatched result IDs, malformed dictionaries, and future schemas are rejected without partial restoration.
- A corrupt Charter never blocks either chapter; the next valid terminal result can rebuild the record.
- Failed chapter results are remembered but do not count as surviving that region.

## Non-goals

- A five-region campaign map.
- Carrying fuel, damage, modules, or money between chapters.
- Permanent numerical bonuses.
- Multiple Continue slots.
- Replacing explicit chapter selection on the title.
