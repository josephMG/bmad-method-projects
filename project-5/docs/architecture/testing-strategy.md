# Testing Strategy for BMad-FamilyExpenseTracker

This document outlines the comprehensive testing strategy for the `BMad-FamilyExpenseTracker` Flutter application, covering unit, widget, and integration tests, along with guidelines for test data management and coverage of edge cases and error scenarios.

## 1. Overall Testing Philosophy

Our goal is to ensure high code quality, prevent regressions, and facilitate confident future development through a robust testing suite. We adhere to the testing pyramid principle:

*   **Unit Tests:** Fast, isolated tests for individual functions, methods, and classes (e.g., data models, utility functions, business logic).
*   **Widget Tests:** Verify the behavior and appearance of individual UI widgets and small widget trees.
*   **Integration Tests:** Validate the interaction between multiple components, layers, or even the entire application flow, often involving mocked external services.
*   **End-to-End (E2E) Tests:** (Future consideration) Verify the entire application flow against real external services (e.g., actual Google Sheets API) in a controlled environment.

## 2. Testing Frameworks and Tools

*   **Flutter Test:** The primary testing framework for Dart and Flutter.
*   **Mockito:** For creating mock objects and verifying interactions with dependencies.
*   **Flutter Riverpod Test:** For testing Riverpod providers and state management logic.
*   **Integration Test:** Flutter's package for writing integration tests.

## 3. Unit Testing Guidelines

### 3.1 Scope

*   **Data Models:** Test constructors, factory methods (e.g., `fromGoogleSheetRow`), `copyWith`, `toJson`, `isValid`, and any custom logic within the model.
*   **Services/Repositories:** Test business logic, data transformations, and interactions with external dependencies (mocked).
*   **Providers (Riverpod):** Test initial state, state changes in response to actions, and correct dependency injection.
*   **Utility Functions:** Test pure functions for expected inputs and outputs.

### 3.2 Mocking Strategy

*   Use `mockito` to create mock implementations of dependencies (e.g., `GoogleSheetsService`, `AuthRepository`).
*   Mock external services at the boundary of the unit under test to ensure isolation.
*   Use `build_runner` to generate mock classes (`.mocks.dart` files).

## 4. Widget Testing Guidelines

### 4.1 Scope

*   Test individual UI widgets or small, self-contained widget trees.
*   Verify widget rendering, user interactions (taps, gestures, text input), and state changes reflected in the UI.
*   Ensure widgets respond correctly to different states of their dependencies (e.g., loading, error, data available).

### 4.2 Mocking and Provider Overrides

*   Use `ProviderScope` with `overrides` to inject mocked dependencies (e.g., `mockAuthRepository`, `mockGoogleSheetsService`) into the widget tree.
*   Override providers that fetch data or interact with external services to control the data presented to the widget.

## 5. Integration Testing Guidelines

### 5.1 Scope

*   Verify the interaction between multiple layers of the application (e.g., UI, state management, data layer).
*   Simulate user flows through significant parts of the application.
*   Often involves mocking external services to ensure test stability and speed, while still verifying the integration points.

### 5.2 Test Data Management for Integration Tests

*   **Controlled Mocks:** For integration tests that involve external services (like Google Sheets), use `mockito` to precisely control the data returned by these services.
*   **Scenario-Based Data:** Define specific mock data sets for different test scenarios (e.g., empty sheet, sheet with one expense, sheet with multiple categories, malformed data).
*   **Clear Setup/Teardown:** Ensure `setUp` and `tearDown` methods properly initialize and clean up mock states to prevent test interference.

## 6. Edge Case and Error Scenario Coverage

*   **Explicitly Test Error Paths:** For every function or method that can throw an exception or return an error state, write tests that specifically trigger and verify the handling of these errors.
    *   Examples: Network errors, API errors (`GoogleSheetsApiException`), validation errors (`ValidationException`), unauthorized access (`UnauthorizedException`), data not found scenarios.
*   **Edge Cases for Data:** Test with empty lists, null values (where applicable), boundary conditions (e.g., minimum/maximum amounts, dates).
*   **UI Error States:** Verify that the UI correctly displays error messages or appropriate fallback UI when underlying data or services encounter issues.
*   **User Input Validation:** Ensure all user input fields have robust validation and that invalid inputs are handled gracefully (e.g., showing error messages, disabling buttons).

## 7. Test Coverage Expectations

*   **Target:** Aim for high test coverage (e.g., >80%) for critical business logic, data models, and core services.
*   **Focus on Value:** Prioritize testing complex logic, critical user flows, and areas prone to bugs over achieving a high percentage for trivial code.
*   **Measurement:** Use Flutter's built-in coverage tools to monitor and report test coverage.

## 8. CI/CD Integration (Future)

*   Automate test execution as part of the CI/CD pipeline.
*   Enforce minimum test coverage thresholds for pull requests.
*   Generate test reports for easy analysis.
