# Authentication Components

This document details the architecture and implementation of authentication-related components within the `nextjs-frontend` application.

## LoginForm Component

### Overview
The `LoginForm` component (`nextjs-frontend/src/components/auth/LoginForm.tsx`) is responsible for handling user login. It provides a user interface for entering email/username and password, performs client-side validation, and interacts with the backend API to authenticate the user.

### Key Features
-   **Client-Side Validation:** Utilizes `react-hook-form` and `zod` for robust input validation.
-   **Material-UI Integration:** Built using Material-UI components for a consistent and accessible UI.
-   **API Interaction:** Integrates with RTK Query (`useLoginMutation`) to send login credentials to the `/api/v1/token` endpoint.
-   **State Management:** Manages local form state with `react-hook-form` and global authentication state (JWT handling, user session) via Redux Toolkit.
-   **Error Handling:** Displays user-friendly error messages for invalid credentials or API failures.
-   **Redirection:** Redirects to the dashboard upon successful login.
-   **Accessibility:** Adheres to WCAG 2.1 AA standards with proper ARIA labels and keyboard navigation support.

### Dependencies
-   `@mui/material`: UI components.
-   `react-hook-form`: Form management and validation.
-   `@hookform/resolvers/zod`: Zod integration with React Hook Form.
-   `zod`: Schema validation library.
-   `next/navigation`: For client-side routing (`useRouter`).
-   `@/redux/features/auth/authSlice`: RTK Query mutation hook for login.

### Usage
The `LoginForm` component is integrated into the `LoginPage` (`nextjs-frontend/src/app/login/page.tsx`).

```typescript
// nextjs-frontend/src/app/login/page.tsx
import LoginForm from '@/components/auth/LoginForm';

export default function LoginPage() {
  return (
    // ... other UI elements
    <LoginForm />
    // ...
  );
}
```

### Testing
-   **Unit Tests:** Located in `nextjs-frontend/tests/unit/LoginForm.test.tsx`, covering component rendering, client-side validation, error display, XSS prevention, and accessibility.
-   **Integration Tests:** Located in `nextjs-frontend/tests/integration/LoginForm.integration.test.tsx`, covering API interaction, successful login, and error handling scenarios with mocked API responses.
