# LM-GPT56-1C — Bounded Verification and Journey Re-Proof

**Build:** `0.3.0-alpha.364`

**Status:** Complete. Verification is split into bounded diagnostic groups without dropping prior coverage, and the full clean-save journey has fresh Godot 4.4.1 evidence at both supported review sizes.

## Verification structure

`scripts/verify.sh` defaults to the full suite and also accepts `static`, `core`, `presentation`, `journey`, or `regional`. Every check prints a coarse wall-clock `VERIFY_TIMING` record. Each group and invocation ends with a machine-readable PASS record and elapsed time. `tests/test_verify_groups.py` locks the group names, direct step counts, 55 Godot invocations, timing markers, and CI matrix membership.

| Group | Direct checks | Local time | Scope |
|---|---:|---:|---|
| static | 27 | 5s | Content, release, documentation, packaging, and group contracts |
| core | 15 plus import | 41s | Fortress/campaign state, persistence, memory, and hardening |
| presentation | 17 plus import | 52s | Audio, visual, presenters, shell, recovery, and tutorial |
| journey | 12 plus import | 134s | Complete-journey variants and prototype flow |
| regional | 11 plus import | 76s | Veyru, Cinder, White Salt, and breadth UI flows |

These measurements came from one Apple M1 Pro workstation using Godot `4.4.1.stable.official.49a5bc7b6`. They identify failure scope and likely bottlenecks; they are not stable benchmarks. The journey group is slowest. Its Cinder Quarry, declined-convoy, investment, completion, and responsive fixtures each completed in approximately 11 seconds, so the earlier 900-second bound was not reproduced as a single runaway fixture.

GitHub Actions runs static once on Ubuntu and each Godot group independently on Ubuntu and Windows. This produces nine bounded jobs while preserving both-platform Godot coverage. The default all-suite command remains the local and release contract.

## Complete journey evidence

- [`v0.3.0-alpha.364-gpt56-1c-1600x900/`](visual_evidence/v0.3.0-alpha.364-gpt56-1c-1600x900/) — 24 standard rendered states.
- [`v0.3.0-alpha.364-gpt56-1c-1280x720/`](visual_evidence/v0.3.0-alpha.364-gpt56-1c-1280x720/) — 22 representative accessibility states.

Both runs start without local state and use normal player actions through First Watch, live refit, route commitment, travel, contact, recovery, the next-road decision, Meridian Pass, and terminal Debrief. Their schema-2 manifests bind exact files and SHA-256 digests to four restored checkpoints and a five-contact completed run. The rendered-frame gate now treats these fresh sets as the candidate evidence.

The compact contact remains information-dense, but its fortress state, forecast, counter, prepared response, advance action, emergency orders, and timeline remain visible. Automation proves rendering, bounds, state continuity, and deterministic completion; it does not prove that a person understood or enjoyed the flow.

## Verification

Focused groups passed independently on Godot 4.4.1. The default all-suite command then passed all five groups in 300 seconds: static 7s, core 50s, presentation 56s, journey 119s, and regional 68s, with an 11-second slowest step. Normal scheduler and cache variation explains the difference from the independent timings above. Both-platform CI results are recorded on the pull request carrying this report.

## Next packet

Run exactly one consented, uncoached **LM-H1** observation cohort against an exact checksummed candidate. Convert the first repeated comprehension, comfort, pacing, or replay-intent finding into one narrow repository issue.
