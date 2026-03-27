---
title: Domain-Context Directory Structure
category: Directory Structure
tags: architecture, directory, contexts, isolation
---

## Domain-Context Directory Structure

All applications use a `contexts/` directory to organize code by business domain. This is not optional — even small apps benefit from domain boundaries established early. Each domain lives in its own subdirectory with a barrel `index.ts` as its only public API.

**If you don't know the business domains, ask before creating any files.** 

```
src/
├── components/      # Presentational, reusable UI — no business logic
├── containers/      # Stateful wrappers that orchestrate cross-domain composition
├── views/           # Page-level components; compose containers, components, and contexts
├── hooks/           # Shared hooks not owned by any single domain
├── lib/             # Utilities and internal libraries
├── types/           # Shared type definitions
└── contexts/        # Business domains — one subdirectory per domain
    ├── users/
    │   ├── components/
    │   ├── containers/
    │   ├── hooks/
    │   ├── types/
    │   └── index.ts
    ├── workspaces/
    │   └── index.ts
    └── tasks/
        └── index.ts
```

Each `contexts/<domain>/` mirrors the top-level structure. The `index.ts` barrel is the **only** public API for that context — nothing outside the context imports from internal paths.

**Wrong — importing from inside a context:**

```ts
import { useUser } from '@/contexts/users/hooks/useUser';
```

**Correct — always go through the barrel:**

```ts
import { useUser } from '@/contexts/users';
```

## Dependency Hierarchy

Contexts must form a directed acyclic graph (DAG). Define the hierarchy upfront and declare it in each barrel file:

```ts
// contexts/tasks/index.ts
//
// Allowed dependencies: users, epics
// Depended on by: (none — top of the dependency chain)
//
export { TaskCard } from './components/TaskCard';
export { useTask, useTaskList } from './hooks/useTask';
export type { Task, TaskStatus } from './types';
```

**Wrong — circular dependency:**

```ts
// contexts/users imports contexts/tasks
// contexts/tasks imports contexts/users  ← cycle
```

**Correct — dependencies only flow downward:**

```
users          ← foundational; imports no other context
workspaces     ← may import: users
epics          ← may import: workspaces, users
tasks          ← may import: users, epics
```

## Composition Layer

Cross-domain wiring happens **only** in `src/containers/` and `src/views/`. A context never pulls in another context to orchestrate it — it receives what it needs through props.

**Wrong — context orchestrating another context directly:**

```tsx
// contexts/tasks/components/TaskCard.tsx
import { useUser } from '@/contexts/users';  // ← wrong if users isn't a declared dep

export function TaskCard({ taskId }: { taskId: string }) {
  const task = useTask(taskId);
  const assignee = useUser(task.assigneeId);  // composition inside the context
  ...
}
```

**Correct — accept cross-domain data as props; compose at the top level:**

```tsx
// contexts/tasks/components/TaskCard.tsx
interface TaskCardProps {
  task: Task;
  assignee: { id: string; name: string; avatarUrl: string };
}
export function TaskCard({ task, assignee }: TaskCardProps) { ... }

// containers/TaskCardContainer.tsx — composition lives here
import { useTask } from '@/contexts/tasks';
import { useUser } from '@/contexts/users';
import { TaskCard } from '@/contexts/tasks';

export function TaskCardContainer({ taskId }: { taskId: string }) {
  const task = useTask(taskId);
  const assignee = useUser(task.assigneeId);
  return <TaskCard task={task} assignee={assignee} />;
}
```

## Enforcement

Boundaries are enforced via `eslint-plugin-boundaries`. The default policy is `disallow` — all cross-context imports are blocked unless explicitly listed in the config. When adding a new cross-context dependency:

1. Confirm it doesn't create a cycle.
2. Add it to the barrel's `Allowed dependencies` comment.
3. Add the `allow` rule to the ESLint boundaries config.
4. Only then add the import.

A diff that adds a cross-context import without updating both the barrel comment and the ESLint config is incomplete.

## Where Code Belongs

Ask one question: does this code serve **one** business domain, or does it **orchestrate multiple**?

- **One domain** → it belongs inside that context.
- **Multiple domains** → it belongs in `src/containers/`, `src/views/`, or `src/hooks/`.

If the answer is ambiguous, the code is probably doing too much. Split it.

For full details on containers and views, see `patterns/containers.md` and `patterns/views.md`.
