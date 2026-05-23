# MILESTONES.md - Windows Storage Research Cleaner

> Source of truth for current project milestones.
> Agents must read this file before starting architecture or module work.
> Only the human can approve moving to the next milestone.

---

## Current Milestone

Current: **M3 - AppData Analyze-Only Module**
Status: **PENDING**
Started: **not started**

---

## Transition Rule

Move milestone only when:

- acceptance checklist is complete,
- validation passes,
- public/private boundaries are reviewed,
- human explicitly approves transition.

When moving milestone:

1. Update `.context/MILESTONES.md`.
2. Move completed milestone notes to `.context/MILESTONES_HISTORY.md`.
3. Move resolved active tensions to `.context/TENSIONS_HISTORY.md`.
4. Keep unresolved tensions in `.context/TENSIONS_OPEN.md`.

---

## Completed Milestones

### M1 - Repo Architecture and Schemas

Status: **DONE**
Completed: **2026-05-23**

Acceptance:

- [x] Added `modules/` layout.
- [x] Added `schemas/` layout.
- [x] Added module registry.
- [x] Updated README with multi-module direction.
- [x] Validation passed.

### M2 - DriverStore Module Migration

Status: **DONE**
Completed: **2026-05-23**

Acceptance:

- [x] Moved DriverStore implementation into `modules/driverstore/`.
- [x] Preserved root wrapper scripts for compatibility.
- [x] Added DriverStore module README.
- [x] Wrapper dry-run test passed.
- [x] Validation passed.

---

## Upcoming Milestones

### M3 - AppData Analyze-Only Module

Status: **PENDING**

Acceptance:

- [ ] Add `modules/appdata/README.md`.
- [ ] Add analyze-only script for cache candidates.
- [ ] Report `%LOCALAPPDATA%\Temp`, Office cache, browser caches, and dev caches.
- [ ] Do not delete anything.
- [ ] Produce public/private artifacts using shared schema.
- [ ] Add research note and run spec for first AppData scan.
- [ ] Validation passes.

### M4 - Unified Reports and Metrics

Status: **PENDING**

Acceptance:

- [ ] Add public summary generator.
- [ ] Add private audit report generator.
- [ ] Add estimated size metrics per module.
- [ ] Add skipped/high-risk counts.
- [ ] README documents report structure.

### M5 - WinSxS Explain-Only Module

Status: **PENDING**

Acceptance:

- [ ] Add DISM analyze wrapper.
- [ ] Report component store cleanup recommendation.
- [ ] Do not manually delete WinSxS files.
- [ ] Document `StartComponentCleanup` and `/ResetBase` tradeoffs.

