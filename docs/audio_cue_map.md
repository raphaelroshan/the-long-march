# Temporary Journey Audio Map

**Build:** `0.3.0-alpha.355`
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
| Ember Drakes warning | `threat_ember_drakes` | `knifeSlice2.ogg` | A fast cutting cue precedes the overhead fireline dive. |
| Lift Saboteurs warning | `threat_lift_saboteurs` | `metalLatch.ogg` | A small mechanical release precedes the gantry attack. |
| Elevator Warden warning | `threat_elevator_warden` | `drop_003.ogg` | A heavy descending cue precedes the counterweight impact. |
| Salt Storm warning | `threat_salt_storm` | `error_008.ogg` | A dry signal alarm precedes the whiteout shear. |
| Rival Scouts warning | `threat_rival_scouts` | `drawKnife1.ogg` | A light weapon cue precedes the open-flank mark. |
| Rival Fortress warning | `threat_rival_fortress` | `doorClose_4.ogg` | A heavy closure cue precedes the parallel broadside. |
| Signal Hunters warning | `threat_signal_hunters` | `glitch_003.ogg` | A broken transmission cue precedes the false-beacon lock. |
| Bridgebreakers warning | `threat_bridgebreakers` | `metalPot2.ogg` | A lower metallic strike precedes the underspan charge. |
| Module placed or moved | `module_place` | `metalLatch.ogg` | Plays after the authoritative placement succeeds. |
| Module rotated | `module_rotate` | `beltHandle1.ogg` | Plays after a stored footprint or installed module rotates successfully. |
| Module removed | `module_remove` | `doorClose_2.ogg` | Plays after the selected module returns to storage. |
| Refit command blocked | `module_invalid` | `error_004.ogg` | Plays after a rejected placement, rotation, or removal while the written reason remains visible. |
| Resolved contact impact | `contact_impact` | `metalPot3.ogg` | Plays once when an animated resolved step reaches Impact, or immediately at Consequence under Reduced Motion. |
| Road resolved | `arrival` | `bookPlace1.ogg` | Plays when the authoritative encounter reaches arrival or recovery. |
| Enter location | `arrival_handoff` | `open_001.ogg` | Plays from the visible arrival acknowledgment. |
| Recovery service completed | `service` | `metalPot1.ogg` | Plays after repair, refuel, or hull service succeeds. |
| Roadside choice resolved | `event` | `bookFlip1.ogg` | Plays after an event choice is accepted. |
| Emergency order accepted | `intervention` | `switch_001.ogg` | Plays after the combat intervention changes state. |
| Open route review | `route_review` | `open_002.ogg` | Plays from the recovery route-review action. |
| Debrief reached | `debrief` | `bookOpen.ogg` | Plays when the run enters results. |

All cues use the existing Interface Audio setting and remain silent when muted. Checkpoint-controlled controls suppress the ordinary click so one successful command does not produce two competing confirmations. A family warning replaces only the generic contact-step cue at its deterministic warning step; refit sounds follow the accepted or rejected command result. The material impact cue follows an already-resolved hit and never controls when it occurs. Audio never advances state or simulation timing.

The intended replacement vocabulary is route latch, fortress door, mechanism advance, braking/arrival weight, repair tools, paper/ledger handling, control lever, map case, and debrief folio. Final selection requires listening tests on speakers and headphones.
