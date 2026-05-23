# Research Notes Ledger

This folder is the public, append-only research ledger for DriverStore Cleaner.

Agents must add one new entry file for every scan/research contribution. Do not
delete or rewrite older entries. If a previous entry needs correction, add a new
correction entry that references the old entry ID.

## Entry Naming

Use:

```text
YYYY-MM-DD-<session-id>-<agent-tool>.md
```

Examples:

```text
2026-05-23-poc-dryrun-20260523-codex.md
2026-05-24-dell-latitude-win11-claudecode.md
```

## Required Fields

Each entry must declare:

- Entry ID
- Date
- Session ID
- Agent tool, such as Codex, Claude Code, Cursor, Aider, or Human
- Agent model, such as GPT-5, Claude Sonnet, or unknown
- Operator, use a public handle or `anonymous`
- Windows generation/release
- OEM, machine family, and model line
- Data files contributed
- What was done
- What was learned
- Privacy review

Use `TEMPLATE.md`.

