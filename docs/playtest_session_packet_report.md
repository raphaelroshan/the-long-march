# Provenance-Checked Playtest Session Packet

**Build:** `0.3.0-alpha.345`

## Problem

The verified preflight established which build an observer intended to test, and the game export identified its own build, but the two files still depended on manual naming and storage discipline after the session. A renamed or misplaced export could be reviewed beside the wrong notes without either file being altered.

## Implemented contract

`tools/finalize_playtest_session.py create` now:

- reverifies every file in the retained release cohort;
- checks the observer sheet's build, cohort, platform, source commit, executable digest, and manifest digest;
- requires the local feedback export to name the same player-facing build;
- creates a new output directory and refuses any existing destination;
- preserves byte-identical copies as `observer.md`, `feedback.json`, and `release_manifest.json`;
- creates `automatic.md` separately from the human notes;
- records byte lengths and SHA-256 digests in `packet_manifest.json`;
- omits original filenames and machine-specific paths; and
- records artifact identity as verified while leaving consent, uniqueness, coaching, and comprehension unverified.

`tools/finalize_playtest_session.py verify` detects missing or changed packet files and rejects any manifest that promotes a human-owned claim.

## Evidence

`tests/test_finalize_playtest_session.py` covers a valid packet, source-byte preservation, existing-output refusal, mismatched feedback builds, altered observer provenance, in-cohort output rejection, human-claim tampering, and file hash/size tampering. The tool and its dependencies are checksummed in both platform cohorts.

## Boundary

The packet is local evidence handling, not analytics or automatic qualitative analysis. It can contain direct quotes and written answers, so it remains outside Git and shared services unless the participant consented and identifying information was removed. A valid packet does not prove that a session was consented, unique, uncoached, understood, or successful.
