### Story: Presenter Unit Tests

**Description:** As a developer, I need unit tests for the `CalculatorPresenter` to verify its data formatting and gesture handling logic.

**Prerequisites:** Story 5.

**Acceptance Criteria:**
*   Using mock objects, tests verify that raw `Decimal` values from the Interactor are correctly formatted into strings.
*   Tests verify that calls from the View (e.g., `didTapAdd()`) result in the correct methods being called on the mock Interactor.

**Effort:** 2 Story Points
