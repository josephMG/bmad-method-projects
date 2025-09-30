# Change Password Components

This document details the architecture and implementation of change password-related components within the `nextjs-frontend` application.

## ChangePasswordForm Component

### Overview
The `ChangePasswordForm` component (`nextjs-frontend/src/components/auth/ChangePasswordForm.tsx`) is responsible for handling user password changes. It provides a user interface for entering current, new, and confirmed new passwords, performs client-side validation, and interacts with the backend API to update the user's password.

### Key Features
-   **Client-Side Validation:** Utilizes `react-hook-form` and `zod` for robust input validation, including password strength and matching new passwords.
-   **Material-UI Integration:** Built using Material-UI components for a consistent and accessible UI.
-   **API Interaction:** Integrates with RTK Query (`useChangePasswordMutation`) to send password change data to the `/api/v1/users/me/password` endpoint.
-   **State Management:** Manages local form state with `react-hook-form`.
-   **Error Handling:** Displays user-friendly error messages for invalid input or API failures using Material-UI `Snackbar`.
-   **Accessibility:** Adheres to WCAG 2.1 AA standards with proper ARIA labels and keyboard navigation support.

### Dependencies
-   `@mui/material`: UI components.
-   `react-hook-form`: Form management and validation.
-   `@hookform/resolvers/zod`: Zod integration with React Hook Form.
-   `zod`: Schema validation library.
-   `@/store/user/userApi`: RTK Query mutation hook for changing user password.

### Usage
The `ChangePasswordForm` component is integrated into the `ChangePasswordPage` (`nextjs-frontend/src/app/dashboard/settings/change-password/page.tsx`).

```typescript
// nextjs-frontend/src/app/dashboard/settings/change-password/page.tsx
import ChangePasswordForm from '@/components/auth/ChangePasswordForm';

export default function ChangePasswordPage() {
  // ... logic to handle password change and feedback
  return (
    <ChangePasswordForm onSubmit={handleSubmit} isSubmitting={isChangingPassword} />
  );
}
```

### Testing
-   **Unit Tests:** Located in `nextjs-frontend/tests/unit/ChangePasswordForm.test.tsx`, covering component rendering, client-side validation, error display, and accessibility.
-   **Integration Tests:** Located in `nextjs-frontend/tests/integration/ChangePasswordForm.integration.test.tsx`, covering API interaction, successful password changes, and error handling scenarios with mocked API responses.