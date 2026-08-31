# Specialist Continuity

**Build:** `0.3.0-alpha.314`

## Purpose

Keep a recruited specialist visible as part of the fortress rather than letting the person vanish when the recruitment button is resolved.

## Implemented

- The route-planner specialist card now supports offer, locked, ready, and assigned states.
- Recruiting Iven leaves a visible receipt naming the 12-Ashmark cost and his forecast, route-risk, and storm-pressure contribution.
- Assigned Iven remains in later route planning as the signal officer, without another recruit action.
- Assigned Mara appears in route planning as the forge master, with her field and Morrowline repair contribution.
- Each specialist keeps a distinct code-native prop: Iven's relay mast and Mara's hammer.

## Boundaries

The card projects existing state only. It does not add a roster, second berth, relationship score, dialogue system, new specialist effect, or serialized field.

## Verification

- Presenter tests cover hidden, offer, assigned-Iven, and assigned-Mara projections without state mutation.
- Full-flow tests recruit Iven, verify the receipt and assigned card, restore the route state, and later verify Mara's assigned card after her workbench decision.
- 1280×720 captures confirm both assigned states fit the existing readiness/map/dossier layout.

## Remaining human question

Does retaining the specialist beside route information help players connect a forecast or repair advantage to the person who provides it?
