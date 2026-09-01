# Packaged Evidence Workflow Smoke

**Build:** `0.3.0-alpha.349`

## Purpose

The release pipeline previously verified each downloaded platform cohort and generated an observer sheet, but it did not exercise the rest of the tools exactly as packaged. A missing import or omitted file could therefore leave packet finalization or cohort synthesis broken despite passing repository tests.

## Implemented contract

`tools/smoke_playtest_evidence.py` now runs against an extracted, verified cohort and:

- creates a fresh observer sheet outside the cohort;
- writes a clearly synthetic feedback export matching the manifest's build and platform;
- creates and reverifies a provenance-bound session packet;
- confirms consent, uniqueness, uncoached status, and comprehension remain false;
- produces a one-packet cohort report that must remain `INCOMPLETE (1/5 verified packets)`; and
- refuses existing or in-cohort output and removes partial output after a failed run.

Both CI and tagged-release manifests checksum the harness. Pull-request CI downloads its exact packaged Windows candidate and invokes the bundled copy before merge. The publisher repeats that proof from each downloaded Windows and macOS cohort before release assets are assembled.

## Verification

The focused test covers successful creation, artifact identity, false human-owned claims, overwrite refusal, and cohort isolation. The harness also completed against both downloaded `0.3.0-alpha.347` cohorts and the public `0.3.0-alpha.348` macOS cohort. Alpha.349 adds the same downloaded-artifact proof to every pull request so packaging regressions fail before a release tag exists.

## Boundary

This smoke proves executable packaging and provenance checks only. Synthetic answers are never copied into the release, never count toward the five-session target, and provide no evidence of consent, participant uniqueness, uncoached use, comprehension, pacing, balance, or product quality.
