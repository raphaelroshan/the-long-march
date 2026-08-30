# L10 — Private-Alpha Hardening

**Build:** `0.3.0-alpha.297`

## Result

PASS for automated private-alpha readiness. The repository now produces a versioned, checksummed candidate only after the source tests and the exported executable both pass their gates.

## Closed gaps

- Windows and macOS exports are launched headlessly after packaging; a non-zero exit, timeout, script error, or runtime error fails the candidate.
- Packaged runtime sources are checked for Godot networking APIs, socket peers, and remote URLs.
- The release manifest records the exact Godot version in addition to product version, source revision, workflow run, platform, verification stages, sizes, and SHA-256 hashes.
- CI verifies the completed manifest before uploading it.
- A deterministic performance gate runs 1,800 representative planning inspections and 60 same-seed encounter replays under conservative headless budgets.
- A machine-readable contract protects the pinned engine, both desktop targets, controller/audio/responsive/full-flow coverage, offline check, packaged smoke, and the explicit `release_ready: false` boundary.

## Existing gates retained

The complete suite still covers fresh local state, supported older saves, malformed and future saves, backup restoration, active battles and events, settlement recovery, terminal results, safe close, controller navigation, 100% and 110% text, high contrast, reduced motion, interface audio and mute, both five-encounter chapters, and exact cohort hashing.

## Honest limitations

The performance test protects deterministic state-processing throughput, not rendered frame rate across arbitrary hardware. The macOS candidate remains unsigned and unnotarized. Final music, ambience, combat sound, bespoke animation, storefront SDKs, and the planned five-region campaign are not included. Human sessions remain necessary to assess comprehension, pacing, comfort, and enjoyment.

## Candidate and rollback

The CI package job creates a clean-run Windows candidate for every reviewed commit. The tagged release workflow creates Windows and macOS candidates from the same immutable source revision. Each download includes its verifier, observer brief, session sheet, limitations, source snapshot, and release manifest. Rollback means retaining and returning to the exact previously verified package and manifest pair.
