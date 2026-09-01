# Automated Prerelease Publication Report

**Build:** `0.3.0-alpha.341`

## Purpose

Tagged releases previously required a manual sequence after CI: download both artifacts, verify them, rename standalone builds, create two cohort archives, upload four assets, and check the release. That process was repeatable but still exposed the public test artifact to naming, omission, and mixed-cohort mistakes.

## Tag-gated flow

An owner-created `v*` tag remains the authorization boundary. Manual workflow dispatch can build candidates but cannot publish a release. After both platform jobs pass, the publish job:

1. downloads the Windows and macOS cohorts produced by that workflow run;
2. verifies every file against each platform manifest;
3. runs the bundled session preflight against both cohorts;
4. copies the standalone executable/archive into stable release names;
5. creates complete Windows and macOS cohort archives;
6. tests all ZIP files;
7. creates `SHA256SUMS.txt` for the four downloadable builds;
8. creates a prerelease from the verified tag, or refreshes the same assets safely on rerun.

## Permission boundary

The build matrix retains read-only repository access. Only the tag-gated publish job receives `contents: write`, and it runs only after both platform candidates succeed. Pull requests and manual workflow dispatches cannot create GitHub releases.

## Verification

- A repository test checks the tag gate, matrix dependency, scoped write permission, both downloads, both manifest checks, both preflight checks, archive construction, checksum generation, and idempotent release commands.
- The private-alpha contract requires the publication test in the full verification suite.
- The first live proof is the `v0.3.0-alpha.341` tag and its generated prerelease assets.
