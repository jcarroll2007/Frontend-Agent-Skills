---
title: Routing
category: Routing
tags: routing, tanstack-router, routes, guards, search-params
---

## Routing

Routing is programmatic via TanStack Router. All route definitions live in `src/router/`.

## Directory Structure

```
src/router/
├── index.tsx      # Router instantiation and global config
├── root.tsx       # Root route component
├── tree.tsx       # Complete route tree — single source of truth
└── types.ts       # RouterContext and shared search param types
```

`tree.tsx` is the only place routes are defined. `index.tsx` creates the router instance with global config (preloading, scroll restoration, error fallback).

## Naming Conventions

| Suffix | Purpose |
|--------|---------|
| `*Route` | Any route variable |
| `*LayoutRoute` | Renders `<Outlet />` only, no own UI |
| `*GuardRoute` | Enforces access control in `beforeLoad` |
| `*DialogRoute` | URL-driven modal/dialog |
| `*DetailRoute` | Detail/show view |
| `*RedirectRoute` | Exists solely to redirect |

URL parameters use the `$` prefix convention: `$orgId`, `$workspaceId`, etc.

## Route Hierarchy

Routes are composed into trees using `.addChildren()`. Each scope follows a **guard → chooser → access → content** pattern:

1. **Role guard** — blocks users without the required membership type
2. **Access guard** — validates the user belongs to the specific resource
3. **Content routes** — the actual pages, wrapped in a context provider

## Access Control

Auth state and resource access are enforced in `beforeLoad`, not in components.

**Authentication guard:**
```tsx
beforeLoad: async ({ context }) => {
  const sessionExists = await Session.doesSessionExist();
  if (!sessionExists) {
    throw redirect({ to: '/auth', search: { returnTo: location.href } });
  }
  const user = await context.queryClient.fetchQuery(userMeQuery());
  return { user };
}
```

**Resource existence guard** — fetch the resource and redirect if it doesn't exist:
```tsx
beforeLoad: async ({ params, context }) => {
  try {
    const workspace = await context.queryClient.fetchQuery(
      workspaceQuery(params.workspaceId)
    );
    return { workspace };
  } catch {
    throw redirect({ to: '/workspaces' });
  }
}
```

## Search Params

All search params are validated with Zod via `zodValidator()`. Define the schema inline on the route.

```tsx
const workspaceRoute = createRoute({
  validateSearch: zodValidator(
    z.object({
      tab: z.enum(['overview', 'members', 'settings']).optional(),
      page: z.number().optional(),
    })
  ),
});
```

Define filter or date-range params on layout routes so child routes inherit them automatically.

## Layout Routes

Layout routes render shared UI (nav, sidebar, providers) around children via `<Outlet />`. They carry no path segment of their own. Wrap context providers at the appropriate layout level so all children have access.

```tsx
const workspaceLayoutRoute = createRoute({
  getParentRoute: () => workspaceAccessGuardRoute,
  path: 'workspaces',
  component: () => (
    <WorkspaceProvider>
      <WorkspaceShell>
        <Outlet />
      </WorkspaceShell>
    </WorkspaceProvider>
  ),
});
```

## Dialog Routes

URL-driven dialogs are child routes of the list or detail they overlay:

```
workspaceVenuesRoute
├── venueCreateDialogRoute       (new)
├── venueEditDialogRoute         ($venueId/edit)
└── venueDeleteDialogRoute       ($venueId/delete)
```

## Adding a New Route

1. Define the route in `tree.tsx` using `createRoute()`.
2. Choose the correct parent based on scope and access requirements.
3. Add guards in `beforeLoad` if the route needs access control.
4. Validate search params with `zodValidator()` if the route uses query strings.
5. Attach it to the parent's `.addChildren()` call.

## Testing

Test routing behavior in `router/__tests__/tree.test.tsx` using memory history and MSW for API mocking. Cover:

- Auth redirects (unauthenticated → login, authenticated → away from login)
- Guard behavior when access is denied
- Auto-redirect for single-membership chooser routes
- Search param parsing
