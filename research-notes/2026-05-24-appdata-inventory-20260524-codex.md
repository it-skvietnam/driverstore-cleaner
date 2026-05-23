# Research Note

Entry ID: RN-2026-05-24-APPDATA-INVENTORY-20260524-CODEX
Date: 2026-05-24
Session ID: APPDATA-INVENTORY-20260524

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

- `appdata`

## Public Files

- Public run spec: `reports/sessions/APPDATA-INVENTORY-20260524/appdata-run-spec-public.md`
- Public research CSV: `reports/sessions/APPDATA-INVENTORY-20260524/appdata-research-public.csv`
- Public top-level inventory CSV: `reports/sessions/APPDATA-INVENTORY-20260524/appdata-localtop-public.csv`
- Public Microsoft subtree research:
  `reports/sessions/APPDATA-INVENTORY-20260524/appdata-microsoft-subtree-research-public.md`

## What Was Done

The agent corrected the AppData analyzer by adding a TreeSize-like top-level
`%LOCALAPPDATA%` inventory. The known-cache research CSV remains, but it is no
longer presented as the full AppData footprint.

## What Was Learned

The known-cache shortlist was about 532.47 MB, while the top-level LocalAppData
inventory was about 14,613.50 MB. This shows that AppData research needs both a
policy shortlist and a broad inventory layer. The broad inventory is discovery data,
not a cleanup candidate list.

Top public size rows for TreeSize comparison:

| Public inventory ID | ItemName | Estimated size |
|---|---|---:|
| LOCALTOP-0001 | Microsoft | 3,607.85 MB |
| LOCALTOP-0002 | wsl | 3,585.11 MB |
| LOCALTOP-0003 | Mozilla | 1,366.71 MB |
| LOCALTOP-0004 | OpenAI | 696.14 MB |
| LOCALTOP-0005 | GitHubDesktop | 640.71 MB |
| LOCALTOP-0006 | BraveSoftware | 585.89 MB |
| LOCALTOP-0007 | Postman | 536.76 MB |
| LOCALTOP-0008 | Programs | 533.43 MB |

## Special Notes

Public inventory exposes top-level folder/product names because anonymous ranks are
not researchable. Local paths and user-specific file names remain private.

## Privacy Review

- [x] No `oemXX.inf`
- [x] No raw `pnputil` output
- [x] No username, computer name, serial number, or exact local path
- [x] No private mapping
- [x] No local AppData paths
- [x] No private browser or mail filenames
- [x] Public top-level folder names are redacted

## Correction Policy

This note corrects the interpretation of `RN-2026-05-24-APPDATA-DRYRUN-20260524-CODEX`.
The earlier session was a cache-policy shortlist, not a TreeSize-like AppData
inventory.

The obsolete `APPDATA-DRYRUN-20260524` public artifacts should not remain tracked
because they are superseded by this inventory session and can mislead readers into
thinking the AppData footprint is only the known-cache shortlist.
