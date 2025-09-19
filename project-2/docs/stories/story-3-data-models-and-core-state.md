### Story: Data Models and Core State

**Description:** As a developer, I need the core data models (Entities) to represent the calculator's state and operations.

**Prerequisites:** Story 2.

**Acceptance Criteria:**
*   The `CalculatorEntity.swift` file is created.
*   It contains the `CalculationState` struct to hold operands, operations, and the display value.
*   It contains the `Operation` enum for all arithmetic operations.
*   It contains the `CalculationError` enum for potential errors like `divisionByZero`.
*   The `CalculatorInteractor` is updated to hold an instance of `CalculationState`.

**Effort:** 1 Story Point
