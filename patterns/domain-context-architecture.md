# Domain-Context Architecture

Use this pattern for applications with multiple distinct business domains that need explicit, enforced isolation between them. It replaces the simpler `features/` structure when cross-domain composition complexity warrants it.

## Directory Layout

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
    ├── epics/
    │   └── index.ts
    └── tasks/
        └── index.ts
```

Each directory under `contexts/` mirrors the top-level structure. The `index.ts` barrel file is the only public API for that context.

## Dependency Hierarchy

Contexts must form a directed acyclic graph (DAG). Define the hierarchy upfront and document it:

```
users          ← foundational; imports no other context
workspaces     ← may import: users
epics          ← may import: workspaces, users
tasks          ← may import: users, epics
```

Declare each context's allowed dependencies in its barrel file:

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

## Import Rules

These rules are absolute. Violating them breaks the architecture.

**1. Cross-context imports only go through the barrel file.**

```ts
// Correct
import { useUser } from '@/contexts/users';

// Wrong — never import from inside another context
import { useUser } from '@/contexts/users/hooks/useUser';
```

**2. A context only imports from its declared dependencies.**

Before adding any cross-context import, check the barrel file's `Allowed dependencies` comment. If the context you need isn't listed, do not add the import — push the composition up instead.

**3. No circular dependencies.**

If context A imports context B, context B cannot import context A under any circumstances. If you find yourself needing this, see "Resolving Dependency Violations" below.

**4. Top-level `views/` and `containers/` are the composition layer.**

They are the only place where multiple contexts are wired together. A context never orchestrates other contexts by pulling them in directly — it receives what it needs through props. See [containers.md](./containers.md) and [views.md](./views.md) for how each is structured.

## Dependency Inversion Inside Contexts

Context-internal components declare cross-domain data needs via props, not imports.

```tsx
// contexts/tasks/components/TaskCard.tsx
// Correct — accepts User shape via props; no import from users context
interface TaskCardProps {
  task: Task;
  assignee: { id: string; name: string; avatarUrl: string };
}

export function TaskCard({ task, assignee }: TaskCardProps) { ... }
```

```tsx
// containers/TaskCardContainer.tsx
// Correct — composition happens at the top level
import { useTask } from '@/contexts/tasks';
import { useUser } from '@/contexts/users';
import { TaskCard } from '@/contexts/tasks';

export function TaskCardContainer({ taskId }: { taskId: string }) {
  const task = useTask(taskId);
  const assignee = useUser(task.assigneeId);
  return <TaskCard task={task} assignee={assignee} />;
}
```

**Hooks within a context MAY import from allowed dependency contexts** when the relationship is genuinely domain-driven:

```ts
// contexts/tasks/hooks/useTaskWithAssignee.ts
// Allowed: tasks depends on users
import { useUser } from '@/contexts/users';
```

**If a hook composes contexts without a hierarchical relationship**, it belongs in `src/hooks/`, not inside any context.

## ESLint Boundaries Enforcement

The architecture is enforced via `eslint-plugin-boundaries`. Default policy is `disallow` — all cross-context imports are blocked unless explicitly permitted.

```js
// eslint.config.js (relevant excerpt)
import boundaries from 'eslint-plugin-boundaries';

export default [
  {
    plugins: { boundaries },
    settings: {
      'boundaries/elements': [
        { type: 'context-users',      pattern: 'src/contexts/users/**' },
        { type: 'context-workspaces', pattern: 'src/contexts/workspaces/**' },
        { type: 'context-epics',      pattern: 'src/contexts/epics/**' },
        { type: 'context-tasks',      pattern: 'src/contexts/tasks/**' },
      ],
    },
    rules: {
      'boundaries/element-types': ['error', {
        default: 'disallow',
        rules: [
          { from: 'context-workspaces', allow: ['context-users'] },
          { from: 'context-epics',      allow: ['context-workspaces', 'context-users'] },
          { from: 'context-tasks',      allow: ['context-users', 'context-epics'] },
        ],
      }],
    },
  },
];
```

The ESLint config is the canonical, machine-readable architecture document. The barrel file comments are the human-readable version. Keep them in sync.

## Adding a New Cross-Context Dependency

When a context genuinely needs to depend on another context:

1. Confirm the dependency does not create a cycle.
2. Add the allowed context to the barrel file's `Allowed dependencies` comment.
3. Add the corresponding `allow` rule in the ESLint boundaries config.
4. Only then add the import — and only through the barrel file.

Never add a cross-context import without completing all three steps. A diff that adds a cross-context import without updating both the barrel comment and the ESLint config is incomplete.

## Resolving Dependency Violations

If two contexts would need to import each other, or a needed dependency isn't in the hierarchy:

**Option 1 — Extract a shared lower-level context.** If both contexts need the same concept, that concept is its own domain. Create a new context at a lower level that both can depend on.

**Option 2 — Push composition up.** Move the code that needs both contexts to `src/containers/` or `src/views/`. Pass the results in as props.

Never resolve a violation by just adding the import. The violation is a design signal.

## Isolation Test

A context is correctly isolated if deleting it produces compile errors **only** in:

- `src/views/`, `src/containers/`, or `src/hooks/` that import from it
- Other contexts whose barrel files list it as a declared dependency

If deleting a context breaks a context that does not list it as a dependency, an internal file was imported directly or a dependency was added without being declared. Find and fix the violation.

## Shared Types

Prefer `src/types/` for types that multiple contexts reference (e.g., `UserId`, `Timestamp`, pagination shapes). Do not create cross-context type imports to avoid them — that is still a cross-context dependency and subject to the same rules.

## Where Code Belongs: Decision Rule

Ask one question: does this code serve one business domain, or does it orchestrate multiple?

- **One domain** → it belongs inside that context.
- **Multiple domains** → it belongs in `src/containers/`, `src/views/`, or `src/hooks/`.

If the answer is ambiguous, the code is probably doing too much. Split it.
