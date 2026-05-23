# DriverStore Inventory Run Spec - Public

Session ID: DRIVERSTORE-INVENTORY-20260524
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
- Notes: DriverStore inventory can be strongly affected by GPU, audio, wireless,
  and OEM system-extension packages.

## Modules Covered

- `driverstore`

## DriverStore Scan Summary

- Conservative duplicate cleanup candidates: 0
- Top-level FileRepository inventory rows: 40
- Top-level FileRepository inventory total: 4,838.89 MB
- DeleteApproved: 0

## Top Folder Size Summary

These rows keep `OriginalName` public for research, but redact the full
FileRepository folder name, hash suffix, local path, and `PublishedName`.

| Public inventory ID | OriginalName | Architecture | Estimated size |
|---|---|---|---:|
| DRVSTORE-TOP-0001 | `nvltwi.inf` | amd64 | 2,554.15 MB |
| DRVSTORE-TOP-0002 | `iigd_dch.inf` | amd64 | 1,279.15 MB |
| DRVSTORE-TOP-0003 | `hdxlvj.inf` | amd64 | 169.34 MB |
| DRVSTORE-TOP-0004 | `hdxlvj.inf` | amd64 | 156.60 MB |
| DRVSTORE-TOP-0005 | `synpd.inf` | amd64 | 72.73 MB |
| DRVSTORE-TOP-0006 | `cnlb0ma64.inf` | amd64 | 63.82 MB |
| DRVSTORE-TOP-0007 | `fn.inf` | amd64 | 44.97 MB |
| DRVSTORE-TOP-0008 | `rtlejf.inf` | amd64 | 43.14 MB |

## Correction Note

The earlier DriverStore report described duplicate-driver cleanup candidates. It
did not publish a TreeSize-like `FileRepository` inventory. This session adds that
inventory layer so reports can distinguish:

- cleanup candidates: packages that passed conservative duplicate rules,
- research targets: large package folders that need device binding and vendor
  evidence before any cleanup decision.

## Execution Summary

- Executed deletion: no
- WhatIf commands: 0
- Successful deletions: 0
- Failed deletions: 0
- Reboot verification: not needed
- Observed reclaimed size: 0 MB

## Public Case Notes

The public top-level inventory exposes `OriginalName` because it is required for
research. Driver package folder hashes, local paths, and `PublishedName` remain
private. The private inventory keeps folder names and local paths for local
diagnosis.

## Privacy Checklist

- [x] No `oemXX.inf`
- [x] No raw `pnputil` output
- [x] No username, computer name, serial number, or exact local path
- [x] No local DriverStore paths
- [x] Top-level FileRepository folder names redacted in public inventory
