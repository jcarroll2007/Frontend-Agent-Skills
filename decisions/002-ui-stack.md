# ADR-002: UI Stack — Tailwind + shadcn/ui

**Status:** Accepted
**Date:** 2026-03-07

## Decision

Tailwind CSS for styling, shadcn/ui for component primitives.

## Why

- Tailwind eliminates naming and specificity problems. Styles are co-located with markup.
- shadcn/ui components are owned (not a dependency) — fully customizable, no black-box overrides.
- The combination covers 90% of UI needs without a design system build-out.
- CSS variables for tokens means theming is a config change, not a refactor.

## Trade-offs Accepted

- Tailwind class strings get long. Acceptable — readability is solved with consistent ordering and `clsx`/`tailwind-merge`.
- shadcn/ui requires copying components into the project. Copy-paste is the feature, not a limitation.
