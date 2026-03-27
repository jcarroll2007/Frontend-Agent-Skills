---
title: Containers
category: Component Architecture
tags: containers, data-fetching, suspense, error-boundary, render-props
---

## Before You Build

Before writing a container, ask the user:

> "Should this container use Suspense for loading states, or manage loading state manually?"

- **Suspense (default)** — use `useSuspenseQuery` in the content component and wrap with `<Suspense fallback={<LoadingView />}>` in `index.tsx`
- **Manual** — use `useQuery` and handle `isPending` / `isFetching` directly in the content component; omit `<Suspense>` from `index.tsx`

If the user opts out of Suspense, also ask whether to lazy-load the content component. If they use Suspense, lazy loading is available but not required — default to a direct import unless the user asks for it.

## Containers

The container pattern separates data-fetching components into three distinct layers:

1. **Container** (`index.tsx`) — error boundary + Suspense wrapper; no logic
2. **Content** (`*ContainerContent.tsx`) — data fetching, route params, data transformation
3. **Presentation** (`components/`) — pure UI; receives data via props

## Directory Structure

```
containers/UserList/
├── index.tsx              # Container: QueryErrorBoundary + Suspense
├── UserListContent.tsx    # Content: data fetching
└── types.ts               # Shared prop types (only when props pass through)
```

`index.tsx` is the public interface. Nothing else belongs here — no helpers, no sub-components. If a piece of UI needs extraction, it becomes a component in `components/`.

Add `types.ts` only when the container accepts props that are passed through to the content component. Both files import from it; don't duplicate the interface.

```ts
// types.ts
interface UserListContainerProps {
  workspaceId: string;
}
export type { UserListContainerProps };
```

## index.tsx

Wraps the content component in `QueryErrorBoundary` and `Suspense`. See [`containers-error-boundary`](./containers-error-boundary.md) for `QueryErrorBoundary` usage and its built-in error handling.

```tsx
// containers/UserList/index.tsx
import { Suspense } from 'react';
import { LoadingView } from '@/components/loading-view';
import { QueryErrorBoundary } from '@company/ui';
import { UserListContent } from './UserListContent';
import type { UserListContainerProps } from './types';

export function UserListContainer(props: UserListContainerProps) {
  return (
    <QueryErrorBoundary>
      <Suspense fallback={<LoadingView />}>
        <UserListContent {...props} />
      </Suspense>
    </QueryErrorBoundary>
  );
}
```

Don't use suspense when the container has meaningful static content that should render immediately and you need fine-grained control over loading states — in that case use `isPending` / `isFetching` from TanStack Query directly in the content component.

## Content Component

Fetches data using `useSuspenseQuery`, extracts route params, transforms the response, and passes data to the presentation component. Contains no UI beyond rendering the presentation component.

```tsx
// containers/UserList/UserListContent.tsx
import { useSuspenseQuery } from '@tanstack/react-query';
import { useParams } from '@tanstack/react-router';
import { UserList } from '../../components/UserList';
import type { UserListContainerProps } from './types';

export function UserListContent({ workspaceId }: UserListContainerProps) {
  const { orgId } = useParams({ from: '/org/$orgId/users/' });

  const { data: response } = useSuspenseQuery({
    queryKey: getGetApiUsersQueryKey({ workspaceId }),
    queryFn: () => getApiUsers({ workspaceId }),
  });

  const users = response?.status === 200 ? response.data : [];

  return <UserList users={users} />;
}
```

Use `useSuspenseQuery` when the container uses Suspense (the default). Use `useQuery` and handle `isPending` / `isFetching` in the UI when the container opts out of Suspense. When using `useQuery`, errors must be re-thrown so they propagate to the `QueryErrorBoundary`:

```tsx
const { data, isPending, error } = useQuery(/* ... */);
if (error) throw error;
```

Extract route params here, not in the container.

A container always fetches its own data — never receives already-fetched data from a parent as props. If a parent happens to fetch the same query, React Query's cache deduplicates the request. Design each container to be completely self-sufficient; assume nothing about what ancestors have already loaded.

Child containers are never imported directly inside a content component — they are passed in as render props. This keeps each container single-purposed and makes composition explicit at the call site.

## Presentation Component

Lives in `components/`, not inside the container directory. Accepts data via props, renders pure UI, and manages only local UI state (toggles, modals). No data fetching, no route dependencies.

```tsx
// components/UserList.tsx
interface UserListProps {
  users: User[];
}

export function UserList({ users }: UserListProps) {
  if (users.length === 0) return <div>No users found</div>;

  return (
    <ul className="space-y-2">
      {users.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

## Composition with Render Props

When a container renders rows, cards, or items that are themselves containers, accept a render prop instead of importing the child container:

```tsx
// Correct — caller controls child container
<UserListContainer
  workspaceId={workspaceId}
  renderUser={(userId) => <UserDetailContainer userId={userId} />}
/>

// Wrong — UserListContainer imports and hard-codes UserDetailContainer
```

This keeps the composition visible at the view level and avoids coupling containers to each other.

## Lazy Loading

Most containers should not be lazy-loaded — default to a direct import. Lazy-load only when the container is on a route or modal that the majority of users never reach and the bundle cost is measurable. When you do lazy-load, do it in `index.tsx` so consumers are unaffected.

## Testing

Test containers using [Mock Service Worker](https://mswjs.io/) to intercept requests at the network level. Do not mock TanStack Query hooks or the fetch client directly.

```tsx
const server = setupServer(
  http.get('/api/users', () =>
    HttpResponse.json([{ id: '1', name: 'Alice' }])
  )
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

Override specific handlers per test with `server.use()` to cover error states without duplicating the happy-path setup.
