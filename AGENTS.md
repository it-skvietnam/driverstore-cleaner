# AGENTS.md - DriverStore Cleaner

> Read this file before doing any task in this repository.
> This project handles Windows driver inventory. Treat local driver data as private
> unless a file is explicitly marked public/anonymized.

---

## 0. Project Goal

DriverStore Cleaner is a proof-of-concept workflow for researching and safely
removing stale Windows DriverStore packages. The long-term goal is to collect enough
anonymized, evidence-backed driver cleanup cases to support:

- a scientific-style dataset about DriverStore bloat and cleanup safety,
- a safer cleanup workflow than manual guessing,
- a tool that can scan and explain DriverStore usage with TreeSize-like clarity,
- optimization rules that respect Windows version, OEM model family, and legacy
  device dependencies.

The project is not a blind deletion tool. Research quality and privacy are part of
the product.

---

## 1. Startup Protocol

Every agent session starts with:

```powershell
Get-Content README.md
Get-Content AGENTS.md
Get-Content .gitignore
git status --short -uall --ignored
```

If the task touches a previous run, inspect only the public report first:

```powershell
Get-ChildItem .\reports\sessions -Recurse -Filter driverstore-research-public.csv
```

Do not open private reports unless the human asks for local diagnosis or execution.

Private by default:

- `reports\driverstore-raw.txt`
- `reports\driverstore-all.csv`
- `reports\driverstore-candidates.csv`
- `reports\driverstore-research-review.csv`
- `reports\sessions\*\driverstore-research-private.csv`
- `reports\sessions\*\driverstore-research-merged.csv`
- `docs\private\`
- any file containing `ResearchId -> PublishedName/oemXX.inf`

Public by default:

- source code,
- README and public docs,
- mock test fixtures,
- `reports\sessions\*\driverstore-research-public.csv`,
- public summaries containing only aggregate metrics and anonymized `ResearchId`.

---

## 2. Non-Negotiable Safety Rules

- Never delete files directly from `C:\Windows\System32\DriverStore\FileRepository`.
- Removal must use `pnputil /delete-driver <oemXX.inf> /uninstall`.
- Do not use `/force` unless the human explicitly approves it for a specific row.
- Do not run `Remove-DriverStoreCandidates.ps1 -Execute` without explicit human
  approval in the current conversation.
- Always run `-WhatIf` before any real execute.
- Unknown evidence means keep. Use `UnknownKeep`, not deletion.
- Legacy-looking evidence means keep. Use `LegacyKeep`, not deletion.
- Do not publish `oemXX.inf`, installed driver versions/dates, class inventory,
  signer names, usernames, computer names, serial numbers, or raw `pnputil` output.

---

## 3. Required Agent Workflow

For analyze/research tasks:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Analyze-DriverStore.ps1 -OutputDir .\reports -SessionId <session-id>
```

Then inspect the public/private split:

```powershell
Get-ChildItem .\reports\sessions\<session-id>
```

For research tasks:

1. Use the public research CSV first.
2. Research official sources before community sources.
3. Fill evidence fields.
4. Merge public research back into the private file only when local execution is
   needed.
5. Run dry-run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Remove-DriverStoreCandidates.ps1 `
  -CandidatesCsv .\reports\sessions\<session-id>\driverstore-research-merged.csv `
  -WhatIf
```

For deletion tasks:

1. Confirm human explicitly approved deletion.
2. Confirm the row has `WebResearchStatus=Reviewed`.
3. Confirm `DriverAssessment=OutdatedDuplicate`.
4. Confirm `DeleteApproved=TRUE`.
5. Confirm at least one evidence URL exists.
6. Run `-WhatIf`.
7. Run `-Execute` only after the approval.
8. Generate public and private reports.

---

## 4. PR Requirement: Public Run Spec

Any PR that contributes scan/research data must include one public run spec file.
This file is required even if no driver is deleted.

Path format:

```text
reports/sessions/<session-id>/driverstore-run-spec-public.md
```

This file must not include serial numbers, usernames, computer names, exact local
paths, `oemXX.inf`, raw `pnputil` output, or private mapping data.

Use this template:

```markdown
# DriverStore Run Spec - Public

Session ID:
Date:
Mode: Analyze | WhatIf | Execute
Agent:

## Windows Context

- Windows generation: Windows 10 | Windows 11 | Windows Server
- Windows release: 22H2 | 23H2 | 24H2 | unknown
- Build family: optional, coarse only
- Architecture: x64 | arm64 | unknown

## Machine Context

- OEM: Lenovo | Dell | HP | ASUS | Acer | Microsoft | Custom | Unknown
- Machine family: ThinkPad | ThinkCentre | Latitude | Precision | Pavilion | etc.
- Model line: ThinkPad T14 Gen 2 | X1 Carbon Gen 9 | unknown
- Exact model number: optional, public only if human approves
- Device role: laptop | desktop | workstation | mini PC | VM | unknown
- Notes: include why OEM context matters for this run

## DriverStore Scan Summary

- Total third-party driver packages:
- Duplicate driver-name groups:
- Default safe candidates:
- Risky-class duplicate groups:
- Public research rows:

## Research Summary

- Reviewed:
- OutdatedDuplicate:
- LegacyKeep:
- UnknownKeep:
- PendingResearch:
- DeleteApproved:

## Execution Summary

- Executed deletion: yes | no
- WhatIf commands:
- Successful deletions:
- Failed deletions:
- Reboot verification: not needed | pending | completed
- Observed reclaimed size: unknown | value

## Public Case Notes

Describe the public learning from this run. Mention OEM/model-generation constraints
when relevant. Example: ThinkPad audio drivers may be Lenovo-customized, so Realtek
INF duplicates should not be treated like generic Realtek packages without exact
model support evidence.

## Privacy Checklist

- [ ] No `oemXX.inf`
- [ ] No raw `pnputil` output
- [ ] No installed driver version/date from the local machine
- [ ] No username, computer name, serial number, or local path
- [ ] No `ResearchId -> PublishedName` mapping
- [ ] Public evidence URLs only
```

Why this file matters:

- Windows generation changes driver behavior and support status.
- OEM machine family matters because vendors customize packages.
- A Lenovo ThinkPad can legitimately carry Lenovo-specific Realtek, Intel, ACPI,
  hotkey, and system extension drivers that generic research would misclassify.
- A dataset without machine context cannot become a serious research artifact.

## 4.1 PR Requirement: Narrative Explanation

Every PR must explain what happened, not only attach CSV files. Include:

- What the agent ran: analyze, research, dry-run, execute, docs, or tooling.
- What public information was added.
- What private information was intentionally kept local.
- What is special about this run: Windows generation, OEM, machine family, model
  line, risky driver family, legacy package, or odd duplicate pattern.
- What the result contributes to the dataset or future TreeSize-like scanner.

Negative results are valid. If no driver was deleted, explain why that is useful:
for example, the run may show that a ThinkPad audio package is OEM-specific and
should not be treated as a generic Realtek duplicate.

## 4.2 PR Requirement: Research Note Ledger Entry

Every scan/research PR must add one new public research note under:

```text
research-notes/YYYY-MM-DD-<session-id>-<agent-tool>.md
```

Use `research-notes/TEMPLATE.md`.

Required declarations:

- Agent tool, such as Codex, Claude Code, Cursor, Aider, or Human.
- Agent model, such as GPT-5, Claude Sonnet, or unknown.
- Operator, as a public handle or `anonymous`.
- Session ID.
- Windows generation/release.
- OEM, machine family, and model line.
- Public files contributed.
- What was done and what was learned.

Research notes are append-only. Do not delete or rewrite older notes. If an old note
is wrong, add a new correction note and reference the old entry ID.

---

## 5. Research Evidence Rules

Evidence priority:

1. Exact OEM model support page.
2. Hardware vendor support/download page.
3. Microsoft Update Catalog as supporting evidence.
4. Release notes or official package metadata.
5. Community/forum posts only for legacy-risk clues.

Driver assessment values:

- `OutdatedDuplicate`: evidence shows the package is an old duplicate and a newer
  matching package remains available.
- `LegacyKeep`: the package is old but likely supports OEM or legacy functionality.
- `UnknownKeep`: evidence is incomplete, ambiguous, or too generic.

Never convert `UnknownKeep` or `LegacyKeep` into deletion just to improve cleanup
numbers.

---

## 6. Reporting Rules

After a run, produce:

Public:

- `driverstore-research-public.csv`
- `driverstore-run-spec-public.md`
- optional `public-summary.md`

Private:

- private inventory and merged review CSV,
- pre/post snapshots,
- deletion results,
- execution logs,
- private audit report.

README may include public summaries and case studies only. It must not include
private mapping, local `oemXX.inf`, or raw inventory.

---

## 7. End-of-Task Checklist

Before submitting a PR or final answer:

```powershell
git status --short -uall --ignored
```

Checklist:

- [ ] No private files staged.
- [ ] Public run spec exists for scan/research contribution PRs.
- [ ] Public run spec includes Windows generation and OEM machine context.
- [ ] README updated only with public-safe information.
- [ ] No real deletion ran unless the human explicitly approved it.
- [ ] If deletion ran, public and private reports were generated.
- [ ] Evidence links are official where possible.
- [ ] Ambiguous drivers remain `UnknownKeep`.
