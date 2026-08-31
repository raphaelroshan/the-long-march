# Temporary Journey Audio Map

**Build:** `0.3.0-alpha.311`
**Status:** CC0 testing cues; replace before final audio direction

The interface retains its generated focus and ordinary confirmation sounds. Major journey transitions use distinct temporary cues so playtests can evaluate timing and acknowledgment without treating this library as final machine audio.

| Game event | Cue ID | Temporary asset | Trigger contract |
|---|---|---|---|
| Route accepted | `route_commit` | `confirmation_001.ogg` | Plays only after the route command succeeds. |
| Enter contact | `contact_entry` | `doorOpen_1.ogg` | Plays from the visible travel-to-contact action. |
| Resolve ordinary contact step | `contact_step` | `metalClick.ogg` | Plays after a successful encounter step when no new family warning is due. |
| Road Raiders warning | `threat_road_raiders` | `drawKnife2.ogg` | Plays one readable step before arrival, or on step one for an immediate contact. |
| Climbers warning | `threat_climbers` | `beltHandle2.ogg` | Plays one readable step before arrival, evoking a grapnel or harness under tension. |
| Burrowers warning | `threat_burrowers` | `creak3.ogg` | Plays one readable step before arrival, evoking lower-hull strain. |
| Storm Front warning | `threat_storm_front` | `error_005.ogg` | Plays on the immediate warning step as a sustained signal alarm. |
| Siege Beast warning | `threat_siege_beast` | `bong_001.ogg` | Plays one readable step before arrival as a low, heavy alarm. |
| Flood Surge warning | `threat_flood_surge` | `drop_004.ogg` | Plays on the immediate warning step as a short fluid signal. |
| Civic Guardian warning | `threat_civic_guardian` | `glitch_004.ogg` | Plays one readable step before arrival as a clipped machine interruption. |
| Module placed or moved | `module_place` | `metalLatch.ogg` | Plays after the authoritative placement succeeds. |
| Module rotated | `module_rotate` | `beltHandle1.ogg` | Plays after a stored footprint or installed module rotates successfully. |
| Module removed | `module_remove` | `doorClose_2.ogg` | Plays after the selected module returns to storage. |
| Refit command blocked | `module_invalid` | `error_004.ogg` | Plays after a rejected placement, rotation, or removal while the written reason remains visible. |
| Road resolved | `arrival` | `bookPlace1.ogg` | Plays when the authoritative encounter reaches arrival or recovery. |
| Enter location | `arrival_handoff` | `open_001.ogg` | Plays from the visible arrival acknowledgment. |
| Recovery service completed | `service` | `metalPot1.ogg` | Plays after repair, refuel, or hull service succeeds. |
| Roadside choice resolved | `event` | `bookFlip1.ogg` | Plays after an event choice is accepted. |
| Emergency order accepted | `intervention` | `switch_001.ogg` | Plays after the combat intervention changes state. |
| Open route review | `route_review` | `open_002.ogg` | Plays from the recovery route-review action. |
| Debrief reached | `debrief` | `bookOpen.ogg` | Plays when the run enters results. |

All cues use the existing Interface Audio setting and remain silent when muted. Checkpoint-controlled controls suppress the ordinary click so one successful command does not produce two competing confirmations. A family warning replaces only the generic contact-step cue at its deterministic warning step; refit sounds follow the accepted or rejected command result. Audio never advances state or controls timing.

The intended replacement vocabulary is route latch, fortress door, mechanism advance, braking/arrival weight, repair tools, paper/ledger handling, control lever, map case, and debrief folio. Final selection requires listening tests on speakers and headphones.
