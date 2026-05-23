# DriverStore Module

The DriverStore module researches and removes stale Windows driver packages using
Windows-supported APIs only.

## Safety Rules

- Never delete from `C:\Windows\System32\DriverStore\FileRepository` directly.
- Analyze uses `pnputil /enum-drivers`.
- Removal uses `pnputil /delete-driver <oemXX.inf> /uninstall`.
- `/force` requires explicit approval.
- Risky classes are excluded from default candidates.

## Scripts

```text
Analyze-DriverStore.ps1
Research-DriverCandidates.ps1
Merge-DriverResearchReview.ps1
Remove-DriverStoreCandidates.ps1
```

Root-level scripts are compatibility wrappers for these module scripts.

## Default Policy

```text
Module: driverstore
DefaultRisk: ReviewRequired
SupportedAnalyze: yes
SupportedResearch: yes
SupportedWhatIf: yes
SupportedExecute: yes, gated
AllowedCleanupMethods: pnputil
ForbiddenCleanupMethods: manual file deletion
```

