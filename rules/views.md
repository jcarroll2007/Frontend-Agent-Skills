---
title: Views
category: Component Architecture
tags: views, routing, composition, layout
---

## Views

A view is a page-level component and the composition root for a route. Views live in `src/views/` — they are part of the app layer, not any business domain. They consume contexts and wire them together into pages, but they belong to neither.

**Responsibilities:**
- Extract route params and pass them as props to containers
- Compose containers and layout components declaratively
- Own nothing else — no data fetching, no business logic, no conditional rendering beyond layout variation

```tsx
// views/WorkspaceView.tsx
export function WorkspaceView() {
  const { workspaceId } = useParams();

  return (
    <WorkspaceLayout>
      <WorkspaceHeaderContainer workspaceId={workspaceId} />
      <UserListContainer
        workspaceId={workspaceId}
        renderUser={(userId) => <UserDetailContainer userId={userId} />}
      />
    </WorkspaceLayout>
  );
}
```

A view should read like a flat list of every major piece of UI on the page. If you need to scroll past inline logic to understand what's rendered, move that logic into a container.

## What Does Not Belong in a View

- `useQuery` or any data fetching — put it in a container's content component
- `useState` for server-derived state — same
- Conditional rendering based on fetched data — the container handles that
- Shared layout like navbars or sidebars — those belong in a layout component wrapping the route, not inside each view

## Directory Structure

`src/views/` is organized to mirror the app's URL hierarchy. Each segment of a URL becomes a directory; the view for that route is the `index.tsx` inside it. This makes any route trivially findable by its URL — but the structure is purely organizational. Routing is programmatic; file location has no effect on routing behavior. See `rules/routing.md`.

```
src/views/
├── workspaces/
│   ├── index.tsx                      # /workspaces
│   └── $workspaceId/
│       ├── index.tsx                  # /workspaces/$workspaceId
│       ├── epics/
│       │   ├── index.tsx              # /workspaces/$workspaceId/epics
│       │   └── $epicId/
│       │       └── index.tsx          # /workspaces/$workspaceId/epics/$epicId
│       └── settings/
│           └── index.tsx              # /workspaces/$workspaceId/settings
└── account/
    └── index.tsx                      # /account
```

## Routing

Each view maps to exactly one route and is registered in the router — not imported by other components. If two routes share significant UI, they share containers, not a shared view.

For how routes are defined and organized, see `rules/routing.md`.
