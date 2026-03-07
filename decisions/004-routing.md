# ADR-004: Routing — TanStack Router

**Status:** Accepted
**Date:** 2026-03-07

## Decision

TanStack Router for all client-side routing.

## Why

- Fully type-safe routes, params, and search params out of the box.
- Built-in route-level data loading integrates cleanly with TanStack Query.
- File-based routing keeps route structure explicit and navigable.
- React Router v7 is moving toward framework territory. TanStack Router stays lean.

## Trade-offs Accepted

- Smaller community than React Router. Docs are good; ecosystem is catching up.
- File-based routing requires Vite plugin setup. Small one-time cost.
