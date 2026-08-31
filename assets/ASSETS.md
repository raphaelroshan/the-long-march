# The Long March visual asset manifest

The first journey slice uses an original hand-inked 2D industrial-fantasy direction: charcoal steel, oxidized brass, warm parchment, ember orange, muted teal signals, and restrained red threat accents. The visual job is to make the mobile fortress, its key modules, the road, and the destination readable at a glance without turning the prototype into a dense dashboard.

| Asset | Dimensions | Runtime role | Status |
|---|---:|---|---|
| `long_march_visual_reference.png` | 1280×720 | Internal art-direction reference for the Ashgate Lowlands and mobile fortress | Reference only |
| `ashgate_journey_background.png` | 1280×720 | Journey banner showing Ashgate Depot, the road, relay crossing, and distant convoy refuge | Integrated in `src/ui/main.gd` |
| `steam_lance_engine_icon.png` | 512×512 | Engine identity; movement and Burrower-risk unit | Integrated in the module strip |
| `shell_cannon_icon.png` | 512×512 | Burst weapon identity; primary Road Raider/Siege Beast counter | Integrated in the module strip |
| `field_workshop_icon.png` | 512×512 | Recovery identity; repairs the weakest damaged module after contact | Integrated in the module strip |
| `signal_coil_icon.png` | 512×512 | Recon identity; reveals the encounter target class | Integrated in the module strip |

These are first-pass generated project assets, not final animation sheets or a complete production tileset. The PNG files are stored as repository source content because they are used by the prototype and remain below the project’s artifact-size policy threshold. Godot import metadata, local saves, build output, and temporary scripts remain excluded from version control. No third-party images or credentials were added.


## Temporary testing kit

The temporary CC0 breadth kit is documented in [`docs/temporary_asset_kit.md`](../docs/temporary_asset_kit.md) and inventoried in [`assets/temporary/manifest.json`](temporary/manifest.json). It includes Kenney Tiny Town, Interface Sounds, RPG Audio, and a curated Particle Pack subset. These files support settlement breadth, travel transitions, journey timing, animation tests, and audio feedback; they are explicitly not the final moving-fortress, settlement, or machine sound identity.

Build `0.3.0-alpha.300` integrates the documented semantic audio subset plus `spark_03.png` and `smoke_03.png`. Tiny Town remains reference-only.
