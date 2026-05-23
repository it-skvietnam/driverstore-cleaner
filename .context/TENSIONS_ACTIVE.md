# Tensions - ACTIVE

> Contains resolved tensions that remain relevant to the current milestone.

---

## [2026-05-23 21:00] | context-mapping
Tension:    `context-mapping` could not parse this PowerShell/docs-heavy repo.
Context:    The project uses `context-mapping` from WSL Debian `.venv` to manage milestones and tensions.
Proposal:   Add a standard PowerShell parser using the official PowerShell AST backend.
Constraint: Context should be generated and kept consistent from source files, not only manual docs.
Severity:   low
Tags:       context, tooling, powershell
Milestone:  M3 - AppData Analyze-Only Module
Status:     RESOLVED_ACTIVE
Resolved:   2026-05-23
Decision:   Added a PowerShell parser to `context-mapping` using `System.Management.Automation.Language.Parser.ParseFile`; verified on `driverstore-cleaner` and ChrisTitusTech WinUtil.
