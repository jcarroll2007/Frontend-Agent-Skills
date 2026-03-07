# State Management

Use the simplest tool that solves the problem. In order of preference:

## 1. Local State — `useState` / `useReducer`

Default choice. If only one component or its direct children need the state, keep it local.

Use `useReducer` when state has multiple sub-values that change together, or when the next state depends on complex logic.

## 2. URL State

Underused and underrated. Filters, pagination, tabs, and selected items often belong in the URL. Benefits: shareable links, back-button support, free persistence on reload. Use TanStack Router's typed search params.

## 3. Context

For state shared across a subtree that doesn't change frequently — auth session, theme, feature flags. Not a general-purpose state manager. Wrapping everything in context with frequent updates causes re-render problems.

## 4. TanStack Query

All server state. Cached, synchronized, and invalidated automatically. Never duplicate server state into `useState`.

## What Not to Use

- **Zustand / Redux / Jotai**: Only if you have a concrete problem that the above four can't solve. That's rare. Don't add a global state library by default.
