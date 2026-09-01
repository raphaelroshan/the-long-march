# Player-First README Report

**Build:** `0.3.0-alpha.343`

## Purpose

The public README had become a long implementation inventory. It documented real work, but it buried the playable release, repeated internal details, retained obsolete prototype language, and made the game harder to understand than the current vertical slice.

## New landing-page order

The README now presents:

1. the moving-fortress premise;
2. one representative in-game frame and an explicit alpha-art caption;
3. direct Windows, macOS, observer-cohort, and integrity guidance;
4. the settlement → refit → route → travel → event/contact → recovery → finale loop;
5. a compact table for First Watch, Ashgate Lowlands, and Flooded Veyru;
6. the five mechanical principles that make the fortress matter;
7. controls, comfort settings, local build commands, and observed-playtest setup;
8. authoritative design references and a frank scope boundary.

Detailed feature history remains available in the roadmap, decision log, visual gallery, and verification report rather than competing with the first impression.

## Regression boundary

`tests/test_readme_contract.py` requires the release link, platform choices, checksum and cohort instructions, current loop, both chapters, privacy boundary, verification command, scope boundary, and roadmap. It rejects obsolete prototype copy and caps both total lines and bullets so the page cannot silently return to a subsystem inventory.

## Non-claims

The README does not claim final art, final audio, storefront availability, a complete five-region campaign, accessibility certification, or human comprehension. The current screenshot is identified as code-native alpha presentation.
