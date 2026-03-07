# ADR-005: Testing — Vitest + Testing Library + Playwright

**Status:** Accepted
**Date:** 2026-03-07

## Decision

Vitest for unit/integration, Testing Library for component behavior, Playwright for E2E.

## Why

- Vitest is Jest-compatible but significantly faster, with native Vite integration.
- Testing Library enforces testing from the user's perspective — finds bugs that matter.
- Playwright is the most reliable cross-browser E2E tool available. Better DX than Cypress.

## Trade-offs Accepted

- Three testing tools to configure. The separation of concerns is worth it.
- Playwright E2E tests are slower. Limit to critical flows and run in CI, not every dev iteration.
