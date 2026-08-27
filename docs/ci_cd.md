# The Long March — CI/CD and Multi-Agent Validation

## Purpose

The Long March uses the same deterministic validation contract as the other private game repositories. Pull requests and pushes to `main` run repository policy checks, content validation, gameplay-framework validation, Godot headless tests on Ubuntu and Windows, independent AI review roles, and a source release-candidate package.

The AI review layer is advisory unless it reports a critical finding. It never replaces deterministic tests. The workflow reads `OPENAI_API_KEY` only from a protected GitHub Actions secret. If the secret is absent, the static reviewer still produces a report and the ordinary pull request remains usable.

## Validation layers

| Layer | What it validates | Default behavior |
|---|---|---|
| Repository policy | Required project files, secret patterns, large/generated artifacts | Blocks policy errors. |
| Content manifest | Stable locations, characters, events, progression, and ending references | Blocks malformed content. |
| Gameplay framework | Modules, shapes, spaces, connections, threats, interventions, progression, and slice scope | Blocks incomplete framework data. |
| Godot tests | Placement, dependencies, power, heat, travel, threats, interventions, recovery, and save/load | Blocks failures on Ubuntu or Windows. |
| AI review | Architecture, gameplay, QA, and security findings | Blocks critical findings; otherwise reports. |
| Packaging | Project import and source snapshot; Windows export once presets exist | Produces an artifact; guarded release requires presets. |

## Local commands

```bash
python tools/policy_check.py --repo .
python tools/validate_content.py --manifest content/content_manifest.json
python tools/validate_gameplay_framework.py --data content/gameplay_framework.json
bash scripts/verify.sh
```

A missing local Godot executable is an environment limitation and causes `scripts/verify.sh` to exit with status `2`. GitHub Actions installs Godot 4.4.1 and runs the actual test suite on both operating systems.

## AI review roles

The reviewer runs architecture, gameplay, QA, and security roles against the change diff and the untrusted `ci/quality_contract.md`. Reviewers return structured findings and do not modify the repository. The default model is `gpt-5-mini`; set the repository variable `AI_REVIEW_MODELS` only when a deliberate model change is needed. Set `AI_REVIEW_REQUIRED=true` only after configuring the secret and agreeing to the operational cost.

## Release staging

Pushes to `main` create a source release-candidate artifact. Tags matching `v*` or manual dispatch invoke the guarded Windows release workflow, which requires a reviewed `export_presets.cfg`. Steam and Epic credentials are not stored in the repository. Actual storefront publishing remains a human-controlled action in a protected environment.
