# Create-Only Playtest Report Output

**Build:** `0.3.0-alpha.344`

## Purpose

The observer preflight already refused to overwrite a session sheet, but the post-session and cohort summarizers still used ordinary text writes. Reusing an output name could silently replace hand-written observations—the evidence automation is specifically unable to recreate.

## Behavior

`tools/report_output.py` provides one exclusive-create path for generated Markdown. Both local summarizers now:

- create missing parent directories;
- create a new UTF-8 report only when the destination does not exist;
- return a clear error when a file or directory already occupies that path;
- leave the existing content unchanged;
- continue to print to standard output when no `--output` is requested.

Observer instructions use `session-01-automatic.md` for generated evidence so it is visibly distinct from the provenance-stamped, hand-written session sheet.

## Release integration

The shared writer is included in both CI and tagged Windows/macOS cohorts and listed in each release manifest. The private-alpha contract requires both manifests and both uploaded artifacts to contain it, preventing a packaged summarizer from depending on a missing local module.

## Verification

- Unit coverage creates a nested report, blocks a second write, and confirms the original bytes remain unchanged.
- Existing session and cohort summary tests continue to cover their generated content.
- The full release suite verifies imports from the packaged cohort layout.
