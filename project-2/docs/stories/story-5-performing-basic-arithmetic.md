### Story: Performing Basic Arithmetic

**Description:** As a user, I want to perform a calculation using two numbers and one operator.

**Prerequisites:** Story 4.

**Acceptance Criteria:**
*   The Interactor contains the logic to execute addition, subtraction, multiplication, and division.
*   When an operator button is tapped, the Presenter instructs the Interactor to set the pending operation.
*   When the "=" button is tapped, the Presenter instructs the Interactor to perform the calculation.
*   The Interactor calculates the result, updates its state, and passes the result back to the Presenter.
*   The Presenter formats and displays the final result in the View.
*   Example: `2 + 3 =` correctly displays `5`.

**Effort:** 5 Story Points
