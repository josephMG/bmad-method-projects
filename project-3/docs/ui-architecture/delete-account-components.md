# Delete Account Components

This document details the architecture and implementation of account deletion-related components within the `nextjs-frontend` application.

## DeleteAccountForm Component

### Overview
The `DeleteAccountForm` component (`nextjs-frontend/src/components/auth/DeleteAccountForm.tsx`) is responsible for handling user account deletion. It provides a user interface for confirming deletion by re-entering the password, performs client-side validation, and interacts with the backend API to delete the user's account.

### Key Features
-   **Client-Side Validation:** Utilizes `react-hook-form` and `zod` for robust input validation, specifically for password re-entry.
-   **Material-UI Integration:** Built using Material-UI components for a consistent and accessible UI.
-   **API Interaction:** Integrates with RTK Query (`useDeleteUserAccountMutation`) to send the deletion request to the `/api/v1/users/me` endpoint.
-   **State Management:** Manages local form state with `react-hook-form`.
-   **Error Handling:** Displays user-friendly error messages for invalid input or API failures using Material-UI `Snackbar`.
-   **Accessibility:** Adheres to WCAG 2.1 AA standards with proper ARIA labels and keyboard navigation support.

### Dependencies
-   `@mui/material`: UI components.
-   `react-hook-form`: Form management and validation.
-   `@hookform/resolvers/zod`: Zod integration with React Hook Form.
-   `zod`: Schema validation library.
-   `@/store/user/userApi`: RTK Query mutation hook for deleting user account.

### Usage
The `DeleteAccountForm` component is integrated into the `DeleteAccountPage` (`nextjs-frontend/src/app/dashboard/settings/delete-account/page.tsx`).

```typescript
// nextjs-frontend/src/app/dashboard/settings/delete-account/page.tsx
import DeleteAccountForm from '@/components/auth/DeleteAccountForm';

export default function DeleteAccountPage() {
  // ... logic to handle account deletion and feedback
  return (
    <DeleteAccountForm onConfirm={handleConfirm} onCancel={handleCancel} isSubmitting={isDeleting} formError={error} />
  );
}
```

### Testing
-   **Unit Tests:** Located in `nextjs-frontend/tests/unit/DeleteAccountForm.test.tsx`, covering component rendering, client-side validation, error display, and accessibility.
-   **Integration Tests:** Located in `nextjs-frontend/tests/integration/DeleteAccount.integration.test.tsx`, covering API interaction, successful account deletion, and error handling scenarios with mocked API responses.
