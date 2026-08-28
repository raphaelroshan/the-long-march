# The Long March — Setup

## Requirements

Use Godot 4.4.1 stable with export templates and standard GDScript. Windows, macOS, and Ubuntu can run the deterministic project; Windows remains the primary commercial target. The prototype does not require external plugins.

## Open the project

Open the repository's `project.godot` in Godot 4.x, or launch it from the command line:

```bash
godot --editor --path .
```

The project entry scene is `scenes/App.tscn`, which owns the title, settings, pause, confirmation, save, and stage lifecycle. `scenes/Main.tscn` remains the independently testable playable stage. The authoritative campaign state remains in `src/core/fortress_state.gd`.

## Run tests

```bash
bash scripts/verify.sh
```

The verification script imports assets and runs the simulation, local playtest-journal, and complete UI-flow tests. If Godot is not installed, it exits with status `2` rather than pretending that tests passed.

## Validate content

```bash
python tools/validate_content.py --manifest content/content_manifest.json
python tools/validate_gameplay_framework.py --data content/gameplay_framework.json
```

Content files are authored source data. They are not executable scripts. New module, route, threat, event, or progression IDs must be added to the appropriate catalog and validated before implementation code references them.

## Local saves and playtest notes

The UI writes a versioned prototype save to `user://the_long_march_prototype.save`. The playtest journal and explicitly exported feedback bundles also remain under Godot's local `user://` directory. They are never uploaded by the game. Do not commit local saves or tester feedback.

The application intercepts operating-system close requests. A title screen or fully checkpointed march closes immediately; an unsaved live march offers **Save & Quit** and writes the existing Continue save before exit. If that write fails, the application remains open.

## Release staging

The repository contains reviewed Windows and unsigned macOS playtest export presets. Run `bash scripts/export_playtest.sh windows` or `bash scripts/export_playtest.sh macos` after installing matching Godot export templates. Tags matching `v*` produce both artifacts in the guarded GitHub Actions workflow. Steam, Epic, Apple signing, and notarization credentials must be added only through protected environments after a human release review.

The export script prints the detected Godot version, removes any stale target before building, and verifies that a non-empty artifact was created. A missing or mismatched export-template installation exits with status `3` and names the prerequisite instead of leaving an old build that appears current.
