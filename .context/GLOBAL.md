# GLOBAL.md - Windows Storage Research Cleaner

This repository is an agent-assisted research-first Windows storage cleanup project.
It started as DriverStore Cleaner and is being expanded into a modular Windows
Storage Research Cleaner.

## Core Principles

- Analyze before delete.
- Research before approve.
- Keep local/private machine data out of public artifacts.
- Use supported cleanup APIs per module.
- Treat unknown evidence as keep.
- Record public research notes append-only.

## Active Module

- `driverstore`: Windows DriverStore package research and gated cleanup through
  `pnputil`.

## Planned Modules

- `winsxs`
- `appdata`
- `office-outlook`
- `browser-cache`
- `dev-cache`
- `wsl-docker`
- `restore-points`
- `windows-update`

## Important Files

- `AGENTS.md`: agent protocol.
- `CONTRIBUTING.md`: contribution workflow.
- `modules/MODULES.md`: module registry and risk taxonomy.
- `schemas/*.md`: public/private artifact contracts.
- `research-notes/`: append-only public research ledger.
- `tools/Test-AgentContribution.ps1`: privacy and contribution validation.

