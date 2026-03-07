# Component Architecture

## Default Pattern: Small, Focused, Composable

Every component should do one thing. If you're scrolling to find the return statement, split the component.

## Props

- Prefer primitive props over object props for simple components.
- Use a `ComponentNameProps` type, not inline types.
- Don't pass props through more than two levels. If you're prop-drilling, reach for composition or context.

## Composition Over Configuration

Don't build a single component with 15 props controlling variants. Build composable pieces.

```tsx
// Prefer this
<Card>
  <CardHeader><CardTitle>Title</CardTitle></CardHeader>
  <CardContent>Content</CardContent>
</Card>

// Over this
<Card title="Title" content="Content" showHeader={true} headerVariant="large" />
```

## State Placement

- Keep state as close to where it's used as possible.
- Lift only when sibling components genuinely need to share it.
- Server state belongs in TanStack Query, not `useState`.

## When to Extract a Component

- The JSX is hard to read because it's too long — extract for readability.
- The exact same UI appears in 3+ places — extract to share.
- Not before.
