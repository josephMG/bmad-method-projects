# Component Standards

### Component Template

```typescript
// src/components/common/ExampleComponent/ExampleComponent.tsx
import React from 'react';

// Define props interface for type safety
interface ExampleComponentProps {
  /**
   * A descriptive prop for the component.
   */
  text: string;
  /**
   * Optional click handler.
   */
  onClick?: () => void;
}

/**
 * A reusable example component.
 *
 * @param {ExampleComponentProps} props - The props for the component.
 * @returns {JSX.Element} The rendered component.
 */
const ExampleComponent: React.FC<ExampleComponentProps> = ({ text, onClick }) => {
  return (
    <button
      className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
      onClick={onClick}
    >
      {text}
    </button>
  );
};

export default ExampleComponent;

// Path: src/components/common/ExampleComponent/index.ts
export { default } from './ExampleComponent';
```

### Naming Conventions

*   **Components:**
    *   **Files:** PascalCase (e.g., `Button.tsx`, `UserProfileCard.tsx`).
    *   **Folders:** PascalCase for component-specific folders (e.g., `Button/`, `UserProfileCard/`).
    *   **Index files:** `index.ts` or `index.tsx` for barrel exports within component folders.
*   **Pages (App Router):**
    *   **Files:** `page.tsx` for route segments, `layout.tsx` for layouts, `loading.tsx` for loading UI, `error.tsx` for error UI.
    *   **Folders:** Kebab-case for route segments (e.g., `dashboard/`, `user-profile/`).
*   **API Routes (App Router):**
    *   **Files:** `route.ts` for API route handlers.
    *   **Folders:** Kebab-case for API route segments (e.g., `api/users/`).
*   **Hooks:**
    *   **Files:** `usePascalCaseHook.ts` (e.g., `useAuth.ts`, `useDebounce.ts`).
*   **Contexts:**
    *   **Files:** `PascalCaseContext.tsx` (e.g., `AuthContext.tsx`).
*   **Redux Slices (if Redux Toolkit is used):**
    *   **Files:** `kebab-case-slice.ts` (e.g., `auth-slice.ts`, `user-slice.ts`).
    *   **Names:** CamelCase (e.g., `authSlice`, `userSlice`).
*   **Utility Functions/Helpers:**
    *   **Files:** `camelCase.ts` or `kebab-case.ts` (e.g., `formatDate.ts`, `api-client.ts`).
*   **Types/Interfaces:**
    *   **Files:** `types.ts` or `interfaces.ts` for global types, or co-located with components/modules.
    *   **Names:** PascalCase for interfaces and types (e.g., `User`, `ProductProps`).
*   **Environment Variables:**
    *   **Names:** SCREAMING_SNAKE_CASE (e.g., `NEXT_PUBLIC_API_BASE_URL`).