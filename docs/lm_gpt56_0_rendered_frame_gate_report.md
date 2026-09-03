# LM-GPT56-0 — Rendered-Frame Evidence Gate

**Build:** `0.3.0-alpha.364`

**Status:** Complete. Invalid desktop captures are retained as negative fixtures and cannot satisfy the visual-evidence gate.

## Failure reproduced

The September 3 review produced three uniform-grey 1280×720 desktop frames. Automated gameplay tests were green, but those images contained no trustworthy game state. The exact failed title frame at `docs/visual_evidence/v0.3.0-alpha.363-review-2026-09-03/01_title.png` is now a deterministic negative fixture: the gate must reject it.

## Capture contract

`tests/support/rendered_frame_capture.gd` owns evidence capture. It waits for Godot's `RenderingServer.frame_post_draw`, reads the game viewport rather than the desktop, checks the exact requested dimensions, samples the image, and rejects frames with fewer than eight quantized colors or less than `0.05` luminance range. It retries for at most eight rendered frames, then fails with the measured reason instead of writing a misleading screenshot.

Every accepted capture records its readiness attempt, dimensions, sampled color count, luminance range, opaque sample count, filename, and SHA-256 digest. `tests/test_complete_journey_handoff.gd` writes those records to a versioned `capture-manifest.json`. Rendering remains presentation-only and never reads or mutates `LongMarchState`.

## Deterministic fixtures

`tests/test_rendered_frame_capture.gd` proves four boundaries:

- a synthetic uniform-grey frame is rejected;
- the exact failed review frame is rejected;
- a varied synthetic frame is accepted;
- every committed alpha.364 journey image has the declared size, checksum, bounded readiness attempt, and non-uniform content.

The committed sets contain 22 states at 1280×720 and 24 states at 1600×900. Both begin at the title and continue through First Watch, live refit, route commitment, travel, road interruption, contact, arrival, the specialist conflict, recovery, changed road, promise callback, finale, and Debrief.

No campaign IDs or simulation behavior changed. The recaptured route uses region `ashgate_lowlands`, nodes `ashgate_depot`, `rill_crossing`, `broken_relay`, `morrowline_camp`, `cinder_quarry`, and `meridian_pass`, and the established `road_raiders`, `climbers`, `burrowers`, and `siege_beast` contact families. `LongMarchState` remains the authoritative state owner; the new helper owns only viewport evidence.

## Changed files and verification

- `tests/support/rendered_frame_capture.gd` implements the readiness and image-quality boundary.
- `tests/test_complete_journey_handoff.gd` records only accepted frames and writes the exact manifest.
- `tests/test_rendered_frame_capture.gd` locks the negative and positive fixtures plus both committed journeys.
- `scripts/verify.sh` makes the evidence gate mandatory for every pull request and release candidate.

The required commands completed with exit code zero:

```text
python3 tools/validate_content.py --manifest content/content_manifest.json
repository content manifest: PASS (the-long-march, 17 events, 4 endings)

env PATH=/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS:$PATH bash scripts/verify.sh
build version consistency: PASS (0.3.0-alpha.364)
PASS: The Long March LM-GPT56-0 rendered-frame evidence gate
PASS: The Long March LM-GPT56-1 full creative journey
PASS: The Long March responsive journey profile 1280x720
PASS: The Long March responsive White Salt profile 1600x900
PASS: The Long March LM-I4 breadth UI flow 1280x720
```

The abbreviated markers come from one complete run of the repository script; all intervening content, state, save, accessibility, regional, performance, and package-contract fixtures also passed.

## Evidence

- [`v0.3.0-alpha.364-gpt56-journey-1280x720`](visual_evidence/v0.3.0-alpha.364-gpt56-journey-1280x720/)
- [`v0.3.0-alpha.364-gpt56-journey-1600x900`](visual_evidence/v0.3.0-alpha.364-gpt56-journey-1600x900/)

These are code-native Godot viewport captures. They do not replace final art review, human readability testing, or consumer-hardware validation.

The fortress and UI in these frames are code-native project assets. Temporary licensed Kenney smoke and interface/contact audio remain unchanged; Tiny Town remains reference-only. The capture repair introduced no new third-party asset.

The 35–55 minute First Watch plus Ashgate estimate is still authored. Automation confirms the sequence and its state transitions, not human reading speed, decision time, fatigue, or replay appetite.

## Next packet

Revalidate **LM-GPT56-1 — Full creative journey** using only the captured states accepted by this gate.
