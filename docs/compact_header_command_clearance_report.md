# Compact Header and Contact-Command Clearance

**Build:** `0.3.0-alpha.347`

## Problem

Fresh 1280×720 captures with 110% text, high contrast, reduced motion, and alternate controller labels exposed two presentation defects. The transient autosave receipt occupied the same horizontal space as contact and arrival breadcrumbs, and the bottom row of emergency orders was only partially visible in the contact dock.

## Change

- The autosave receipt now tracks the active surface after layout settles and occupies the free header lane immediately before Pause, or before the battle-phase badge during contact.
- Contact-dock spacing and fixed control heights were reduced modestly without removing threat, response, or intervention information.
- The pre-target intervention guidance was shortened while preserving its timing warning, pointer/focus instruction, and named seal target.

The simulation, save timing, contact resolution, intervention count, and focus order are unchanged.

## Verification

- The application-shell regression checks that a 110%-text receipt moves into the right side of the route header while retaining clearance from Pause.
- The complete-journey compact profile checks that contact receipts clear both breadcrumb and phase badge, arrival receipts clear their breadcrumb, and all four emergency-order buttons are inside the visible contact surface.
- Fresh standard and compact screenshots are stored in [`v0.3.0-alpha.347-header-command-clearance-1600x900`](visual_evidence/v0.3.0-alpha.347-header-command-clearance-1600x900/) and [`v0.3.0-alpha.347-header-command-clearance-1280x720`](visual_evidence/v0.3.0-alpha.347-header-command-clearance-1280x720/).

## Boundary

The captures establish geometric clearance and readable action availability. They do not establish whether an uncoached player notices the receipt, understands the contact options, or prefers the density.
