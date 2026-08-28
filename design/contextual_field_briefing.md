# Contextual Field Briefing

## Player problem

The seven briefing topics are useful during a run, but the reference path previously reopened at Command every time and required repeated Next presses to reach the relevant subject. Its visual topic rail also looked selectable without accepting input. That makes help slowest when a player is already uncertain about a route, contact, recovery choice, or finale.

## Interaction contract

- A first Guided Ashgate run still begins at topic 1 and advances normally.
- Reopening Field Briefing chooses a topic from the authoritative live phase: contract → Command, route or ordinary road decision → Road/Water, battle or results → Contact/Archive, settlement or Mara decision → Repair, and the archive commitment → Archive.
- Every topic in the seven-part rail is a real button. Pointer, keyboard, and controller users can jump directly to any topic.
- The active topic uses a filled marker, viewed topics use a check, and untouched topics use a dash. A direct jump never falsely marks intervening topics as read.
- Closing reference mode returns focus through the existing current-action resolver. It does not activate the destination.
- Opening, browsing, and closing the briefing never changes simulation or serialized run state.

## Focus behavior

The existing Next, Previous, and Close actions remain. Up from those actions reaches the active topic. Left/right moves across the topic rail, down returns to Next, and Tab remains trapped inside the overlay. Initial onboarding continues to focus Next so a new player can follow the authored sequence without learning a second navigation pattern.

## Scope

This is a presentation and input-routing change in `src/ui/main.gd`. It does not add tutorial rewards, alter briefing persistence, change campaign rules, or track reading behavior outside the open overlay.

## Visual evidence

- `/tmp/long_march_alpha251_route_briefing_110.png`
- `/tmp/long_march_alpha251_battle_briefing_110.png`

Both states are captured at 1280×720 with 110% text and High contrast.
