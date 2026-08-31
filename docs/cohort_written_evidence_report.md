# Cohort Written Evidence Report

**Build:** `0.3.0-alpha.329`

## Purpose

Automatic counts make cohort navigation comparable, but the private-alpha gate also depends on what testers actually said. The cohort report now places each session's written answers beside the automatic evidence without replacing them with generated interpretation.

## Report behavior

For every export, the report shows:

- what felt clear or satisfying;
- what felt confusing or frustrating;
- the tester's perceived cause and next-run change.

Responses remain in the same order as the command-line inputs, preserve line breaks, and appear as quoted text. Exports created before the causal prompt show `Not recorded` rather than inventing an answer.

## Interpretation boundary

The tool does not score correctness, infer sentiment, cluster themes, rewrite wording, or promote a response into a roadmap item. The observer still confirms the session conditions and records repeated failures in the human synthesis table.

## Verification

- Tests cover all three answers, multiline preservation, legacy missing answers, and the no-classification statement.
- The full offline and private-alpha verification contracts remain unchanged.
