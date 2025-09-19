### Story: Displaying Digit Input

**Description:** As a user, when I tap a digit button, I want to see that number appear on the display.

**Prerequisites:** Stories 1, 2, 3.

**Acceptance Criteria:**
*   Tapping a digit button on the `CalculatorView` forwards the action to the Presenter.
*   The Presenter instructs the Interactor to append the digit.
*   The Interactor updates its `CalculationState` and informs the Presenter of the new display value.
*   The Presenter formats the value into a string and updates the `displayText` property bound to the View.
*   The `CalculatorView` updates to show the correct sequence of digits (e.g., tapping "1", then "2", then "3" shows "123").

**Effort:** 3 Story Points
