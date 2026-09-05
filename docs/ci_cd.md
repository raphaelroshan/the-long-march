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
| Bounded verification | Static contracts plus core, presentation, journey, and regional Godot groups | Blocks failures; Godot groups run independently on Ubuntu and Windows. |
| AI review | Architecture, gameplay, QA, and security findings | Blocks critical findings; otherwise reports. |
| Packaging | Project import, source snapshot, Windows, unsigned macOS, and x86-64 Linux playtest builds | Produces guarded artifacts from reviewed export presets. |

## Local commands

```bash
python tools/policy_check.py --repo .
python tools/validate_content.py --manifest content/content_manifest.json
python tools/validate_gameplay_framework.py --data content/gameplay_framework.json
bash scripts/verify.sh
```

The default command still runs every check. During diagnosis or development, the same coverage can be run as bounded groups:

```bash
bash scripts/verify.sh --list
bash scripts/verify.sh static
bash scripts/verify.sh core
bash scripts/verify.sh presentation
bash scripts/verify.sh journey
bash scripts/verify.sh regional
```

Every step emits a `VERIFY_TIMING` record, every group emits `VERIFY_GROUP_RESULT`, and the invocation ends with `VERIFY_RESULT`, including the slowest completed step. These are coarse wall-clock diagnostics rather than performance budgets. The static group does not require Godot. A missing local Godot executable causes only Godot-backed groups to exit with status `2`.

The verifier requires each suite's explicit PASS marker and rejects Godot `ERROR:` or `SCRIPT ERROR:` output even if the engine process exits zero. GitHub Actions installs Godot 4.4.1 and runs core, presentation, journey, and regional groups independently on Ubuntu and Windows; static checks run once on Ubuntu. Splitting controls failure scope and CI wall time without removing any prior invocation.

Runnable desktop artifacts use `scripts/export_playtest.sh` both locally and in GitHub Actions. The workflow installs matching export templates and completes validation/import before calling the script with `LONG_MARCH_SKIP_IMPORT=1`; this avoids a redundant Windows editor import after the verified cache already exists. Local calls still import by default. An absent or mismatched template set fails with status `3`, removes the incomplete target, and explains the required remedy.

The policy scanner checks tracked files and untracked files that Git would include, while respecting `.gitignore`. Local export folders and downloaded release artifacts therefore do not create false large-file or secret-pattern failures, but any newly introduced publishable file is still scanned before commit.

## AI review roles

The reviewer runs architecture, gameplay, QA, and security roles against the change diff and the untrusted `ci/quality_contract.md`. Reviewers return structured findings and do not modify the repository. The default model is `gpt-5-mini`; set the repository variable `AI_REVIEW_MODELS` only when a deliberate model change is needed. Set `AI_REVIEW_REQUIRED=true` only after configuring the secret and agreeing to the operational cost.

## Release staging

Pushes to `main` create Windows and Linux release-candidate artifacts with source snapshots. Tags matching `v*` or manual dispatch invoke the guarded desktop playtest workflow, which exports Windows, unsigned macOS, and x86-64 Linux builds from the reviewed presets. Steam, Epic, Apple signing, and notarization credentials are not stored in the repository. Storefront publishing remains a human-controlled action in a protected environment.
