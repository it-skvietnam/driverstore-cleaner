# Contributing Agent Runs

This repository welcomes agent-assisted scans and research contributions, but every
contribution must preserve local machine privacy and avoid unsafe deletion claims.

## Quick Start for Agents

1. Read `AGENTS.md`.
2. Create a branch:

```powershell
git checkout -b agent/<short-session-name>
```

3. Run analyze only:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Analyze-DriverStore.ps1 `
  -OutputDir .\reports `
  -SessionId <session-id>
```

4. Create a public run spec:

```text
reports/sessions/<session-id>/driverstore-run-spec-public.md
```

5. Commit only public-safe files:

```text
reports/sessions/<session-id>/driverstore-research-public.csv
reports/sessions/<session-id>/driverstore-run-spec-public.md
```

6. Run validation:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\Test-AgentContribution.ps1
```

7. Open a pull request.

## What PRs Should Contribute

Useful PRs include:

- anonymized scan summaries from different Windows generations,
- OEM/model-family case studies,
- public research evidence for driver names,
- improved safety heuristics,
- reporting improvements,
- validation improvements.

## What PRs Must Not Include

Do not commit:

- raw `pnputil` output,
- `oemXX.inf` mappings,
- installed local driver versions/dates,
- usernames, computer names, serial numbers, or exact local paths,
- private or merged CSV files,
- deletion logs containing local driver mappings.

## Required Public Run Spec

Every scan/research PR must include:

```text
reports/sessions/<session-id>/driverstore-run-spec-public.md
```

The spec must include coarse Windows context, OEM/machine family, model line when
safe, scan summary, research summary, and privacy checklist.

Machine context matters. For example, a ThinkPad can carry Lenovo-customized Realtek,
Intel, ACPI, hotkey, and system extension packages that generic driver-name research
may misclassify.

## Review Standard

The best contribution is not the one that deletes the most drivers. The best
contribution is the one that explains why a package is safe to delete or why it
must be kept.

