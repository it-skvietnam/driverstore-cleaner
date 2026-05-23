# DriverStore Cleaner PR

## Type

- [ ] Agent scan contribution
- [ ] Driver research contribution
- [ ] Tooling/script change
- [ ] Documentation change
- [ ] Other

## Summary

Describe what this PR contributes.

## What Was Done

Explain the actual work performed. Include commands or workflow steps at a high
level, but do not paste private raw output.

- Analyze run:
- Research run:
- Dry-run:
- Execute deletion:
- Report generation:

## Public Information Added

List the public-safe files or data added by this PR.

- Public run spec:
- Public research CSV:
- Public summary/case study:
- Documentation/tooling changes:

## Private Information Kept Local

Confirm what was generated but intentionally not committed.

- Raw `pnputil` output:
- Full driver inventory:
- Private review CSV:
- Merged execution CSV:
- Logs/audit files:

## Special Findings

Call out anything unusual or scientifically useful. Examples:

- OEM/model-specific driver behavior
- Windows generation differences
- Legacy driver risk
- Risky duplicate group
- Driver family that looks removable but should be kept
- Evidence that a generic vendor driver is not enough

## Public Run Spec

For scan/research PRs, link the required file:

```text
reports/sessions/<session-id>/driverstore-run-spec-public.md
```

## Research Note

For scan/research PRs, link the required append-only research note:

```text
research-notes/YYYY-MM-DD-<session-id>-<agent-tool>.md
```

Agent declaration:

- Agent tool:
- Agent model:
- Operator:

## Safety

- [ ] I did not commit private reports or raw driver inventory.
- [ ] I did not commit `ResearchId -> PublishedName/oemXX.inf` mapping.
- [ ] I did not include usernames, computer names, serial numbers, or exact local paths.
- [ ] I did not claim deletion approval without evidence.
- [ ] I ran `tools\Test-AgentContribution.ps1`.

## Research Outcome

- Reviewed:
- OutdatedDuplicate:
- LegacyKeep:
- UnknownKeep:
- PendingResearch:
- DeleteApproved:
- Deleted:

## Evidence Notes

List official sources used where possible.

## Dataset / Tooling Value

Explain how this PR improves the future dataset or TreeSize-like scanner. Examples:

- Adds a new OEM/model family.
- Adds a new Windows generation.
- Adds a risky-driver classification example.
- Improves privacy validation.
- Improves report quality.
- Finds a repeatable cleanup candidate pattern.
