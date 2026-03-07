# TypeScript Conventions

## Rules

- **No `any`**. Use `unknown` and narrow, or fix the types properly.
- **No type assertions** (`as Foo`) unless at a validated API boundary with a comment explaining why.
- **Infer from Zod schemas** at API boundaries. Don't write duplicate `interface`/`type` definitions.
- **Prefer `type` over `interface`** for consistency. Use `interface` only when you need declaration merging.
- **Name types after the domain concept**, not the shape — `UserProfile`, not `UserProfileObject`.
- **Generic names**: `T` for single generics, descriptive names (`TData`, `TError`) for multiple.
- **Avoid enums**. Use `as const` objects with a derived union type instead.

```ts
// Do this
const Role = { Admin: 'admin', User: 'user' } as const;
type Role = typeof Role[keyof typeof Role];

// Not this
enum Role { Admin = 'admin', User = 'user' }
```
