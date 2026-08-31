# The Long March — Temporary Asset Kit

**Status:** Testing-only breadth kit  
**Build target:** Current private alpha branch  
**Purpose:** Give AI agents usable temporary fortress, settlement, travel, VFX, audio, and animation ingredients while the moving-fortress identity is refined.

## Included sources

| Source | Repository path | License | Intended use | Deficiency note |
|---|---|---|---|---|
| Kenney Tiny Town | `assets/temporary/kenney/tiny-town/` | CC0; proof in `assets/temporary/kenney/LICENSE-tiny-town.txt` | Temporary settlement cards, route plates, map pieces, and travel backgrounds | Cute 16×16 town art does not match the worn moving-fortress tone. Use as temporary regional filler and route-layout reference. |
| Kenney Interface Sounds | `assets/temporary/kenney/interface-sounds/` | CC0; proof in `assets/temporary/kenney/LICENSE-interface-sounds.txt` | Journey commitment, selection, confirmation, cancel, error, recovery, and Debrief feedback | Generic UI clicks do not communicate machinery, convoy strain, or settlement character. |
| Kenney RPG Audio | `assets/temporary/kenney/rpg-audio/` | CC0; proof in `assets/temporary/kenney/LICENSE-rpg-audio.txt` | Footsteps, doors, cloth, books, weapon, and material foley | Useful as temporary contact/settlement foley but not a custom engine, hull, wheel, or track soundscape. |
| Kenney Particle Pack | `assets/temporary/kenney/particle-pack/` | CC0; proof in `assets/temporary/kenney/LICENSE-particle-pack.txt` | Steam, dust, smoke, sparks, scorch, impact, and event emphasis | Generic particle shapes need tinting and restraint; they do not yet express a specific machine or frontier material. |

## Safe usage pattern in Godot

Load imported assets through `ResourceLoader` or `load`:

```gdscript
var settlement_texture: Texture2D = load("res://assets/temporary/kenney/tiny-town/tilemap.png")
var route_confirm: AudioStream = load("res://assets/temporary/kenney/interface-sounds/confirmation_001.ogg")
var engine_smoke: Texture2D = load("res://assets/temporary/kenney/particle-pack/smoke_01.png")
```

For temporary motion, use `AnimatedSprite2D`, `SpriteFrames`, `AnimationPlayer`, or a deterministic tween. The packs are mostly static tiles and effect frames; they are not a complete fortress animation set. Do not allow a visual animation to change route costs, contact outcomes, resource consumption, target order, or save state.

Route temporary audio through the project’s existing music, ambience, UI, world, or combat buses. Use `confirmation_001` for accepted route commitment, `error_001` for invalid preparation, `bookFlip1` or `bookOpen` for a report/receipt, `footstep` for a specialist movement cue, and `creak` or door sounds for temporary fortress/settlement transitions. Keep important consequence receipts audible above ambience.

## Long March-specific application

Use Tiny Town only where a journey state needs more atmosphere than the current placeholder or procedural layer provides: settlement arrival, route preview, roadside event, or background travel. Keep the fortress silhouette, dependency state, and route commitment visible above the temporary backdrop. The travel layer must not make the game look like a generic cheerful village crawler.

Use the Interface Sounds pack to give each journey transition a reliable acknowledgment. Route commitment, departure, contact resolution, recovery completion, arrival, and Debrief should not all use the same sound; select variants and document their semantic mapping. The eventual replacement should use machine and frontier cues, but these temporary sounds are sufficient to test timing and player confirmation.

Use particle frames for steam, dust, sparks, and damage smoke. Tint white effects toward the project palette and stop them during pause or reduced-motion mode. A short smoke loop can represent an already-recorded machine condition; it must not be used to signal a hidden future failure.

## Animation recipes for the agent

The temporary kit should support these deterministic presentation recipes:

1. A two- or three-frame smoke sequence follows a known damaged or overheated fortress state.
2. A short scale/fade cue confirms route commitment after the command is accepted.
3. A subtle parallax offset gives the travel background motion while the authoritative route state remains unchanged.
4. A two-frame spark or recoil cue stages a resolved road-contact impact.
5. A slow mechanical bob or vibration can be applied to the fortress silhouette during travel, with animation disabled or simplified under reduced-motion settings.

The animation layer must be driven by already-determined state. The same seed, commands, route, contact, recovery, and arrival must produce the same authoritative result under normal, paused, stepped, fast, reduced-motion, keyboard, and controller runs.

## Replacement priority

Replace Tiny Town first with a coherent set of settlement and route plates that make Ashgate, Morrowline, Lantern Quay, and Evacuation Camp distinct. Replace generic foley with engine hum, hull creaks, wheel/track rhythm, steam release, repair tools, wind, and braking sounds. Commission the moving-fortress key art and a small set of signature fortress details before commissioning many character or event illustrations.

The temporary pack is successful if it makes the full journey testable and atmospheric enough to expose timing and comprehension problems. It is not successful as final commercial art; all uses in evidence reports should be labeled as temporary placeholders.

## Provenance

The upstream pages are [Tiny Town](https://kenney.nl/assets/tiny-town), [Interface Sounds](https://kenney.nl/assets/interface-sounds), [RPG Audio](https://kenney.nl/assets/rpg-audio), and [Particle Pack](https://kenney.nl/assets/particle-pack). The local license files are the authoritative copies used for this temporary kit. Keep this document with the assets and do not redistribute raw source packages as a standalone asset bundle.
