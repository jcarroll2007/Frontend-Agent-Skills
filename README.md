# Frontend Agent Skills

Opinionated frontend patterns, conventions, and agent skills built from 15 years of production experience.

## What's Here

| Directory | Purpose |
|---|---|
| `skills/frontend-agent-skills/` | The installable agent skill — `SKILL.md` plus its `rules/` |
| `decisions/` | Architecture Decision Records explaining library choices |

## Installing the Skill

This repo is a [`npx skills`](https://github.com/vercel-labs/skills) source. Run from the root of your project:

```sh
npx skills add jcarroll2007/Frontend-Agent-Skills
```

Target a specific agent with `-a` (e.g. Claude Code):

```sh
npx skills add jcarroll2007/Frontend-Agent-Skills -a claude-code
```

This copies the `frontend-agent-skills` skill (its `SKILL.md` and `rules/`) into your agent's skills directory — for Claude Code that's `.claude/skills/frontend-agent-skills/`. The agent picks it up automatically.

Update later with `npx skills update`, and list installed skills with `npx skills list`.

## Stack at a Glance

React + TypeScript + Vite · TanStack Router + Query · Tailwind + shadcn/ui · Vitest + Playwright

## Contributing

Open an issue or PR. New patterns and decisions should follow the existing document format — direct, opinionated, no option lists without a clear recommendation.
