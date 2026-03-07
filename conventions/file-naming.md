# File Naming

| Thing | Convention | Example |
|---|---|---|
| Components | PascalCase | `UserAvatar.tsx` |
| Hooks | camelCase, `use` prefix | `useUserSession.ts` |
| Utilities | camelCase | `formatDate.ts` |
| Routes | kebab-case | `user-profile.tsx` |
| Types/interfaces | PascalCase | `UserProfile.ts` |
| Test files | Same name + `.test` | `UserAvatar.test.tsx` |
| Constants | camelCase file, SCREAMING_SNAKE values | `queryKeys.ts` → `USER_PROFILE` |

## Component Files

One component per file. File name matches the component name. Barrel exports (`index.ts`) at the feature level only, not inside component folders.
