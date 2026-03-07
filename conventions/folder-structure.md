# Folder Structure

Feature-based. Group by what the code does, not what type of file it is.

```
src/
├── routes/          # TanStack Router file-based routes
├── features/        # Feature modules — most code lives here
│   └── [feature]/
│       ├── components/
│       ├── hooks/
│       ├── api/     # Query/mutation definitions for this feature
│       └── types.ts
├── components/
│   └── ui/          # shadcn/ui components (owned, not third-party)
├── hooks/           # App-wide shared hooks only
├── lib/             # Utilities, clients, config
│   ├── api.ts       # Fetch wrapper
│   └── queryKeys.ts # All TanStack Query keys
└── types/           # Shared TypeScript types
```

## Rules

- If something is used by only one feature, it lives inside that feature folder.
- Move to `src/` root only when genuinely shared across 3+ features.
- Don't create a `utils/` dumping ground. Name folders by domain (`formatting/`, `validation/`).
