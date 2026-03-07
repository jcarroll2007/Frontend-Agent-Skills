# Testing Stack

**Vitest + Testing Library + Playwright**

- **Vitest** — unit and integration tests. Replaces Jest. Same API, faster.
- **Testing Library** — component tests. Query by role/label, not implementation details.
- **Playwright** — E2E tests for critical user flows only.

## What to Test

- Business logic in hooks and utilities: always.
- Component behavior (user interactions, conditional rendering): yes.
- Component appearance/markup: no.
- Every E2E happy path for critical flows (auth, checkout, core actions): yes.
- Internal implementation details: never.

## Coverage

Don't chase a coverage number. Test the things that break silently and cost users.
