# nextjs-frontend Frontend Architecture Document

## Introduction

This document outlines the architectural decisions and guidelines for the `nextjs-frontend` application. It serves as a comprehensive reference for developers and AI agents, ensuring consistency, maintainability, and scalability across the frontend codebase.

### Document Scope

Focused on areas relevant to: stories 2.1-2.6 (Next.js Frontend Dockerization, User Registration, User Login, User Profile Management, Change Password, Delete User Account)

### Change Log

| Date | Version | Description | Author |
|---|---|---|---|
| 2025-09-27 | 1.0 | Initial frontend architecture document | Winston (Architect) |

## Frontend Tech Stack

### Technology Stack Table

| Category | Technology | Version | Purpose | Rationale |
| :--- | :--- | :--- | :--- | :--- |
| **Framework** | Next.js | 15.5.4 | React framework for frontend | Provides server-side rendering, static site generation, and a great developer experience for React applications. |
| **UI Library** | Material-UI | latest | React UI component library | Comprehensive suite of UI tools to implement Google's Material Design. (Assumed from PRD/previous stories, not explicitly in `package.json` yet) |
| **State Management** | Redux Toolkit | latest | State management for React | Official opinionated toolset for efficient Redux development. (Assumed from PRD/previous stories, not explicitly in `package.json` yet) |
| **Routing** | Next.js Router | Built-in | Client-side routing | Handles navigation within the Next.js application. |
| **Build Tool** | Next.js / Webpack | Built-in | Bundling and transpilation | Manages the build process for the Next.js application. |
| **Styling** | Tailwind CSS | 4 | Utility-first CSS framework | For rapid UI development and consistent styling. (Found in `package.json` and `postcss.config.mjs`) |
| **Testing** | Vitest, React Testing Library, Jest-DOM | 1.6.0, 16.0.0, 6.4.6 | Unit and integration testing | Fast unit testing with Vite, component testing with React Testing Library, and DOM matchers with Jest-DOM. (Found in `package.json` and `vitest.config.ts`) |
| **Component Library** | Material-UI | latest | React UI component library | Comprehensive suite of UI tools to implement Google's Material Design. (Assumed from PRD/previous stories, not explicitly in `package.json` yet) |
| **Form Handling** | (To be determined) | N/A | Managing form state and validation | Will need to be selected based on project needs. |
| **Animation** | (To be determined) | N/A | Adding animations and transitions | Will need to be selected based on project needs. |
| **Dev Tools** | ESLint | 9 | Code linting | For maintaining code quality and consistency. (Found in `package.json` and `eslint.config.mjs`) |

## Project Structure

```plaintext
nextjs-frontend/
├── .next/                  # Next.js build output (ignored)
├── node_modules/           # Project dependencies (ignored)
├── public/                 # Static assets (images, fonts)
│   ├── file.svg
│   ├── globe.svg
│   ├── next.svg
│   ├── vercel.svg
│   └── window.svg
├── src/                    # Main application source code
│   ├── app/                # Next.js App Router (pages, layouts, API routes)
│   │   ├── favicon.ico
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/         # Reusable UI components (e.g., buttons, cards, forms)
│   │   ├── auth/           # Authentication-related components (Login, Register, etc.)
│   │   └── common/         # Generic components
│   ├── hooks/              # Custom React hooks
│   ├── lib/                # Utility functions, helpers, API clients
│   ├── styles/             # Global styles, Tailwind config extensions
│   ├── types/              # TypeScript type definitions
│   └── utils/              # General utilities
├── tests/                  # Test files
│   ├── __mocks__/          # Mock files for testing
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   └── example.test.tsx
├── .gitignore              # Git ignore rules
├── Dockerfile.dev          # Dockerfile for development environment
├── Dockerfile.prod         # Dockerfile for production environment
├── Dockerfile.test         # Dockerfile for test environment
├── eslint.config.mjs       # ESLint configuration
├── next.config.ts          # Next.js configuration
├── package-lock.json       # npm lock file
├── package.json            # Project dependencies and scripts
├── postcss.config.mjs      # PostCSS configuration (for Tailwind)
├── README.md               # Project README
├── tsconfig.json           # TypeScript configuration
└── vitest.config.ts        # Vitest configuration
└── vitest.setup.ts         # Vitest setup file
```

## Component Standards

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

## State Management

### Store Structure

```plaintext
src/
├── store/
│   ├── index.ts            # Redux store configuration
│   ├── hooks.ts            # Typed Redux hooks (useAppDispatch, useAppSelector)
│   ├── auth/               # Auth feature slice
│   │   ├── authSlice.ts    # Auth reducer, actions, selectors
│   │   └── authApi.ts      # RTK Query API slice for auth
│   ├── user/               # User feature slice
│   │   ├── userSlice.ts    # User reducer, actions, selectors
│   │   └── userApi.ts      # RTK Query API slice for user
│   ├── common/             # Common/global slices (e.g., notifications)
│   │   └── notificationSlice.ts
│   └── types.ts            # Global Redux types
```

### State Management Template

```typescript
// src/store/auth/authSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { RootState } from '../index'; // Assuming RootState is defined in src/store/index.ts

interface AuthState {
  isAuthenticated: boolean;
  user: { id: string; email: string } | null;
  token: string | null;
  isLoading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  isAuthenticated: false,
  user: null,
  token: null,
  isLoading: false,
  error: null,
};

export const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setCredentials: (
      state,
      action: PayloadAction<{ user: { id: string; email: string }; token: string }>
    ) => {
      state.isAuthenticated = true;
      state.user = action.payload.user;
      state.token = action.payload.token;
      state.isLoading = false;
      state.error = null;
    },
    logout: (state) => {
      state.isAuthenticated = false;
      state.user = null;
      state.token = null;
      state.isLoading = false;
      state.error = null;
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
  },
  // Extra reducers for handling RTK Query lifecycle actions
  extraReducers: (builder) => {
    // Example: Handle pending/fulfilled/rejected states from an RTK Query endpoint
    // builder.addMatcher(authApi.endpoints.login.matchPending, (state) => {
    //   state.isLoading = true;
    // });
    // builder.addMatcher(authApi.endpoints.login.matchFulfilled, (state, action) => {
    //   state.isLoading = false;
    //   state.isAuthenticated = true;
    //   state.user = action.payload.user;
    //   state.token = action.payload.token;
    // });
    // builder.addMatcher(authApi.endpoints.login.matchRejected, (state, action) => {
    //   state.isLoading = false;
    //   state.error = action.error?.message || 'Login failed';
    // });
  },
});

export const { setCredentials, logout, setLoading, setError } = authSlice.actions;

export const selectIsAuthenticated = (state: RootState) => state.auth.isAuthenticated;
export const selectCurrentUser = (state: RootState) => state.auth.user;
export const selectAuthToken = (state: RootState) => state.auth.token;
export const selectAuthLoading = (state: RootState) => state.auth.isLoading;
export const selectAuthError = (state: RootState) => state.auth.error;

export default authSlice.reducer;
```

```typescript
// src/store/auth/authApi.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

interface LoginRequest {
  email: string;
  password: string;
}

interface LoginResponse {
  access_token: string;
  token_type: string;
  user: { id: string; email: string };
}

export const authApi = createApi({
  reducerPath: 'authApi',
  baseQuery: fetchBaseQuery({
    baseUrl: process.env.NEXT_PUBLIC_API_BASE_URL, // Assuming this env var is set
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token; // Access token from auth slice
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  endpoints: (builder) => {
    // Example: login mutation
    login: builder.mutation<LoginResponse, LoginRequest>({
      query: (credentials) => ({
        url: '/token',
        method: 'POST',
        body: credentials,
      }),
      async onQueryStarted(credentials, { dispatch, queryFulfilled }) {
        try {
          const { data } = await queryFulfilled;
          dispatch(authSlice.actions.setCredentials({ user: data.user, token: data.access_token }));
        } catch (error) {
          dispatch(authSlice.actions.setError('Login failed'));
        }
      },
    }),
    // Example: get user profile query
    getProfile: builder.query<{ id: string; email: string }, void>({
      query: () => '/users/me',
    }),
  },
});

export const { useLoginMutation, useGetProfileQuery } = authApi;
```

## API Integration

### Service Template

```typescript
// src/store/auth/authApi.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

interface LoginRequest {
  email: string;
  password: string;
}

interface LoginResponse {
  access_token: string;
  token_type: string;
  user: { id: string; email: string };
}

export const authApi = createApi({
  reducerPath: 'authApi',
  baseQuery: fetchBaseQuery({
    baseUrl: process.env.NEXT_PUBLIC_API_BASE_URL, // Assuming this env var is set
    prepareHeaders: (headers, { getState }) => {
      const token = (getState() as RootState).auth.token; // Access token from auth slice
      if (token) {
        headers.set('authorization', `Bearer ${token}`);
      }
      return headers;
    },
  }),
  endpoints: (builder) => ({
    login: builder.mutation<LoginResponse, LoginRequest>({
      query: (credentials) => ({
        url: '/token', // Assuming /api/v1/token is the full path
        method: 'POST',
        body: credentials,
      }),
      async onQueryStarted(credentials, { dispatch, queryFulfilled }) {
        try {
          const { data } = await queryFulfilled;
          dispatch(authSlice.actions.setCredentials({ user: data.user, token: data.access_token }));
        } catch (error) {
          dispatch(authSlice.actions.setError('Login failed'));
        }
      },
    }),
    getProfile: builder.query<{ id: string; email: string }, void>({
      query: () => '/users/me', // Assuming /api/v1/users/me is the full path
    }),
  }),
});

export const { useLoginMutation, useGetProfileQuery } = authApi;
```

### API Client Configuration

```typescript
// Example from src/store/auth/authApi.ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import { RootState } from '../index'; // Assuming RootState is defined

export const baseQuery = fetchBaseQuery({
  baseUrl: process.env.NEXT_PUBLIC_API_BASE_URL, // Base URL from environment variable
  prepareHeaders: (headers, { getState }) => {
    const token = (getState() as RootState).auth.token; // Get token from Redux store
    if (token) {
      headers.set('authorization', `Bearer ${token}`); // Attach token for authenticated requests
    }
    return headers;
  },
});

// Example of a custom baseQuery with global error handling (optional)
// const baseQueryWithReauth: BaseQueryFn<
//   string | FetchArgs,
//   unknown,
//   FetchBaseQueryError
// > = async (args, api, extraOptions) => {
//   let result = await baseQuery(args, api, extraOptions);
//   if (result.error && result.error.status === 401) {
//     // try to get a new token
//     // const refreshResult = await baseQuery('/refreshToken', api, extraOptions);
//     // if (refreshResult.data) {
//     //   api.dispatch(tokenReceived(refreshResult.data));
//     //   // retry the original query with new access token
//     //   result = await baseQuery(args, api, extraOptions);
//     // }
//   }
//   return result;
// };

// Then use baseQueryWithReauth in createApi:
// export const authApi = createApi({
//   reducerPath: 'authApi',
//   baseQuery: baseQueryWithReauth,
//   endpoints: (builder) => ({ ... }),
// });
```

## Routing

### Route Configuration

```plaintext
src/app/
├── layout.tsx          # Root layout
├── page.tsx            # Home page
├── login/
│   ├── page.tsx        # Login page
├── register/
│   ├── page.tsx        # Registration page
├── dashboard/
│   ├── layout.tsx      # Dashboard layout
│   ├── page.tsx        # Dashboard home
│   ├── settings/
│   │   ├── page.tsx    # Dashboard settings page
│   │   └── profile/
│   │       ├── page.tsx # User profile page
│   │       └── change-password/
│   │           ├── page.tsx # Change password page
│   └── delete-account/
│       ├── page.tsx    # Delete account page
├── api/                # API Routes (Next.js API handlers)
│   ├── users/
│   │   ├── route.ts    # Example: /api/users
│   └── auth/
│       ├── route.ts    # Example: /api/auth/login
```

## Styling Guidelines

### Styling Approach

```typescript
// Example of a styled button component
import React from 'react';

interface ButtonProps {
  children: React.ReactNode;
  primary?: boolean;
  onClick?: () => void;
}

const Button: React.FC<ButtonProps> = ({ children, primary = false, onClick }) => {
  const baseStyles = "px-4 py-2 rounded-md font-semibold transition-colors duration-200";
  const primaryStyles = "bg-blue-600 text-white hover:bg-blue-700";
  const secondaryStyles = "bg-gray-200 text-gray-800 hover:bg-gray-300";

  return (
    <button
      className={`${baseStyles} ${primary ? primaryStyles : secondaryStyles}`}
      onClick={onClick}
    >
      {children}
    </button>
  );
};

export default Button;
```

### Global Theme Variables

```css
/* src/app/globals.css */
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";

:root {
  /* Colors */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-500: #3b82f6;
  --color-primary-700: #1d4ed8;
  --color-secondary-50: #f0f9ff;
  --color-secondary-100: #e0f2fe;
  --color-secondary-500: #0ea5e9;
  --color-secondary-700: #0369a1;

  /* Text Colors */
  --color-text-default: #171717;
  --color-text-muted: #6b7280;
  --color-text-inverted: #ffffff;

  /* Background Colors */
  --color-background-default: #ffffff;
  --color-background-alt: #f9fafb;

  /* Spacing (using Tailwind's default scale or custom) */
  --spacing-xs: 0.25rem; /* 4px */
  --spacing-sm: 0.5rem;  /* 8px */
  --spacing-md: 1rem;    /* 16px */
  --spacing-lg: 1.5rem;  /* 24px */
  --spacing-xl: 2rem;    /* 32px */

  /* Typography */
  --font-family-sans: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
  --font-family-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
  --font-size-base: 1rem; /* 16px */
  --line-height-base: 1.5;

  /* Border Radius */
  --border-radius-sm: 0.25rem;
  --border-radius-md: 0.5rem;

  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Dark Mode Support */
@media (prefers-color-scheme: dark) {
  :root {
    --color-text-default: #ededed;
    --color-text-muted: #a0a0a0;
    --color-text-inverted: #171717;
    --color-background-default: #0a0a0a;
    --color-background-alt: #1a1a1a;
  }
}

/* Example of extending Tailwind's theme to use CSS variables */
// tailwind.config.js (or similar)
// module.exports = {
//   theme: {
//     extend: {
//       colors: {
//         primary: {
//           50: 'var(--color-primary-50)',
//           100: 'var(--color-primary-100)',
//           500: 'var(--color-primary-500)',
//           700: 'var(--color-primary-700)',
//         },
//         background: {
//           DEFAULT: 'var(--color-background-default)',
//           alt: 'var(--color-background-alt)',
//         },
//         text: {
//           DEFAULT: 'var(--color-text-default)',
//           muted: 'var(--color-text-muted)',
//           inverted: 'var(--color-text-inverted)',
//         },
//       },
//       spacing: {
//         xs: 'var(--spacing-xs)',
//         sm: 'var(--spacing-sm)',
//         md: 'var(--spacing-md)',
//         lg: 'var(--spacing-lg)',
//         xl: 'var(--spacing-xl)',
//       },
//       borderRadius: {
//         sm: 'var(--border-radius-sm)',
//         md: 'var(--border-radius-md)',
//       },
//       boxShadow: {
//         sm: 'var(--shadow-sm)',
//         md: 'var(--shadow-md)',
//       },
//     },
//   },
// };
```

## Testing Requirements

### Component Test Template

```typescript
// src/components/auth/LoginForm/LoginForm.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import LoginForm from './LoginForm'; // Assuming LoginForm component

describe('LoginForm', () => {
  it('renders the login form with email and password fields', () => {
    render(<LoginForm onSubmit={() => {}} />);

    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /log in/i })).toBeInTheDocument();
  });

  it('calls onSubmit with correct credentials when form is submitted', async () => {
    const handleSubmit = vi.fn();
    render(<LoginForm onSubmit={handleSubmit} />);

    const emailInput = screen.getByLabelText(/email/i);
    const passwordInput = screen.getByLabelText(/password/i);
    const submitButton = screen.getByRole('button', { name: /log in/i });

    fireEvent.change(emailInput, { target: { value: 'test@example.com' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });
    fireEvent.click(submitButton);

    expect(handleSubmit).toHaveBeenCalledTimes(1);
    expect(handleSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123',
    });
  });

  it('displays validation errors for invalid input', async () => {
    render(<LoginForm onSubmit={() => {}} />);

    const emailInput = screen.getByLabelText(/email/i);
    const submitButton = screen.getByRole('button', { name: /log in/i });

    fireEvent.change(emailInput, { target: { value: 'invalid-email' } });
    fireEvent.click(submitButton);

    expect(await screen.findByText(/invalid email format/i)).toBeInTheDocument();
    expect(screen.queryByText(/password is required/i)).toBeInTheDocument(); // Assuming basic validation
  });
});
```

### Testing Best Practices

*   **Unit Tests**: Test individual components, functions, and hooks in isolation. Mock all external dependencies (API calls, Redux store, router).
*   **Integration Tests**: Test the interaction between multiple components or between components and external services (e.g., Redux store, API mocks).
*   **End-to-End (E2E) Tests**: Use Cypress to test critical user flows across the entire application, simulating real user interactions in a browser environment.
*   **Coverage Goals**: Aim for 80% code coverage for unit and integration tests.
*   **Test Structure**: Follow the Arrange-Act-Assert pattern for clear and readable tests.
*   **Mock External Dependencies**: Always mock API calls, routing, and state management interactions in unit tests to ensure isolation.
*   **User-Centric Testing**: Use React Testing Library to test components from a user's perspective, focusing on accessibility and usability.
*   **Performance**: Ensure tests run quickly to facilitate a fast feedback loop during development.
*   **CI/CD Integration**: Integrate all tests (unit, integration, E2E) into the CI/CD pipeline to prevent regressions and ensure code quality.

## Environment Configuration

### Required Environment Variables
- `NEXT_PUBLIC_API_BASE_URL`: The base URL for the backend API (e.g., `http://app:8000/api/v1` when running with `docker-compose`).

### Example `.env.local` (for local development outside of docker-compose):
```
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000/api/v1
```

### Example `docker-compose.yml` (for development with Docker):
```yaml
  nextjs-frontend:
    # ... other configurations ...
    environment:
      NEXT_PUBLIC_API_BASE_URL: http://app:8000/api/v1
```

## Frontend Developer Standards

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
