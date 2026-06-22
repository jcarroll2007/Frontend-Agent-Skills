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
- Own all navigation callbacks — when a container action triggers navigation (e.g., navigating after a delete), the view passes a callback prop rather than letting the container call `useNavigate` directly
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

## Navigation Ownership

Views own all navigation. Containers should never call `useNavigate` directly — instead, they accept callback props (e.g., `onDeleteSuccess`, `onSaveComplete`) that the view wires to navigation. This keeps containers decoupled from routing and from other business domains.

**Why this matters:** A container that navigates after an action (e.g., "navigate to the parent epic after deleting a task") implicitly depends on the route structure and often on another domain's route params. This coupling prevents the container from living inside its own context and makes it harder to reuse.

**Wrong — container handles navigation:**

```tsx
// containers/TaskDetail/TaskDetailContent.tsx
function TaskDetailContent({ epicId, taskId }: Props) {
  const navigate = useNavigate();
  const deleteTask = useDeleteTask();

  // This container now depends on epics (epicId) just for navigation
  const handleDelete = () => {
    deleteTask.mutate(taskId, {
      onSuccess: () => navigate({ to: '/epics/$epicId', params: { epicId } }),
    });
  };
  // ...
}
```

**Correct — view owns navigation via callback:**

```tsx
// views/epics/$epicId/tasks/$taskId/index.tsx
export function TaskDetailView() {
  const { epicId, taskId } = useParams();
  const navigate = useNavigate();

  return (
    <TaskDetailContainer
      taskId={taskId}
      onDeleteSuccess={() => navigate({ to: '/epics/$epicId', params: { epicId } })}
    />
  );
}
```

The container only knows about tasks. The view — which already has the route context — handles where to go next.

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
