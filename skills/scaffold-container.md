# Skill: scaffold-container

Scaffold a new container following the structure defined in `patterns/containers.md`.

## Trigger

User runs `/scaffold-container` or asks to create / scaffold a new container.

## Step 1 — Gather Context

Ask the following questions if the answers aren't already clear from context. Ask them together in one message, not one at a time.

**1. Name and purpose**
What is the container called, and what does it do? (Used to determine the name and where it lives in the directory tree.)

**2. Lazy loading**
Should this container be lazy-loaded?

Default: **no**. Only lazy-load if the container is behind a route or modal that most users never reach and the bundle cost is worth the added complexity. If unsure, default to no.

**3. Suspense**
Should this container use `Suspense` for its loading state?

Default: **yes**. Only omit Suspense if the container has meaningful static content that should render immediately and you need fine-grained control over individual loading states within it. If unsure, default to yes.

## Step 2 — Determine the Directory

Based on the container's purpose, place it in the right location:

- If it belongs to a single business domain: `src/contexts/<domain>/containers/<ContainerName>/`
- If it composes multiple domains: `src/containers/<ContainerName>/`

If it's unclear which applies, ask.

## Step 3 — Write the Files

Create two files: `index.ts` and `<ContainerName>Content.tsx`.

---

### index.ts — no lazy, with Suspense (default)

```ts
import { Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';
import { <ContainerName>Content } from './<ContainerName>Content';
import type { <ContainerName>ContentProps } from './<ContainerName>Content';

export type <ContainerName>Props = <ContainerName>ContentProps;

export function <ContainerName>({ ...props }: <ContainerName>Props) {
  return (
    <ErrorBoundary fallback={<div>Something went wrong.</div>}>
      <Suspense fallback={<div>Loading...</div>}>
        <<ContainerName>Content {...props} />
      </Suspense>
    </ErrorBoundary>
  );
}
```

---

### index.ts — no lazy, no Suspense

```ts
import { ErrorBoundary } from 'react-error-boundary';
import { <ContainerName>Content } from './<ContainerName>Content';
import type { <ContainerName>ContentProps } from './<ContainerName>Content';

export type <ContainerName>Props = <ContainerName>ContentProps;

export function <ContainerName>({ ...props }: <ContainerName>Props) {
  return (
    <ErrorBoundary fallback={<div>Something went wrong.</div>}>
      <<ContainerName>Content {...props} />
    </ErrorBoundary>
  );
}
```

---

### index.ts — lazy, with Suspense

```ts
import { lazy, Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';
import type { <ContainerName>ContentProps } from './<ContainerName>Content';

const <ContainerName>Content = lazy(() =>
  import('./<ContainerName>Content').then((m) => ({ default: m.<ContainerName>Content }))
);

export type <ContainerName>Props = <ContainerName>ContentProps;

export function <ContainerName>({ ...props }: <ContainerName>Props) {
  return (
    <ErrorBoundary fallback={<div>Something went wrong.</div>}>
      <Suspense fallback={<div>Loading...</div>}>
        <<ContainerName>Content {...props} />
      </Suspense>
    </ErrorBoundary>
  );
}
```

---

### index.ts — lazy, no Suspense

Lazy loading without Suspense is not valid — `lazy()` requires a `Suspense` boundary. If the user has asked for this combination, clarify: either add Suspense, or don't lazy-load.

---

### \<ContainerName\>Content.tsx

```tsx
export interface <ContainerName>ContentProps {
  // props passed in from the view (e.g. route params, render props)
}

export function <ContainerName>Content({ }: <ContainerName>ContentProps) {
  // Fetch data here using TanStack Query.
  // Render UI components here.
  // Accept child containers as render props, not imports.
  return null;
}
```

## Step 4 — Replace Placeholders

Substitute `<ContainerName>` with the actual name throughout both files.

Use the description of the container's purpose to:
- Add the correct props to `<ContainerName>ContentProps`
- Add a `useQuery` call if a specific query is already known
- Add a `render*` prop for any child containers the user mentioned

If the purpose is too vague to fill these in meaningfully, leave the placeholders with comments and note what the user should fill in.

## Step 5 — Report

Tell the user:
- The files created and their paths
- Which lazy/Suspense variant was used and why (one sentence each if non-default)
- Anything left for them to fill in (props, query, render props)
