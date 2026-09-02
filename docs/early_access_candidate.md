# The Long March — Early Access candidate

**Candidate version:** `0.3.0-alpha.359`
**Release state:** mechanically complete candidate; owner approval and human playtesting are still required before public release.

This candidate contains four standalone five-contact journeys: Ashgate Lowlands, Flooded Veyru, the Cinder Spine, and the White Salt Expanse. Together they exercise three chassis geometries, twenty modules, six specialists, fifteen threat families, twenty-one authored decisions or meetings, five persistent regional developments, and composable Debrief outcomes.

## Build and verification

Pull-request CI is the source of candidate packages. Windows and Linux jobs export with the pinned Godot version, launch the packages headlessly, verify the offline boundary, and write checksummed release manifests before merge. A version tag repeats the complete workflow for Windows, unsigned macOS, and Linux, and can publish a GitHub prerelease only after all three candidates are downloaded and reverified. `release_ready` remains false until the repository owner approves a public release.

Run the complete local gate with:

```bash
bash scripts/verify.sh
```

The gate validates authored content, deterministic chapter runs, save migration and malformed-save rejection, controller and responsive layouts, contrast and reduced motion, semantic audio, performance budgets, package manifests, and the local-only playtest evidence workflow.

## Save and rollback contract

Run saves accept schema versions 4 through 15. A save created by a newer build is rejected without partial restoration. Chassis geometry, installed and stored modules, specialist assignment, active event, route position, encounter state, regional developments, and replay order are validated before replacement of live state. The application maintains a prior checkpoint for explicit recovery. Published cohorts identify their exact executable and source snapshot by SHA-256; rollback means retaining and launching that exact artifact rather than rebuilding a tag with a different toolchain.

## Approval boundary

Passing automation proves determinism, package integrity, and the declared technical scope. It does not prove comprehension, balance, pacing, accessibility for a specific player, or commercial readiness. Those remain owner and human-playtest decisions listed in the known limitations and test matrix.
