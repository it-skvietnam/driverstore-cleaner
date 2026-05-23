# Tensions - OPEN

> Contains only `Status: OPEN` entries.
> Agents must read this file before every task.
> Do not delete old entries. Move resolved entries to `TENSIONS_ACTIVE.md`.

---

## [2026-05-23 21:00] | context-mapping
Tension:    `context-mapping` currently found no parseable source files in this PowerShell/docs-heavy repo.
Context:    The project is using `context-mapping` from WSL Debian `.venv` to manage milestones and tensions, but the tool's parser set is aimed at Rust/TypeScript/PHP projects.
Proposal:   Keep `.context` milestone/tension files manually maintained for now, and later add PowerShell/docs awareness or a module convention if needed.
Constraint: Context should be generated and kept consistent, but the current tool cannot infer PowerShell module structure automatically.
Severity:   low
Tags:       context, tooling, powershell
Milestone:  M3 - AppData Analyze-Only Module
Status:     OPEN
Resolved:
Decision:   OPEN

---

## [2026-05-23 21:05] | module-architecture
Tension:    The repo is expanding from DriverStore-only cleanup to multi-domain Windows storage cleanup.
Context:    DriverStore module migration is complete, but validators and public artifacts still use some DriverStore-specific names.
Proposal:   Keep DriverStore compatibility while gradually generalizing validation/report schemas per module.
Constraint: New modules must not weaken privacy checks or cleanup approval gates.
Severity:   low
Tags:       modules, validation, privacy
Milestone:  M3 - AppData Analyze-Only Module
Status:     OPEN
Resolved:
Decision:   OPEN

