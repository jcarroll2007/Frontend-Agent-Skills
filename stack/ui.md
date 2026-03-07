# UI Stack

**Tailwind CSS + shadcn/ui**

Tailwind for all styling. shadcn/ui for component primitives. No CSS-in-JS, no styled-components.

## Tailwind

Use CSS variables for design tokens (colors, spacing, radius) so themes are swappable. Define tokens in `globals.css`, reference them in `tailwind.config.ts`.

## shadcn/ui

Use as the component foundation. Components are copied into the project (`components/ui/`) and owned — modify them freely. Don't treat them as a locked dependency.

## Icons

Lucide React. Consistent with shadcn/ui defaults.

## No custom component library

Build features with shadcn/ui primitives + Tailwind. Extract to shared components only when the same UI pattern appears 3+ times.
