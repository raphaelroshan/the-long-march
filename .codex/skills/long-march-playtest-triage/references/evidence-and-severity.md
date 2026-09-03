# Evidence and severity

## Evidence rules

- Quote observer notes and tester statements exactly; do not repair grammar inside quotations.
- Link every telemetry claim to the matching feedback export and ordered event trail.
- Use telemetry to confirm what occurred, never why it occurred.
- Keep participant identity pseudonymous and do not commit raw packets or personal information.
- Record contradictions. A tester may say they inspected a target while the event trail shows no inspection; neither source should be silently discarded.

## Severity

- **S0 — safety or data integrity:** consent, privacy, save corruption, destructive action, or inaccessible required control.
- **S1 — blocked progress:** the tester cannot continue without coaching or repeatedly enters a dead end.
- **S2 — wrong irreversible choice:** the tester acts on a false understanding of cost, target, route, or persistence.
- **S3 — misunderstood consequence:** the tester completes the step but cannot explain what changed or why.
- **S4 — slow discovery:** the correct path is eventually found without coaching but creates avoidable delay or repeated backtracking.
- **S5 — preference:** aesthetic or comfort feedback without a demonstrated task failure.

Prioritize severity first, then recurrence, then breadth across input/display profiles. Do not average away one S0 or S1 finding.

## Narrow issue format

```text
Observed failure:
Evidence:
Affected phase and artifact:
Reproduction:
Smallest proposed change:
Acceptance evidence:
Rejected broader changes:
Human confirmation still required:
```

An acceptance test should prove the intended state, input, or geometry. Only another uncoached session can prove that the change improved comprehension.
