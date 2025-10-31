# Coding Standards for BMad-FamilyExpenseTracker

This document outlines the coding standards and best practices for the `BMad-FamilyExpenseTracker` Flutter project. Adherence to these standards ensures code quality, maintainability, and consistency across the development team.

## 1. General Principles

*   **Readability:** Code should be easy to read and understand.
*   **Maintainability:** Code should be easy to modify and extend.
*   **Consistency:** Follow established patterns and conventions.
*   **Performance:** Write efficient code, especially for UI and data operations.
*   **Testability:** Design code to be easily testable.

## 2. Language & Framework Specific Standards

### 2.1 Dart Language

*   Follow effective Dart guidelines: [https://dart.dev/guides/language/effective-dart](https://dart.dev/guides/language/effective-dart)
*   Use `dart format` for automatic code formatting.
*   Prefer `const` over `final` and `final` over `var` or `dynamic` where possible.
*   Use `late` keyword judiciously.
*   Avoid `as` casts; prefer `is` checks and type promotion.

### 2.2 Flutter Framework

*   **Widget Structure:**
    *   Break down complex UIs into smaller, reusable widgets.
    *   Prefer `StatelessWidget` where state is not managed internally.
    *   Use `StatefulWidget` only when necessary for mutable state.
*   **UI/UX:**
    *   Adhere to **Material 3 Design** guidelines for a consistent and modern look and feel.
    *   Ensure responsiveness across different screen sizes and orientations.
    *   Provide clear visual feedback for user interactions.
    *   **UI/UX for Synchronization Feedback:**
        *   **Loading Indicators:** Use subtle, non-blocking loading indicators (e.g., small spinners, progress bars) to show that data is being fetched or processed. Avoid full-screen blockers unless absolutely necessary.
        *   **Contextual Messages:** Display clear, concise messages like "Syncing...", "Loading data...", or "Refreshing..." near the affected UI elements.
        *   **Success Feedback:** Provide brief, temporary visual cues for successful synchronization (e.g., a checkmark icon, a toast message "Data synced!") that fade away after a few seconds.
        *   **Error Feedback:** For sync failures, display user-friendly, actionable error messages that explain what went wrong and suggest next steps (e.g., "Network error, please try again.", "Failed to sync with Google Sheets.").
        *   **Consistency:** Ensure that synchronization feedback elements (indicators, messages, placement) are consistent across the application.
*   **State Management:**
    *   Consistently use **Riverpod** (preferred) or **Provider** for managing application state.
    *   Separate UI logic from business logic.
    *   Define providers clearly and scope them appropriately.

## 3. Architecture & Design Patterns

*   **Modular Architecture:** Organize code into logical modules (e.g., features, services, models, widgets).
*   **Repository Pattern:** Abstract data sources (e.g., Google Sheets API) behind a repository interface to decouple the UI/business logic from the data layer. This facilitates future backend changes.
*   **Dependency Injection:** Use Riverpod's provider system for dependency injection.

## 4. Naming Conventions

*   **Files:** `snake_case` (e.g., `expense_repository.dart`).
*   **Classes:** `PascalCase` (e.g., `ExpenseRepository`, `CategoryModel`).
*   **Functions/Methods:** `camelCase` (e.g., `fetchExpenses`, `updateCategory`).
*   **Variables/Parameters:** `camelCase` (e.g., `expenseAmount`, `categoryName`).
*   **Constants:** `SCREAMING_SNAKE_CASE` for global constants (e.g., `API_KEY`), `camelCase` for local `const` or `final` variables.

## 5. Documentation & Comments

*   Use Dartdoc comments (`///`) for public APIs (classes, methods, properties).
*   Explain *why* a piece of code exists or a particular decision was made, rather than *what* it does (which should be evident from the code itself).
*   Keep comments concise and up-to-date.

## 6. Error Handling

*   Implement a global error handling strategy.
*   Catch and log errors gracefully.
*   Provide clear and user-friendly error messages.

## 7. Testing

*   Write unit tests for business logic, data models, and services.
*   Write widget tests for UI components.
*   Write integration tests for critical end-to-end flows.
*   Aim for good test coverage, focusing on critical paths and complex logic.
