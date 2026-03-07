# ADR-003: Data Stack — TanStack Query + Zod

**Status:** Accepted
**Date:** 2026-03-07

## Decision

TanStack Query for server state, Zod for validation and type inference at API boundaries.

## Why

- TanStack Query solves caching, background refetch, loading/error states, and optimistic updates — all the hard parts of server state.
- Zod schemas are the single source of truth for API shapes. `z.infer<>` eliminates duplicate type definitions.
- Together they enforce a clean boundary: external data is validated and typed before it touches app logic.

## Trade-offs Accepted

- TanStack Query has a learning curve (query keys, stale time, invalidation). Worth the investment.
- Zod validation adds runtime cost at boundaries. Negligible for typical API payloads.
