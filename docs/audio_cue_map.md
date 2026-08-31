# Temporary Journey Audio Map

**Build:** `0.3.0-alpha.300`
**Status:** CC0 testing cues; replace before final audio direction

The interface retains its generated focus and ordinary confirmation sounds. Major journey transitions use distinct temporary cues so playtests can evaluate timing and acknowledgment without treating this library as final machine audio.

| Game event | Cue ID | Temporary asset | Trigger contract |
|---|---|---|---|
| Route accepted | `route_commit` | `confirmation_001.ogg` | Plays only after the route command succeeds. |
| Enter contact | `contact_entry` | `doorOpen_1.ogg` | Plays from the visible travel-to-contact action. |
| Resolve contact step | `contact_step` | `metalClick.ogg` | Plays after an encounter step succeeds. |
| Road resolved | `arrival` | `bookPlace1.ogg` | Plays when the authoritative encounter reaches arrival or recovery. |
| Enter location | `arrival_handoff` | `open_001.ogg` | Plays from the visible arrival acknowledgment. |
| Recovery service completed | `service` | `metalPot1.ogg` | Plays after repair, refuel, or hull service succeeds. |
| Roadside choice resolved | `event` | `bookFlip1.ogg` | Plays after an event choice is accepted. |
| Emergency order accepted | `intervention` | `switch_001.ogg` | Plays after the combat intervention changes state. |
| Open route review | `route_review` | `open_002.ogg` | Plays from the recovery route-review action. |
| Debrief reached | `debrief` | `bookOpen.ogg` | Plays when the run enters results. |

All cues use the existing Interface Audio setting and remain silent when muted. Checkpoint-controlled buttons suppress the ordinary click so one successful command does not produce two competing confirmations. Audio never advances state or controls timing.

The intended replacement vocabulary is route latch, fortress door, mechanism advance, braking/arrival weight, repair tools, paper/ledger handling, control lever, map case, and debrief folio. Final selection requires listening tests on speakers and headphones.
