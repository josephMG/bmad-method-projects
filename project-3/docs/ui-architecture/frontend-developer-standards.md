# Frontend Developer Standards

### Critical Coding Rules

**Universal Rules:**
- **Type Safety:** Always use TypeScript. Avoid `any` unless absolutely necessary and with clear justification.
- **Immutability:** Treat state as immutable. Always create new objects/arrays when updating state.
- **Readability:** Write clear, concise, and self-documenting code. Prioritize readability over cleverness.
- **Error Handling:** Implement robust error handling for API calls, form submissions, and unexpected scenarios.
- **Accessibility (A11y):** Design and implement components with accessibility in mind (e.g., semantic HTML, ARIA attributes, keyboard navigation).
- **Performance:** Optimize rendering, minimize re-renders, and use efficient data fetching strategies.
- **Security:** Never expose sensitive information on the client-side. Sanitize user input.

**Next.js/React/TypeScript Specific Rules:**
- **Functional Components & Hooks:** Prefer functional components and React Hooks over class components.
- **Component Composition:** Favor composition over inheritance for building UI.
- **Prop Drilling:** Avoid excessive prop drilling. Use Context API or Redux for global state.
- **Key Prop:** Always provide a unique `key` prop when rendering lists of elements.
- **Conditional Rendering:** Use clear and concise methods for conditional rendering (e.g., ternary operators, logical `&&`).
- **Absolute Imports:** Use absolute imports (e.g., `@/components/`) for better readability and refactoring.
- **ESLint & Prettier:** Adhere to ESLint and Prettier configurations for consistent code style.
- **RTK Query Usage:** All data fetching and mutations should primarily use RTK Query.
- **Server Components/Actions:** Leverage Next.js Server Components and Server Actions where appropriate for performance and security.

### Quick Reference

**Common Commands:**
```bash
npm run dev         # Start development server
npm run build       # Create production build
npm start           # Start production server
npm run lint        # Run ESLint
npm test            # Run Vitest tests
```

**Key Import Patterns:**
- **Absolute Imports:** Use `@/` alias for `src/` directory (e.g., `import { Button } from '@/components/ui/Button';`).
- **Relative Imports:** Use relative paths for files within the same directory or immediate subdirectories.

**File Naming Conventions:**
- **Components:** `PascalCase.tsx` (e.g., `Button.tsx`).
- **Hooks:** `usePascalCaseHook.ts` (e.g., `useAuth.ts`).
- **Redux Slices:** `kebab-case-slice.ts` (e.g., `auth-slice.ts`).
- **Pages/Layouts:** `page.tsx`, `layout.tsx`.
- **API Routes:** `route.ts`.

**Project-Specific Patterns and Utilities:**
- **State Management:** Use Redux Toolkit and RTK Query for all global state and API interactions.
- **Styling:** Primarily use Tailwind CSS utility classes. Extend theme via `src/app/globals.css` and `tailwind.config.js`.
- **Authentication:** JWT-based authentication handled via RTK Query's `prepareHeaders` and Redux `authSlice`.
- **Error Handling:** Centralized error handling in RTK Query base query and component-level error boundaries.