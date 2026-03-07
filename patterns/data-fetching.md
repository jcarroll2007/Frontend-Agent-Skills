# Data Fetching

Use TanStack Query for all server state. No exceptions.

## Query Structure

```ts
// features/users/api/queries.ts
export const userQueries = {
  all: () => ({ queryKey: [USERS], queryFn: fetchUsers }),
  detail: (id: string) => ({ queryKey: [USERS, id], queryFn: () => fetchUser(id) }),
};
```

Pass query option objects directly to `useQuery`. Don't wrap `useQuery` in a custom hook unless you're adding meaningful logic (transformation, derived state).

## Error Handling

- Set a global `QueryClient` error handler for unexpected errors.
- Handle expected errors (404, 401) at the component level using the `error` return value.
- Use an `ErrorBoundary` at the route level for unrecoverable states.

## Loading States

- Use `isPending` for initial load (no cached data).
- Use `isFetching` to show a subtle refresh indicator when cached data exists.
- Don't show full-page spinners for background refetches.

## Mutations

- Invalidate relevant queries in `onSuccess`. Don't manually update the cache unless the server doesn't return the updated data.
- Use optimistic updates only for high-frequency interactions where latency is noticeable.
