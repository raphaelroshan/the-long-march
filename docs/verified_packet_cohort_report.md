# Verified Packet Cohort Review

**Build:** `0.3.0-alpha.346`

## Problem

Individual session packets preserve the observer/export pairing, but the older cohort command accepted loose JSON exports. Returning to loose files during synthesis could count one export twice, lose the embedded session number, or separate automatic evidence from its human notes.

## Implemented contract

`tools/summarize_playtest_packets.py` now:

- reverifies each packet's hashes, retained release manifest, observer provenance, feedback build, session number, run code, and explicit human-owned non-claims;
- rejects duplicate session numbers and identical feedback exports;
- sorts valid packets by the embedded session number rather than filename or argument order;
- records full observer and feedback SHA-256 values without copying machine paths;
- passes the verified exports into the existing navigation, outcome, and tester-answer review;
- keeps the original session labels in automatic and human-validation rows;
- does not copy, classify, quote, or summarize observer prose; and
- creates the cohort Markdown exclusively, refusing an existing output.

The loose-export tool remains compatible with older evidence, but the private-alpha guide now makes verified packets the primary path.

## Evidence

`tests/test_playtest_packet_cohort.py` covers out-of-order packets, stable session labels, omitted observer prose, duplicate packet input, repeated feedback, and changed packet rejection. Existing cohort tests cover custom labels and preserve the legacy command contract. Both platform manifests checksum the new tool and every dependency it imports.

## Boundary

A collection of five valid packets is only ready for human synthesis. It does not prove consent, unique participants, uncoached conditions, comprehension, severity, or a passed quality gate. Reviewers must read each paired `observer.md`, complete the validation rows, and cite repeated observable failures before changing the roadmap.
