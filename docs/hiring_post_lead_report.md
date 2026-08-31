# Hiring Post Lead Report

**Build:** `0.3.0-alpha.333`

## Player-facing change

Ashgate Depot's Hiring Post now identifies **Iven Pell** at the **Broken Relay** before the player chooses the first road. The card states every existing join condition:

- restore the Broken Relay;
- carry operational Crew Quarters;
- retain 12 Ashmarks;
- keep the single specialist berth empty.

It also states Iven's implemented contribution: exact immediate contacts, route-risk reduction up to 8 points, encounter-pressure reduction by 1, and 2 anti-storm damage.

Recruitment still happens only at Broken Relay after arrival. The Hiring Post takes no payment and exposes no duplicate recruitment action. If a retreat later returns an assigned Iven or Mara to Ashgate, the station replaces the obsolete rumor with that specialist's active contribution.

Lantern Quay remains honest: its local crews are committed to flood response and no verified specialist lead is posted there.

## Design boundary

This is a discovery and planning improvement, not a new character system. It uses the existing authored specialist identities, requirements, and effects so the player can prepare a route and chassis deliberately before encountering the real recruitment decision.

## Verification

Presenter coverage verifies the complete lead and assigned-specialist replacement. Settlement coverage verifies the 1280×720 card, absence of a premature action button, and continuation through the existing bazaar flow.

## Visual evidence

- [`Iven Pell Hiring Post lead`](visual_evidence/v0.3.0-alpha.333-hiring-post/02c_hiring_post.png)
