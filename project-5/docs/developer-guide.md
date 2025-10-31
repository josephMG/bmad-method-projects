# Developer Guide for BMad-FamilyExpenseTracker

This guide provides comprehensive information for developers working on the `BMad-FamilyExpenseTracker` Flutter application. It covers project setup, architecture overview, key development practices, and how to contribute.

## 1. Getting Started

Refer to the main `README.md` in the `family_expense_tracker` directory for detailed instructions on:

*   **Environment Setup:** Installing Flutter, cloning the repository, and getting dependencies.
*   **Google Sheets API Setup:** Creating a Google Cloud Project, enabling the Google Sheets API, and setting up OAuth 2.0 Client IDs for Android and iOS.
*   **Running the Application:** How to launch the app on a device or emulator.

## 2. Project Architecture Overview

For a detailed understanding of the project's architectural principles, refer to the following documents in the `docs/architecture/` directory:

*   **`coding-standards.md`:** Coding conventions, Dart/Flutter best practices, and documentation guidelines.
*   **`source-tree.md`:** Detailed breakdown of the `lib/` directory structure and testing directory.
*   **`tech-stack.md`:** Overview of the technologies and frameworks used.

## 3. Key Development Practices

### 3.1 State Management

This project uses **Riverpod** for state management. Familiarize yourself with Riverpod's concepts:

*   `Provider`: For read-only values.
*   `StateProvider`: For simple mutable state.
*   `StateNotifierProvider`: For complex state logic.
*   `FutureProvider`/`StreamProvider`: For asynchronous data.

Ensure that UI logic is separated from business logic, and providers are scoped appropriately.

### 3.2 Data Flow

The application follows a Repository Pattern:

*   **UI (Presentation Layer):** Widgets and pages consume data from providers.
*   **Providers:** Interact with repositories to fetch/update data.
*   **Repositories (Data Layer):** Abstract data sources. Define interfaces for data operations.
*   **Data Sources:** Implementations of repositories, directly interacting with external services (e.g., `GoogleSheetsApiDataSource`).

### 3.3 Error Handling

Implement robust error handling throughout the application. Refer to `core/errors/app_exceptions.dart` for custom exception classes. All API calls should include `try-catch` blocks to handle potential network issues, API errors, and rate limits gracefully. Provide clear and user-friendly feedback for errors.

### 3.4 Testing

Adhere to the testing strategy outlined in `docs/architecture/coding-standards.md` and the story-specific testing requirements. Write unit tests for business logic, widget tests for UI components, and integration tests for critical end-to-end flows. Use `flutter test` to run tests and `mockito` for mocking dependencies.

## 4. Google Sheets API Integration Details

### 4.1 Authentication

Google OAuth is used for user authentication. The `auth_repository.dart` handles the sign-in and sign-out flows, and manages the secure storage and refresh of OAuth tokens.

### 4.2 API Usage and Rate Limits

*   **Minimize API Calls:** Design features to reduce the frequency of API calls to Google Sheets. Implement client-side caching for data that doesn't change frequently (e.g., categories) or for data within the currently viewed month.
*   **Batch Operations:** Where possible, use batch update operations provided by the Google Sheets API to reduce the number of individual requests.
*   **Error Handling for Rate Limits:** The application should gracefully handle `RateLimitException` by implementing retry mechanisms with exponential backoff. Inform the user when rate limits are encountered and suggest retrying after a cooldown period.

### 4.3 Data Structure and IDs

*   **Unique Record IDs:** Each expense record in Google Sheets is assigned a unique `RecordID` (UUID) by the application. This ID is crucial for reliably updating and deleting specific records.
*   **Hidden Columns:** `RecordID`, `RecordedBy`, `CreatedAt`, and `LastModified` are stored as hidden columns in the Google Sheet tabs to maintain data integrity and provide auditing information.

## 5. Rollback Procedures

For information on how to perform rollbacks for application deployments or data in Google Sheets, refer to `docs/architecture/rollback-procedures.md`.

## 6. Contributing

*   Follow the project's coding standards and architectural guidelines.
*   Write tests for all new features and bug fixes.
*   Ensure all tests pass and there are no linter warnings before submitting a pull request.
*   Document your code and any significant design decisions.

## 7. Developer Guides

For more in-depth developer documentation, refer to the following guides:

*   **[API Usage](developer_guides/API_USAGE.md):** Details on interacting with the Google Sheets API.
*   **[Data Models](developer_guides/DATA_MODELS.md):** Definitions of core data models like `Category` and `ExpenseRecord`.
*   **[State Management](developer_guides/STATE_MANAGEMENT.md):** Explanation of Riverpod and state management patterns.
*   **[Deployment](developer_guides/DEPLOYMENT.md):** Step-by-step instructions for deploying the application.
