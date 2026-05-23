# AppData Run Spec - Public

Session ID: APPDATA-DRYRUN-20260524
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
- Notes: AppData cache behavior depends more on installed applications and developer tools than OEM, but OEM context is kept for cross-run dataset consistency.

## Modules Covered

- `appdata`

## Scan Summary

- Public research rows: 11
- Estimated total scanned cache/store size: 532.47 MB
- SafeWithClosedApps rows: 5
- ReviewRequired rows: 5
- DoNotDelete rows: 1
- DeleteApproved: 0

## Largest Public Findings

- Local Temp: 412.36 MB
- Microsoft Office File Cache: 69.32 MB
- Edge Cache: 34.75 MB
- Outlook Offline Store: 16.04 MB, report-only

## Execution Summary

- Executed deletion: no
- WhatIf commands: 0
- Successful deletions: 0
- Failed deletions: 0
- Reboot verification: not needed
- Observed reclaimed size: 0 MB

## Public Case Notes

This is an analyze-only AppData session. The scan found plausible future cleanup
targets in local temp, Office cache, and browser cache, but no deletion path exists
in M3. Outlook mail stores are explicitly classified as `DoNotDelete`.

## Privacy Checklist

- [x] No local AppData paths
- [x] No username, computer name, serial number, or exact local path
- [x] No file names from private profile data
- [x] No browser profile contents
- [x] No mail file names

