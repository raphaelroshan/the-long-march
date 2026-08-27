# The Long March — Setup

## Requirements

Use Godot 4.4.1 stable, standard GDScript, and a Windows or Ubuntu development environment. The project does not require external plugins for the deterministic prototype.

## Open the project

Open `/home/ubuntu/the_long_march/project.godot` in Godot 4.x, or launch it from the command line:

```bash
godot --editor --path .
```

The current scene is `scenes/Main.tscn`. The UI is intentionally lightweight; the authoritative state remains in `src/core/fortress_state.gd`.

## Run tests

```bash
bash scripts/verify.sh
```

The test entrypoint is `res://tests/test_fortress_state.gd`. If Godot is not installed, the script exits with status `2` rather than pretending that tests passed.

## Validate content

```bash
python tools/validate_content.py --manifest content/content_manifest.json
python tools/validate_gameplay_framework.py --data content/gameplay_framework.json
```

Content files are authored source data. They are not executable scripts. New module, route, threat, event, or progression IDs must be added to the appropriate catalog and validated before implementation code references them.

## Prototype save

The UI writes a local prototype save to `user://the_long_march_prototype.save`. Production save files require versioning, migrations, and platform cloud integration. Do not commit local saves.

## Release staging

The repository contains CI and a guarded release-candidate workflow. Windows export remains intentionally blocked until a reviewed `export_presets.cfg` and production export configuration exist. Steam and Epic distribution credentials must be added only through protected GitHub environments after a human release review.
