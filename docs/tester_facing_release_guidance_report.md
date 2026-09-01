# Tester-Facing Release Guidance Report

**Build:** `0.3.0-alpha.342`

## Purpose

The first automated prerelease proved asset integrity but left GitHub's generated one-line change list to explain the build. A tester without repository context still had to infer which download was playable, why two larger archives existed, and how to begin a verified session.

## Release preamble

`tools/render_release_notes.py` generates a stable preamble from the trusted tag and workflow URL. It states:

- that the build is private alpha rather than a public or storefront release;
- the exact Windows and macOS standalone filenames;
- the exact Windows and macOS observer-cohort filenames;
- what additional material a cohort contains;
- the one-command verified-session setup;
- how `SHA256SUMS.txt` and the internal cohort manifest differ;
- the workflow run that produced and verified the assets.

GitHub's generated change list follows this preamble, retaining the concrete PR history without asking automation to summarize product quality.

## Rerun behavior

The first successful tag run creates the preamble and generated changes together. A rerun refreshes assets and preserves the existing release body, preventing duplicate generated sections or accidental replacement of owner edits.

## Verification

- Unit coverage checks every platform filename, the private-alpha boundary, session command, integrity guidance, workflow link, and invalid input rejection.
- Workflow contract coverage requires the renderer and combined custom/generated note flags.
- The full repository suite remains required before the tag is created.
- The `v0.3.0-alpha.342` release is the live end-to-end proof.
