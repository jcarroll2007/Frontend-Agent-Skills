# Frontend Agent Skills

This repo is a curated set of frontend patterns, conventions, and skills. When working here, treat every document as authoritative — don't improvise alternatives to documented choices.

## Repo Map

- `skills/frontend-agent-skills/SKILL.md` — Skill entry point. Quick-reference patterns and links to the rule docs.
- `skills/frontend-agent-skills/rules/` — How to implement common frontend concerns. Read the relevant file before writing code.
- `decisions/` — Why specific libraries and approaches were chosen. Don't revisit closed decisions.

This repo is a [`npx skills`](https://github.com/vercel-labs/skills) source: the skill lives at `skills/frontend-agent-skills/` (flat layout) so the CLI can discover and install it.

## Working in This Repo

- Keep docs short and direct. One recommendation per topic, not a list of options.
- New decisions go in `decisions/` as ADRs using `decisions/template.md`.
- When a pattern changes, update the doc. Don't leave outdated guidance.
- New rules go in `skills/frontend-agent-skills/SKILL.md` under their own `##` section, with a rule file in `rules/` following the `category-rule-name` convention.
