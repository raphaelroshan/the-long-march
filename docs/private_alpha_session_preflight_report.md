# Private-Alpha Session Preflight Report

**Build:** `0.3.0-alpha.340`

## Purpose

The next roadmap gate requires five consented, unique, uncoached sessions on one exact artifact cohort. Manual provenance copying can mix builds or overwrite notes before the human evidence is even reviewed. The bundled session-preflight tool makes the artifact check and observer-sheet creation one non-destructive operation.

## Command

Run this from the extracted cohort root, changing the session number and output filename for each tester:

```bash
python tools/prepare_playtest_session.py artifacts/release_manifest.json --session 1 --output ../long-march-session-01.md
```

The tool verifies every file in the release manifest before writing anything. The generated sheet includes the exact build, cohort ID, platform, source and workflow commits, workflow URL, Godot version, desktop package path and digest, manifest digest, completed verification gates, consent checklist, and the bundled uncoached-session template.

## Safety boundary

- Altered, missing, malformed, or mixed cohort files block sheet creation.
- Session numbers must be positive.
- Observer output must remain outside the extracted cohort.
- Existing observer files are never overwritten.
- No player identity, network request, analytics event, or automatic upload is introduced.

## Verification

- Unit coverage creates and verifies a synthetic cohort, checks exact provenance, and confirms the bundled template is retained once.
- Negative coverage rejects digest mismatches, output inside the cohort, session zero, and overwrite attempts.
- The release workflow includes and checksums the preflight tool in both Windows and macOS cohorts.
- The private-alpha contract and full repository verification require the tool before release.
