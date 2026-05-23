# Candidate Schema

Public candidate rows describe storage cleanup opportunities without exposing local
machine-private identifiers.

## Public Columns

```text
SessionId
Module
ResearchId
ItemName
ItemType
EstimatedSizeBytes
RiskLevel
CleanupMethod
ResearchStatus
Assessment
EvidenceUrl1
EvidenceUrl2
DeleteApproved
PublicNotes
```

## Private Mapping Columns

Private files may contain local execution details and must be git-ignored:

```text
ResearchId
LocalPathOrId
ExactCommand
PreState
PostState
PrivateNotes
```

## Assessment Values

```text
OutdatedDuplicate
CacheSafe
SafeWithClosedApps
LegacyKeep
UnknownKeep
DoNotDelete
ExplainOnly
```

Unknown evidence defaults to keep.

