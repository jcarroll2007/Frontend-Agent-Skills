---
title: Containers — Error Boundary
category: Component Architecture
tags: containers, error-boundary, tanstack-query
---

## QueryErrorBoundary

Use `QueryErrorBoundary` from the ui package instead of bare `ErrorBoundary`. It composes `QueryErrorResetBoundary` (TanStack Query) with `ErrorBoundary` (react-error-boundary) and handles common error types automatically.

**Built-in handling (in priority order):**
1. `AppChunkError` → renders `<UpdateAvailableState />` (stale bundle)
2. `ApiError` with status `403` → renders `<PermissionDeniedState />`
3. Custom `fallbackRender` prop → if provided and non-null, renders that
4. Default → renders `<ErrorState />`

Unexpected errors are reported via `useErrorReporter` automatically.

```tsx
// containers/UserList/index.ts
import { Suspense } from 'react';
import { QueryErrorBoundary } from '@company/ui';
import { UserListContent } from './UserListContent';
import type { UserListContentProps } from './UserListContent';

export type UserListContainerProps = UserListContentProps;

export function UserListContainer(props: UserListContainerProps) {
  return (
    <QueryErrorBoundary>
      <Suspense fallback={<UserListSkeleton />}>
        <UserListContent {...props} />
      </Suspense>
    </QueryErrorBoundary>
  );
}
```

Pass `fallbackRender` only when the container needs a custom error UI. Return `null` from it to fall through to the default `<ErrorState />`.

```tsx
<QueryErrorBoundary
  fallbackRender={({ error, resetErrorBoundary }) =>
    error instanceof SpecificError ? <SpecificErrorState /> : null
  }
>
```
