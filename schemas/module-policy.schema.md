# Module Policy Schema

Each module should document:

```text
Module:
DefaultRisk:
SupportedAnalyze:
SupportedResearch:
SupportedWhatIf:
SupportedExecute:
AllowedCleanupMethods:
ForbiddenCleanupMethods:
PrivateArtifacts:
PublicArtifacts:
Preconditions:
RecoveryNotes:
```

## Cleanup Method Examples

```text
pnputil
DISM
StorageSense
DeleteCacheFolder
PackageManagerClean
DockerPrune
WslCompact
VssadminResize
ExplainOnly
```

Cleanup methods must be module-specific and auditable.

