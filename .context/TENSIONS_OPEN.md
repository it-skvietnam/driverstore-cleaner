# Tensions - OPEN

> Contains only `Status: OPEN` entries.
> Agents must read this file before every task.
> Do not delete old entries. Move resolved entries to `TENSIONS_ACTIVE.md`.

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

## 2026-05-24T00:51 | staleness | modules_appdata
Status:     OPEN
Tension:    `[auto]` thay đổi nhưng `[manual]` chưa review
Context:    Hash mismatch trong `.context/modules_appdata.md` — `628a1899` → `918a872a` (built: 2026-05-24T00:32)
Proposal:   Review `[manual]` Design Decisions và Invariants của module `modules_appdata`, confirm hoặc update nếu cần, rebuild để clear warning
Constraint: `[manual]` có thể outdated so với code thực tế
Severity:   low
Tags:       staleness, modules_appdata
Milestone:  M3 - AppData Analyze-Only Module
Decision:   [human fill in]

---

## 2026-05-24T00:56 | staleness | modules_driverstore
Status:     OPEN
Tension:    `[auto]` thay đổi nhưng `[manual]` chưa review
Context:    Hash mismatch trong `.context/modules_driverstore.md` — `f026db99` → `535c20f7` (built: 2026-05-24T00:51)
Proposal:   Review `[manual]` Design Decisions và Invariants của module `modules_driverstore`, confirm hoặc update nếu cần, rebuild để clear warning
Constraint: `[manual]` có thể outdated so với code thực tế
Severity:   low
Tags:       staleness, modules_driverstore
Milestone:  M3 - AppData Analyze-Only Module
Decision:   [human fill in]

---
