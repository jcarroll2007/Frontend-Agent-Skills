# Core Stack

**React + TypeScript + Vite**

Always. No alternatives considered per-project.

## Versions

Always use the latest stable release of each. Fetch current versions from npm at scaffold time.

## TypeScript Config

Strict mode on. No exceptions. Key flags:
- `strict: true`
- `noUncheckedIndexedAccess: true`
- `exactOptionalPropertyTypes: true`

## Project Init

Do not use Create React App. Use Vite with the React TypeScript template as the base, then layer in additional stack pieces per their own stack docs.
