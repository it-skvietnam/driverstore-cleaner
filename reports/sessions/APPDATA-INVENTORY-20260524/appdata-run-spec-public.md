# AppData Inventory Run Spec - Public

Session ID: APPDATA-INVENTORY-20260524
Date: 2026-05-24
Mode: Analyze
Agent: Codex

## Windows Context

- Windows generation: Windows 11
- Windows release: unknown
- Build family: unknown
- Architecture: x64

## Machine Context

- OEM: Lenovo
- Machine family: ThinkPad
- Model line: ThinkPad, exact line not published
- Exact model number: not published
- Device role: laptop
- Notes: AppData inventory is dominated by installed applications and developer tools; OEM context is retained for dataset consistency.

## Modules Covered

- `appdata`

## Scan Summary

- Known cache policy rows: 11
- Known cache policy total: 532.47 MB
- Top-level LocalAppData inventory rows: 40
- Top-level LocalAppData inventory total: 14,614.17 MB
- DeleteApproved: 0

## Top Folder Size Summary

These rows are redacted to match the public CSV. The private CSV contains the
actual folder names for local TreeSize comparison.

| Public inventory ID | Public item name | Estimated size |
|---|---|---:|
| LOCALTOP-0001 | LocalAppData top-level #01 | 3,607.85 MB |
| LOCALTOP-0002 | LocalAppData top-level #02 | 3,585.11 MB |
| LOCALTOP-0003 | LocalAppData top-level #03 | 1,367.38 MB |
| LOCALTOP-0004 | LocalAppData top-level #04 | 696.14 MB |
| LOCALTOP-0005 | LocalAppData top-level #05 | 640.71 MB |
| LOCALTOP-0006 | LocalAppData top-level #06 | 585.89 MB |
| LOCALTOP-0007 | LocalAppData top-level #07 | 536.76 MB |
| LOCALTOP-0008 | LocalAppData top-level #08 | 533.43 MB |

## Correction Note

The earlier AppData dry-run only reported known cache policy paths. That was not a
full `%LOCALAPPDATA%` inventory and understated the visible TreeSize-style footprint.
This session adds a top-level inventory layer so reports can distinguish:

- cache-policy shortlist: known cache/store paths that may have future cleanup rules,
- top-level inventory: TreeSize-like folder size report used for discovery and
  prioritization.

## Execution Summary

- Executed deletion: no
- WhatIf commands: 0
- Successful deletions: 0
- Failed deletions: 0
- Reboot verification: not needed
- Observed reclaimed size: 0 MB

## Public Case Notes

The public top-level inventory redacts folder names by default, because installed
application names can fingerprint a user. The private inventory keeps folder names
and local paths for local diagnosis.

## Privacy Checklist

- [x] No local AppData paths
- [x] No username, computer name, serial number, or exact local path
- [x] No file names from private profile data
- [x] No browser profile contents
- [x] No mail file names
- [x] Top-level folder names redacted in public inventory
