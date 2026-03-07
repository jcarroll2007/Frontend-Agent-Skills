# Data Stack

**TanStack Query + Zod**

TanStack Query for all async server state. Zod for runtime validation and type inference from API boundaries.

## TanStack Query

- All server state lives in Query. Never duplicate it in local state.
- Define query keys as constants in a central `queryKeys.ts` file.
- Co-locate query/mutation definitions with the feature that owns them.

## Zod

- Validate at API boundaries — responses, form inputs, env vars.
- Infer TypeScript types from schemas (`z.infer<typeof schema>`). Don't write parallel type definitions.
- Don't use Zod for internal data structures that never touch external boundaries.

## HTTP Client

Fetch API with a thin wrapper for base URL, auth headers, and error normalization. No Axios.
