# Research Note

Entry ID: RN-2026-05-24-DRIVERSTORE-INVENTORY-20260524-CODEX
Date: 2026-05-24
Session ID: DRIVERSTORE-INVENTORY-20260524

## Agent Declaration

- Agent tool: Codex
- Agent model: GPT-5
- Operator: local human operator
- Run mode: Analyze

## Machine Context

- Windows generation: Windows 11
- Windows release: unknown
- Architecture: x64
- OEM: Lenovo
- Machine family: ThinkPad
- Model line: ThinkPad, exact line not published
- Exact model number: not published
- Device role: laptop

## Modules Covered

- `driverstore`

## Public Files

- Public run spec: `reports/sessions/DRIVERSTORE-INVENTORY-20260524/driverstore-run-spec-public.md`
- Public research CSV: `reports/sessions/DRIVERSTORE-INVENTORY-20260524/driverstore-research-public.csv`
- Public top-level inventory CSV: `reports/sessions/DRIVERSTORE-INVENTORY-20260524/driverstore-filerepository-top-public.csv`

## What Was Done

The agent corrected the DriverStore analyzer by adding a TreeSize-like top-level
`FileRepository` inventory. The duplicate-driver research CSV remains, but it is no
longer presented as the full DriverStore storage footprint.

## What Was Learned

The conservative duplicate cleanup rule produced 0 deletion candidates, while the
top-level FileRepository inventory measured about 4,838.89 MB across the top 40
folders. This shows that DriverStore research needs both a gated cleanup-candidate
layer and a broad inventory layer.

The broad inventory is discovery data, not a deletion list. Large GPU or audio
driver folders can be normal and may still be bound to active devices or OEM
customizations.

Top public size rows for TreeSize comparison and web research:

| Public inventory ID | OriginalName | Estimated size |
|---|---|---:|
| DRVSTORE-TOP-0001 | `nvltwi.inf` | 2,554.15 MB |
| DRVSTORE-TOP-0002 | `iigd_dch.inf` | 1,279.15 MB |
| DRVSTORE-TOP-0003 | `hdxlvj.inf` | 169.34 MB |
| DRVSTORE-TOP-0004 | `hdxlvj.inf` | 156.60 MB |
| DRVSTORE-TOP-0005 | `synpd.inf` | 72.73 MB |
| DRVSTORE-TOP-0006 | `cnlb0ma64.inf` | 63.82 MB |
| DRVSTORE-TOP-0007 | `fn.inf` | 44.97 MB |
| DRVSTORE-TOP-0008 | `rtlejf.inf` | 43.14 MB |

## Special Notes

Public inventory exposes `OriginalName` because anonymous ranks are not researchable.
The full FileRepository folder name, hash suffix, local path, and `PublishedName`
remain private.

## Privacy Review

- [x] No `oemXX.inf`
- [x] No raw `pnputil` output
- [x] No username, computer name, serial number, or exact local path
- [x] No private mapping
- [x] No local DriverStore paths
- [x] Public top-level folder names are redacted

## Correction Policy

This note corrects the interpretation of `RN-2026-05-23-POC-DRYRUN-20260523-CODEX`.
The earlier session was a conservative duplicate-candidate report, not a
TreeSize-like DriverStore inventory.
