# Routing Stack

**TanStack Router**

Type-safe routing with file-based route definitions. No React Router.

## Key Conventions

- Use file-based routing. Routes live in `src/routes/`.
- Loaders handle data fetching at the route level for initial page data. TanStack Query handles subsequent fetches and cache.
- Route params and search params are typed and validated with Zod.
- Protected routes use a layout route with an auth guard — don't scatter auth checks across leaf routes.
