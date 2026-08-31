# Tutorial Fortress Continuity Report

**Build:** `0.3.0-alpha.307`

## Purpose

The First Watch prologue previously used a simplified rectangle-and-window fortress that disappeared when gameplay began. The introduction now teaches through the same actor used in settlements, travel, contact, recovery, and Debrief.

## Page treatment

- **A Moving Settlement:** the shared fortress rests with recognizable module-family bays and crew-scale service activity.
- **Build the Chain:** dependency links connect actual engine, fuel, weapon, workshop, and crew anchors on that fortress.
- **Read the Road:** the same actor shifts into its departure stance, with road marks and the first contact ahead.

## Architecture boundary

The prologue supplies a fixed presentation-only module set to `FortressSilhouette`. It does not instantiate `FortressState`, create a save, or alter tutorial progress. Page changes affect only drawing.

## Verification

- Guided-tutorial tests assert a stable visual signature for each page.
- Existing high-contrast and 110% text checks keep every required prologue action visible.
- All three pages were captured and inspected at 1280×720.
- Application-shell and complete tutorial behavior remain unchanged.

## Remaining human question

Ask first-time players whether the prologue machine is recognizably the same fortress they later configure and whether the dependency overlay helps them predict the first placement lesson.
