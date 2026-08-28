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
| Packaging | Project import, source snapshot, Windows build, and unsigned macOS playtest build | Produces guarded artifacts from reviewed export presets. |

## Local commands

```bash
python tools/policy_check.py --repo .
python tools/validate_content.py --manifest content/content_manifest.json
python tools/validate_gameplay_framework.py --data content/gameplay_framework.json
bash scripts/verify.sh
```

A missing local Godot executable is an environment limitation and causes `scripts/verify.sh` to exit with status `2`. The verifier requires each suite's explicit PASS marker and rejects Godot `ERROR:` or `SCRIPT ERROR:` output even if the engine process exits zero. GitHub Actions installs Godot 4.4.1 and runs the actual test suite on both operating systems.

Runnable desktop artifacts use `scripts/export_playtest.sh` both locally and in GitHub Actions. The workflow installs matching export templates before calling the script; locally, an absent or mismatched template set fails with status `3`, removes the incomplete target, and explains the required remedy.

The policy scanner checks tracked files and untracked files that Git would include, while respecting `.gitignore`. Local export folders and downloaded release artifacts therefore do not create false large-file or secret-pattern failures, but any newly introduced publishable file is still scanned before commit.

## AI review roles

The reviewer runs architecture, gameplay, QA, and security roles against the change diff and the untrusted `ci/quality_contract.md`. Reviewers return structured findings and do not modify the repository. The default model is `gpt-5-mini`; set the repository variable `AI_REVIEW_MODELS` only when a deliberate model change is needed. Set `AI_REVIEW_REQUIRED=true` only after configuring the secret and agreeing to the operational cost.

## Release staging

Pushes to `main` create a Windows release-candidate artifact and source snapshot. Tags matching `v*` or manual dispatch invoke the guarded desktop playtest workflow, which exports Windows and unsigned macOS builds from the reviewed presets. Steam, Epic, Apple signing, and notarization credentials are not stored in the repository. Storefront publishing remains a human-controlled action in a protected environment.
