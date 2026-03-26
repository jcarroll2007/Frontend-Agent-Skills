# Frontend Agent Skills

This repo is a curated set of frontend patterns, conventions, and skills. When working here, treat every document as authoritative — don't improvise alternatives to documented choices.

## Repo Map

- `SKILL.md` — Single skill entry point. Defines all available commands and references pattern docs.
- `patterns/` — How to implement common frontend concerns. Read the relevant file before writing code.
- `decisions/` — Why specific libraries and approaches were chosen. Don't revisit closed decisions.
- `conventions/` — Mechanical rules. Apply them without interpretation.
- `stack/` — Canonical library choices per concern.
- `scripts/` — Shell scripts invoked by skill commands.

## Working in This Repo

- Keep docs short and direct. One recommendation per topic, not a list of options.
- New decisions go in `decisions/` as ADRs using `decisions/template.md`.
- Skills must fetch current library docs at runtime — never hardcode version-specific install steps.
- When a pattern changes, update the doc. Don't leave outdated guidance.
- New commands go in `SKILL.md` under their own `## /command-name` section.
