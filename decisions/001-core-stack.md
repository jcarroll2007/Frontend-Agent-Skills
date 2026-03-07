# ADR-001: Core Stack — React + TypeScript + Vite

**Status:** Accepted
**Date:** 2026-03-07

## Decision

All frontend applications start with React, TypeScript (strict), and Vite.

## Why

- React has the largest ecosystem, best library support, and the widest hiring pool.
- TypeScript strict mode catches entire classes of bugs at authoring time — the cost is real but the payoff is higher.
- Vite is faster than Webpack/CRA in dev and build, with simpler config and first-class TS/JSX support.

## Trade-offs Accepted

- React is not the most performant option (Solid, Svelte). Performance-critical apps should revisit.
- TypeScript strict adds upfront type work. Worth it at any meaningful scale.
