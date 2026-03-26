# Containers

A container is a stateful component that owns data fetching for a specific unit of UI. It is distinct from a UI component, which is purely presentational.

## Directory Structure

Each container lives in its own directory:

```
containers/UserList/
├── index.ts
└── UserListContent.tsx
```

`index.ts` is the public interface. `UserListContent.tsx` is the implementation. Nothing else belongs here — no helpers, no sub-components. If a piece of the UI needs extraction, it becomes a component in `components/`.

## index.ts

`index.ts` wraps the content component in an `ErrorBoundary` and, in most cases, `Suspense`. It exports the wrapped component as the container's public name.

```ts
// containers/UserList/index.ts
import { Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';
import { UserListContent } from './UserListContent';
import type { UserListContentProps } from './UserListContent';

export type UserListContainerProps = UserListContentProps;

export function UserListContainer(props: UserListContainerProps) {
  return (
    <ErrorBoundary fallback={<UserListError />}>
      <Suspense fallback={<UserListSkeleton />}>
        <UserListContent {...props} />
      </Suspense>
    </ErrorBoundary>
  );
}
```

### When to use Suspense

Use `Suspense` by default. The only reason to omit it is when the container has meaningful static content that should render immediately and you need fine-grained control over which parts show a loading state. In that case, use `isPending` / `isFetching` from TanStack Query directly inside the content component and do not wrap in `Suspense`.

### When to lazy-load

Most containers should **not** be lazy-loaded. Default to a direct import.

Lazy-load only when the container is on a route or modal that the majority of users never reach and the bundle cost is measurable. When you do lazy-load, do it in `index.ts` so consumers are unaffected:

```ts
// containers/AdminPanel/index.ts — lazy variant
import { lazy, Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';

const AdminPanelContent = lazy(() =>
  import('./AdminPanelContent').then((m) => ({ default: m.AdminPanelContent }))
);

export function AdminPanelContainer(props: AdminPanelContainerProps) {
  return (
    <ErrorBoundary fallback={<AdminPanelError />}>
      <Suspense fallback={<AdminPanelSkeleton />}>
        <AdminPanelContent {...props} />
      </Suspense>
    </ErrorBoundary>
  );
}
```

## Content Component

`UserListContent.tsx` fetches data and renders UI components. It contains no routing logic — route params are passed in as props by the view.

```tsx
// containers/UserList/UserListContent.tsx
import { useQuery } from '@tanstack/react-query';
import { userQueries } from '@/contexts/users';
import { UserList } from '@/components/UserList';

export interface UserListContentProps {
  workspaceId: string;
  renderUser: (userId: string) => React.ReactNode;
}

export function UserListContent({ workspaceId, renderUser }: UserListContentProps) {
  const { data: users } = useQuery(userQueries.list(workspaceId));

  return (
    <UserList>
      {users.map((user) => renderUser(user.id))}
    </UserList>
  );
}
```

Child containers are never imported directly inside a content component. They are passed in as render props. This keeps each container single-purposed and makes composition explicit at the call site.

## Composition with Render Props

When a container renders rows, cards, or items that are themselves containers, accept a render prop instead of importing the child container:

```tsx
// Correct — caller controls child container
<UserListContainer
  workspaceId={workspaceId}
  renderUser={(userId) => <UserDetailContainer userId={userId} />}
/>

// Wrong — UserListContainer should not know about UserDetailContainer
```

This avoids coupling containers to each other and keeps the composition visible at the view level.

## Testing

Test containers using [Mock Service Worker](https://mswjs.io/) to intercept requests at the network level. Do not mock TanStack Query hooks or the fetch client directly.

```tsx
// containers/UserList/__tests__/UserListContainer.test.tsx
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import { render, screen } from '@testing-library/react';
import { createWrapper } from '@/test/utils'; // QueryClient + any providers
import { UserListContainer } from '..';

const server = setupServer(
  http.get('/api/users', () =>
    HttpResponse.json([{ id: '1', name: 'Alice' }])
  )
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

it('renders users returned by the API', async () => {
  render(
    <UserListContainer
      workspaceId="ws-1"
      renderUser={(id) => <span key={id}>{id}</span>}
    />,
    { wrapper: createWrapper() }
  );

  expect(await screen.findByText('Alice')).toBeInTheDocument();
});

it('renders an error state when the request fails', async () => {
  server.use(
    http.get('/api/users', () => HttpResponse.error())
  );

  render(
    <UserListContainer
      workspaceId="ws-1"
      renderUser={(id) => <span key={id}>{id}</span>}
    />,
    { wrapper: createWrapper() }
  );

  expect(await screen.findByText('Something went wrong.')).toBeInTheDocument();
});
```

Each test file sets up its own `setupServer`. Override specific handlers per test with `server.use()` — use this to cover error states and edge cases without duplicating the happy-path handler.

## Views and Routing

See [views.md](./views.md).
