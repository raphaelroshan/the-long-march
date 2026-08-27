# Content Pipeline

Content is authored as human-readable design documents and machine-readable JSON. `content/content_manifest.json` contains stable campaign IDs for locations, factions, characters, events, progression, and endings. `content/gameplay_framework.json` contains stable implementation IDs for spaces, module families, modules, dependencies, interventions, threats, progression tracks, and vertical-slice limits.

The content layer is not executable scripting. Narrative descriptions, requirements, and effects are authored intent. Runtime code must translate them into explicit commands and deterministic state changes.

## Authoring rules

Every object receives a stable `snake_case` ID. Display names, descriptions, and dialogue may change without changing IDs. A module must define shape, mass, power, heat, durability, tags, and connections. A threat must define its doctrine, targets, and at least two counter-options. An intervention must define timing, cost, benefit, and risk.

Every authored event belongs to a chapter, references known locations, contains at least two choices, and gives each choice requirements, effects, and a visible result. A progression node must create a new layout, route, intervention, information source, or recovery choice rather than only increasing a number.

## Agent workflow

An implementation agent should read `AGENTS.md`, the relevant design document, and the current simulation before changing content or runtime code. Work on one small slice: one module family, one dependency, one threat doctrine, one intervention, one route encounter, or one campaign event. Update the JSON source, runtime command mapping, deterministic tests, and player-facing explanation together.

Run the following checks before opening a pull request:

```bash
python tools/policy_check.py --repo .
python tools/validate_content.py --manifest content/content_manifest.json
python tools/validate_gameplay_framework.py --data content/gameplay_framework.json
bash scripts/verify.sh
```

## Quality bar

A player should understand why a module is valuable, what it depends on, what it costs to carry, and what happens when it fails. A threat should be telegraphed, counterable, and capable of producing a recoverable outcome. A campaign event should alter a meaningful route, resource, relationship, or fortress choice. Content that adds lore without changing a decision is not ready for merge.
