### Story: Clear Functionality

**Description:** As a user, I want to be able to clear the current input and reset the calculator by tapping the "C" button.

**Prerequisites:** Story 5.

**Acceptance Criteria:**
*   Tapping the "C" button triggers the `clear()` function in the Interactor via the Presenter.
*   The Interactor's `CalculationState` is reset to its default values.
*   The display on the `CalculatorView` updates to show "0".

**Effort:** 1 Story Point
