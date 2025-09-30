# User Profile Management Components

This document details the architecture and implementation of user profile management-related components within the `nextjs-frontend` application.

## ProfileForm Component

### Overview
The `ProfileForm` component (`nextjs-frontend/src/components/profile/ProfileForm.tsx`) is responsible for displaying and handling updates to the user's profile information. It provides a user interface for viewing and editing details like email and full name, performs client-side validation, and interacts with the backend API to update the user's profile.

### Key Features
-   **Client-Side Validation:** Utilizes `react-hook-form` and `zod` for robust input validation based on the `UserUpdate` schema.
-   **Material-UI Integration:** Built using Material-UI components for a consistent and accessible UI.
-   **API Interaction:** Integrates with RTK Query (`useUpdateUserProfileMutation`) to send updated profile data to the `/api/v1/users/me` endpoint.
-   **State Management:** Manages local form state with `react-hook-form` and updates global user profile state via Redux Toolkit (`userSlice`).
-   **Error Handling:** Displays user-friendly error messages for invalid input or API failures using Material-UI `Snackbar`.
-   **Accessibility:** Adheres to WCAG 2.1 AA standards with proper ARIA labels and keyboard navigation support.

### Dependencies
-   `@mui/material`: UI components.
-   `react-hook-form`: Form management and validation.
-   `@hookform/resolvers/zod`: Zod integration with React Hook Form.
-   `zod`: Schema validation library.
-   `@/store/user/userApi`: RTK Query mutation hook for updating user profile.
-   `@/store/user/userSlice`: Redux slice for managing user profile state.

### Usage
The `ProfileForm` component is integrated into the `ProfilePage` (`nextjs-frontend/src/app/dashboard/settings/profile/page.tsx`).

```typescript
// nextjs-frontend/src/app/dashboard/settings/profile/page.tsx
import ProfileForm from '@/components/profile/ProfileForm';

export default function ProfilePage() {
  // ... logic to fetch user and handle submission
  return (
    <ProfileForm user={user} onSubmit={handleSubmit} isSubmitting={isUpdating} />
  );
}
```

### Testing
-   **Unit Tests:** Located in `nextjs-frontend/tests/unit/ProfileForm.test.tsx`, covering component rendering, client-side validation, error display, and accessibility.
-   **Integration Tests:** Located in `nextjs-frontend/tests/integration/ProfileForm.integration.test.tsx`, covering API interaction, successful updates, and error handling scenarios with mocked API responses.