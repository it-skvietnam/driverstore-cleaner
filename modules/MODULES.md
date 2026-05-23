# Module Registry

Windows Storage Research Cleaner modules share the same lifecycle:

```text
Analyze -> Research -> Merge private/public evidence -> WhatIf -> Execute -> Report
```

No module should delete data during analyze or research.

## Active Modules

| Module | Status | Default action | Notes |
|---|---|---|---|
| `driverstore` | Active | `ReviewRequired` | Uses `pnputil`; never delete files from DriverStore directly. |

## Planned Modules

| Module | Status | Default action | Notes |
|---|---|---|---|
| `winsxs` | Planned | `ExplainOnly` | Use DISM/Storage Sense only. |
| `appdata` | Planned | `SafeWithClosedApps` / `ReviewRequired` | Cache-oriented, never profile-wide blind delete. |
| `office-outlook` | Planned | `ReviewRequired` | Office cache may be cleanable; Outlook OST is `DoNotDelete`. |
| `browser-cache` | Planned | `SafeWithClosedApps` | Cache only, not profiles/passwords/session data. |
| `dev-cache` | Planned | `ReviewRequired` | npm, pip, NuGet, Gradle, package-manager-specific cleanup. |
| `wsl-docker` | Planned | `HighRisk` | Prune/compact only with explicit approval. |
| `restore-points` | Planned | `HighRisk` | Report and resize only with explicit approval. |
| `windows-update` | Planned | `ReviewRequired` | Service-aware cleanup only. |

## Risk Taxonomy

| Risk | Meaning |
|---|---|
| `SafeAuto` | Can be cleaned automatically after analysis. Rare. |
| `SafeWithClosedApps` | Cleanable only when affected apps are closed. |
| `ReviewRequired` | Needs human or agent evidence review. |
| `HighRisk` | May affect rollback, dev environments, or device function. |
| `DoNotDelete` | Report only; deletion is not part of this workflow. |
| `ExplainOnly` | Use supported OS tooling; do not manually remove. |

