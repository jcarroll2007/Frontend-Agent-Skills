# Views

A view is a page-level component. It is the composition root for a route — the only place that knows what route it's on, what params are in the URL, and which containers and components make up that page.

See [containers.md](./containers.md) for how containers are structured and how they receive props from views.

## Responsibilities

- Extract route params and pass them as props to containers.
- Compose containers and layout components declaratively.
- Own nothing else. No data fetching, no business logic, no conditional rendering beyond layout variation.

## Structure

A view should read like a flat list of every major piece of UI on the page. If you need to scroll past inline logic to understand what's rendered, move that logic into a container.

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

## Routing

Views are registered in the router, not imported by other components. Each view maps to exactly one route. If two routes share significant UI, they share containers — not a shared view.

Use TanStack Router's typed routes. Route params are typed at the route definition; views receive them via `useParams()` or route context with full type safety.

## What Does Not Belong in a View

- `useQuery` or any data fetching — put it in a container's content component.
- `useState` for server-derived state — same.
- Conditional rendering based on fetched data — the container handles that.
- Shared layout like navbars or sidebars — those belong in a layout component wrapping the route, not inside each view.
