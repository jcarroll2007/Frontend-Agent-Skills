# Frontend Agent Skills

Opinionated frontend patterns, conventions, and agent skills built from 15 years of production experience.

## What's Here

| Directory | Purpose |
|---|---|
| `skills/` | Claude Code slash commands — executable workflows |
| `patterns/` | Implementation patterns with clear recommendations |
| `decisions/` | Architecture Decision Records explaining library choices |
| `conventions/` | Concrete rules for naming, structure, and process |
| `stack/` | Opinionated tech stack definitions |

## Using the Skills

Run this from the root of your project:

```sh
npx github:jcarroll2007/Frontend-Agent-Skills
```

This copies `SKILL.md` and the `rules/` folder into `.claude/skills/` in your project. Claude Code will pick them up automatically.

## Stack at a Glance

React + TypeScript + Vite · TanStack Router + Query · Tailwind + shadcn/ui · Vitest + Playwright

## Contributing

Open an issue or PR. New patterns and decisions should follow the existing document format — direct, opinionated, no option lists without a clear recommendation.
