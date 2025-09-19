### Story: Division by Zero Error Handling

**Description:** As a user, if I attempt to divide a number by zero, I want to see a clear error message on the display.

**Prerequisites:** Story 5.

**Acceptance Criteria:**
*   If the user attempts to perform a division by zero, the Interactor detects the error.
*   The Interactor notifies the Presenter of a `CalculationError.divisionByZero`.
*   The Presenter formats an appropriate error message (e.g., "Error").
*   The `CalculatorView` displays the error message.

**Effort:** 2 Story Points
