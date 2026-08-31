# Threat-Family Audio Identity

**Build:** `0.3.0-alpha.308`

## Purpose

Make the seven implemented contacts recognizable by sound at the same readable warning point already shown by the road-contact view. The cue should reinforce the visible threat family without adding another combat phase or requiring audio to understand the encounter.

## Implemented

- Added one restrained CC0 temporary cue for Road Raiders, Climbers, Burrowers, Storm Fronts, the Siege Beast, Flood Surges, and the Civic Guardian.
- Routes the family cue on the final readable step before its authored arrival; threats that arrive on step one cue immediately.
- Keeps the existing generic mechanism cue for successful encounter steps without a new approach warning.
- Uses the existing three-player pool and Interface Audio volume control, including complete mute suppression.
- Leaves target choice, arrival timing, damage, random streams, save state, and encounter resolution unchanged.

## Verification

- Unit coverage proves all seven stable threat IDs map to available family cues at the intended warning step.
- Complete-journey coverage proves the cue follows the successful authoritative advance rather than the button press.
- Unknown, defeated, and non-warning contacts fall back to the bounded generic contact-step cue.
- Full repository verification must pass before merge.

## Human validation still required

The temporary sounds are mnemonics, not final sound design. Private-alpha listening should check whether each family remains distinguishable on speakers and headphones, whether warning volume competes with spoken conversation, and whether mixed-threat roads feel informative rather than noisy.
