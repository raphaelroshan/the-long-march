# LM-I6 Early Access Hardening Gate

**Build:** `0.3.0-alpha.362`

**Status:** Repository roadmap complete through LM-I6; public release remains blocked on owner approval and consented human evidence.

## Player-facing result

Build & Local Data now reports the current save schema, the complete supported migration window, and validated health for the campaign Continue file, recovery backup, and tutorial checkpoint. The panel distinguishes `NOT CREATED`, `VALID · DAY n`, and `UNUSABLE`; it no longer mistakes file presence for a healthy checkpoint.

If the primary checkpoint is corrupt or missing while its predecessor remains valid, the title offers a named Restore Backup action. Recovery requires explicit confirmation, retains a cancel path, names what will and will not change, restores the exact validated bytes, and re-enables Continue. A clean install remains a clearly empty state rather than an error.

## Package contract

Every generated release manifest now carries:

- the supported save-schema minimum and current version;
- an explicit offline-runtime declaration;
- the existing exact source, toolchain, platform, verification, file-size, and SHA-256 provenance.

The downloaded-cohort verifier rejects a missing or invalid compatibility window and a missing offline declaration. Candidate validation derives the schema window from `LongMarchState` and requires both candidate metadata and package metadata to match it.

## Automated evidence

- All declared save versions 4 through 16 are loaded by the hardening fixture; pre-16 fixtures acquire no invented obligation history.
- Version 17 is rejected, as are malformed state and invalid manifest compatibility declarations.
- Clean-install, corrupt-primary/valid-backup, explicit confirmation, exact restore, and post-restore health states run at 1600×900 and 1280×720 with 110% text, high contrast, reduced motion, and alternate controller layout.
- The complete repository gate still covers all four chapters, accessibility profiles, performance budgets, offline source scans, platform exports, packaged launch, downloaded-artifact verification, rollback provenance, and local-only evidence tooling.

## Visual evidence

- [`00_clean_install_health.png`](visual_evidence/v0.3.0-alpha.362-hardening-gate/00_clean_install_health.png)
- [`01_recoverable_save_health.png`](visual_evidence/v0.3.0-alpha.362-hardening-gate/01_recoverable_save_health.png)
- [`02_restore_confirmation.png`](visual_evidence/v0.3.0-alpha.362-hardening-gate/02_restore_confirmation.png)
- [`03_restored_save_health.png`](visual_evidence/v0.3.0-alpha.362-hardening-gate/03_restored_save_health.png)

## Honest boundary

Automation proves declared migration behavior, deterministic recovery, package integrity, offline boundaries, and supported layouts. It does not prove frame pacing on minimum consumer hardware, real suspend/resume behavior on every operating system, uncoached comprehension, balance, accessibility for a particular player, or commercial readiness.

## Next task

Run one consented, uncoached private-alpha cohort with the exact checksummed alpha.362 candidate, then convert the first repeated observed failure into one narrow reproducible repository issue.
