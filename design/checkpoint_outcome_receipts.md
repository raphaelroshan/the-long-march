# Checkpoint Outcome Receipts

## Player problem

The final input of an encounter was saved correctly, but its receipt still read **Saved · Battle Step** after the interface had already moved to a secured road, recovery stop, or debrief. The generic label described the button press rather than the state the player could safely resume.

## Copy contract

- Unresolved encounter progress remains **Battle Step**.
- A completed ordinary road becomes **Road Secured**.
- Arrival at a settlement service phase becomes **Recovery Reached**.
- Arrival at a terminal debrief becomes the neutral **Run Ended**, regardless of result quality.
- Any other resolved encounter uses the safe fallback **Encounter Resolved**.
- The receipt changes only the human-facing reason; checkpoint timing, payload, backup behavior, and simulation state remain unchanged.

## Scope

This changes autosave receipt classification and copy only. It does not add saves, move save boundaries, or alter encounter outcomes.

## Visual evidence

- `/tmp/long_march_alpha266_post_battle_110.png`
- `/tmp/long_march_alpha266_post_battle_settled_110.png`
