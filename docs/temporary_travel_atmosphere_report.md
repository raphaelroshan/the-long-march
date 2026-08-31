# Temporary Travel Atmosphere Pass

**Build:** `0.3.0-alpha.301`

## Purpose

Make the side-on march read as a physical journey rather than one uniformly moving illustration, while preserving the exact route commitment, contact, save, and simulation behavior.

## Implemented

- Split the road presentation into three visual motion profiles: gathering departure, full march, and static contact brace.
- Slowed scenery at departure, used full parallax speed during the march, and stopped travel motion when the named contact appears.
- Added a subtle mechanical bob only during full march.
- Added tinted CC0 smoke frames as temporary Ashgate dust or Veyru road mist, plus restrained foreground speed lines.
- Clipped the center canvas so travel effects cannot bleed into the receipt or decision columns.
- Reset presentation motion for every configured journey so captures and resumed routes begin from a stable visual state.
- Kept Tiny Town out of the build because its cheerful pixel style conflicts with the fortress presentation.

## Boundaries

The effect reads already-committed presentation state only. It does not advance time, spend fuel, select threats, resolve contact, alter random streams, or enter the destination. Reduced motion skips directly to the static contact brace and does not draw the temporary travel effect. Pausing stops processing through the existing scene-tree pause behavior.

## Verification

- Settlement journey coverage asserts all three motion profiles, active-march movement, atmosphere timing, and contact deceleration.
- Complete-journey accessibility coverage asserts the reduced-motion profile is static and effect-free.
- Full repository verification and responsive profiles remain required before merge.
- Evidence: [`v0.3.0-alpha.301 temporary travel atmosphere`](visual_evidence/v0.3.0-alpha.301-temporary-travel-atmosphere/).

## Remaining validation

The temporary dust is useful for timing and legibility tests, not final art. Human sessions should determine whether the march feels weighty enough, whether the one-second staging is too quick, and whether the contact brace creates a clear change in attention without reading as an attack animation.
