---
name: long-march-content-reviewer
description: Review The Long March narrative and content changes for mechanical truth, continuity, meaningful choice, regional identity, UI fit, accessibility, and generic AI-like writing. Use for content or PR review and the final anti-slop pass in this repository; report findings by default and rewrite only when explicitly asked.
---

# Long March Content Reviewer

Review as both a systems editor and a skeptical player. The copy must tell the truth about the game, preserve a real decision, fit its interface, and sound as though it could only belong to The Long March.

## Establish scope and evidence

1. Identify the changed copy, the UI surface that displays it, and the state or command that owns its claimed behavior.
2. Read `AGENTS.md`, `design/design_prompt.md`, the relevant gameplay/world design section, adjacent copy, and focused tests.
3. Trace every named cost, requirement, effect, consequence, and callback to evidence.
4. Use this authority order when sources disagree: state and commands, focused content data, presenter behavior, repository design intent, then prose.
5. Distinguish automated evidence from human observation. Never claim that text is clear, comfortable, or emotionally effective because a test passed.

Use [the review rubric](references/review-rubric.md) for a full pass and [the continuity checklist](references/continuity-checklist.md) for people, places, promises, and saves.

## Review in this order

### 1. Mechanical truth

Confirm that copy exposes the real price before commitment, names only implemented behavior, and matches requirements, effects, timing, targets, and failure handling. Check the result receipt and later callback rather than reviewing the setup alone.

### 2. Player choice

Confirm each option protects something and endangers something. Reject false choices, disguised optimal answers, hidden irreversible costs, and options whose prose differs while their actual result does not.

### 3. Continuity and causality

Check stable IDs, region, location, character capability and limitation, obligation state, prior decisions, ending facet, save/load behavior, and Debrief memory. The world should remember through a changed road, service, shortage, refuge, relationship, or ending—not a detached flavor line.

### 4. Voice and specificity

Ask whether the passage could be pasted into another post-apocalyptic game unchanged. Flag:

- abstract stakes without a physical object or action;
- “ancient secrets,” “echoes of the past,” “a glimmer of hope,” or similar stock language;
- slogan-like three-part cadences and repeated “not just X, but Y” constructions;
- decorative sensory details that the viewpoint could not observe;
- everyone speaking with the same polished, explanatory voice;
- character emotion asserted without pressure, behavior, or consequence;
- exposition that postpones the decision instead of sharpening it.

Do not demand grimness. Warmth, humor, quiet, and relief belong when they emerge from work, familiarity, or a kept promise.

### 5. Interface and accessibility

Check text density, wrapping, focus labels, casing, repeated information, controller parity, large-text layouts, contrast-independent status language, and reduced-motion alternatives. Exact costs belong in stable structured fields when available. A title or button must remain useful outside its surrounding paragraph.

## Classify findings

- **Blocker:** The text lies about mechanics, permits an impossible state, hides an irreversible cost, breaks a stable ID/save contract, or removes the player's only viable recovery.
- **Concern:** The choice is strategically hollow; causality or regional identity is unclear; prose is generic, repetitive, tonally false, or likely to overload its UI.
- **Nit:** A localized wording, punctuation, casing, or rhythm issue with no meaningful comprehension risk.

Report findings first, ordered by severity. For each finding, provide a file and line, the claimed player-facing behavior, the conflicting evidence or concrete prose problem, and the smallest correction. Do not rewrite the passage unless asked. If no findings remain, say so plainly and list residual risks, especially any judgment that requires human play observation.

End substantive reviews with a brief coverage record: mechanics traced, continuity sources checked, UI states considered, automated checks run, and human validation still needed.
