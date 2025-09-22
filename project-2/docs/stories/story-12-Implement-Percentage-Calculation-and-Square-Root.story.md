### Story: Implement Percentage Calculation and Square Root

**Description:** As a general user, I want to calculate percentages so that I can easily figure out discounts, tips, or proportions. Additionally, as a power user, I want to calculate the square root of a number for quick scientific calculations.

**Status:** Done

**Acceptance Criteria:**

- User can input a number, then the percentage operator, and another number (e.g., 50 + 10%).
- App correctly calculates the percentage of a number or adds/subtracts a percentage.
- User can input a number and apply the square root operator.
- App correctly calculates the square root of the number.
- App handles invalid input for square root (e.g., negative numbers) gracefully, with tailored error messages.

---

### Dev Notes

**Previous Story Insights**: No specific guidance found in architecture docs.

**Data Models**:

- `CalculationState` struct will need to be updated to handle percentage and square root operations. It currently has `firstOperand`, `secondOperand`, `pendingOperation`, `currentDisplayValue`, `isEnteringDecimal`. New `Operation` types will be needed.
- `Operation` enum will need new cases for `.percentage` and `.squareRoot`.
- `CalculationError` enum will need specific cases tailored to errors related to percentage or square root calculation (e.g., `invalidInputForSquareRoot`).
  [Source: architecture.md#Entity]

**API Specifications**: No specific guidance found in architecture docs (not applicable for this internal calculation story).

**Component Specifications**:

- The `CalculatorView` will need buttons for the percentage operator and the square root operator.
- The `Presenter` will need to handle `didTapPercentage()` and `didTapSquareRoot()` gestures and translate them to the Interactor.
- The `Presenter` will also be responsible for formatting the display of percentage and square root results.
  [Source: architecture.md#View, architecture.md#Presenter]

**File Locations**:

- `Calculator/Modules/Calculator/CalculatorInteractor.swift`: Will contain the core logic for percentage and square root calculations.
- `Calculator/Modules/Calculator/CalculatorPresenter.swift`: Will handle UI interaction and data formatting for percentage and square root.
- `Calculator/Modules/Calculator/CalculatorEntity.swift`: Will define the `Operation` enum and potentially update `CalculationState`.
- `Calculator/Modules/Calculator/CalculatorView.swift`: Will include the percentage and square root buttons.
- `Calculator/Modules/Calculator/CalculatorContract.swift`: Protocols might need updates for percentage and square root operations.
  [Source: architecture.md#Folder Structure]

**Testing Requirements**:

- **Interactor (Unit Tests with XCTest):**
  - Test `applyPercentage()` method with various scenarios (e.g., `100 + 10%`, `50 * 20%`, `100 - 50%`).
  - Test edge cases for percentage (e.g., applying percentage to zero, applying percentage without a first operand).
  - Test `applySquareRoot()` method with various scenarios (e.g., `√9`, `√0`).
  - Test edge cases for square root (e.g., `√-4` should produce an error).
  - Assert that the correct `CalculationError` is produced, with tailored error messages, when invalid operations occur.
- **Presenter (Unit Tests with XCTest):**
  - Test that `didTapPercentage()` and `didTapSquareRoot()` correctly call the Interactor's respective methods.
  - Test that percentage and square root results from the Interactor are correctly formatted for display.
- **View (UI Tests with XCUITest):**
  - Verify the percentage and square root buttons are present and tappable.
  - Simulate calculations involving percentage (e.g., "100 + 10 % =") and square root (e.g., "9 √ =") and assert the final display value.
    [Source: architecture.md#Finalized Testing Strategy]

**Technical Constraints**:

- High decimal precision will be maintained internally and displayed to the user, leveraging the `Decimal` type.
- Order of operations for percentage (e.g., `X + Y%` as `X + (X * Y/100)`).
- Error handling for invalid percentage and square root operations (e.g., square root of a negative number) will be tailored to each specific function and error condition.
  [Source: architecture.md#Core Logic Implementation]

---

### Tasks / Subtasks

- [x] **Update `CalculatorEntity.swift`:**
- [x] **Update `CalculatorContract.swift`:**
- [x] **Implement Percentage Logic in `CalculatorInteractor.swift`:**
- [x] **Implement Square Root Logic in `CalculatorInteractor.swift`:**
- [x] **Update `CalculatorPresenter.swift`:**
- [x] **Update `CalculatorView.swift`:**
- [x] **Write Unit Tests for `CalculatorInteractorTests.swift`:**
- [x] **Write Unit Tests for `CalculatorPresenterTests.swift`:**
- [x] **Write UI Tests for `CalculatorUITests.swift`:**

### File List

- `CalculatorApp/Calculator/CalculatorEntity.swift`
- `CalculatorApp/Calculator/CalculatorContract.swift`
- `CalculatorApp/Calculator/CalculatorInteractor.swift`
- `CalculatorApp/Calculator/CalculatorPresenter.swift`
- `CalculatorApp/Calculator/CalculatorView.swift`
- `CalculatorApp/CalculatorTests/CalculatorInteractorTests.swift`
- `CalculatorApp/CalculatorTests/CalculatorPresenterTests.swift`
- `CalculatorApp/CalculatorUITests/CalculatorUITests.swift`

### Completion Notes

- Implemented percentage and square root functionality.
- Added unit and UI tests for the new features.
- All tests are passing.

## QA Results

### Review Date: 2025-09-22

### Reviewed By: Quinn (Test Architect)

### Code Quality Assessment
Cannot assess without code.

### Refactoring Performed
None, as code is not available for review.

### Compliance Check
*   Coding Standards: Cannot verify without code.
*   Project Structure: The file list indicates correct placement of files.
*   Testing Strategy: The testing requirements are well-defined and cover unit and UI tests for the new features.
*   All ACs Met: Cannot verify without code/tests.

### Improvements Checklist
*   [ ] Verify comprehensive unit tests for `applyPercentage()` covering all specified scenarios and edge cases (e.g., `100 + 10%`, `50 * 20%`, `100 - 50%`, applying percentage to zero).
*   [ ] Verify comprehensive unit tests for `applySquareRoot()` covering all specified scenarios and edge cases (e.g., `√9`, `√0`, `√-4` producing an error).
*   [ ] Confirm unit tests assert correct `CalculationError` for invalid square root operations.
*   [ ] Verify Presenter unit tests confirm correct handling of `didTapPercentage()` and `didTapSquareRoot()` and proper formatting of results.
*   [ ] Verify UI tests confirm the presence and functionality of percentage and square root buttons, and correct display of results for example calculations.
*   [ ] Ensure the tailored error messages for invalid square root input are user-friendly and clear.

### Security Review
Not directly applicable to this story.

### Performance Considerations
Calculations should be instantaneous.

### Files Modified During Review
None.

### Gate Status
Gate: CONCERNS → qa.qaLocation/gates/12-implement-percentage-calculation-and-square-root.yml
Risk profile: qa.qaLocation/assessments/12-implement-percentage-calculation-and-square-root-risk-20250922.md
NFR assessment: qa.qaLocation/assessments/12-implement-percentage-calculation-and-square-root-nfr-20250922.md

### Recommended Status
✗ Changes Required - See unchecked items above. The primary concern is the lack of concrete code and test results to review the implementation.
