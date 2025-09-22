### Story: Implement Additional Scientific Functions (Logarithms, Exponentiation, etc.)

**Description:** As a power user, I want to perform additional advanced scientific calculations including logarithms (ln, log10), exponentiation (e^x, 10^x, x^y), cube root, and factorial, within the dedicated scientific calculator view.

**Status:** Approved

**Acceptance Criteria:**

- User can input a number and apply the "natural logarithm" (`ln`) operator.
- App correctly calculates the natural logarithm of the number.
- User can input a number and apply the "base-10 logarithm" (`log10`) operator.
- App correctly calculates the base-10 logarithm of the number.
- User can input a number and apply the "e to the power of x" (`e^x`) operator.
- App correctly calculates e raised to the power of the number.
- User can input a number and apply the "10 to the power of x" (`10^x`) operator.
- App correctly calculates 10 raised to the power of the number.
- User can input two numbers and apply the "x to the power of y" (`x^y`) operator.
- App correctly calculates the first number raised to the power of the second number.
- User can input a number and apply the "cube root" (`³√`) operator.
- App correctly calculates the cube root of the number.
- User can input a non-negative integer and apply the "factorial" (`x!`) operator.
- App correctly calculates the factorial of the number.
- All new scientific functions are accessible only within the dedicated scientific calculator view.
- App handles invalid inputs for these scientific functions gracefully, with tailored error messages.

---

### Dev Notes

**Previous Story Insights**: This story builds upon `story-13.story.md` which established the dedicated `ScientificCalculator` VIPER module and implemented initial scientific functions (Power of 2, Basic Trigonometry).

**Data Models**:

- The `Operation` enum within `ScientificCalculatorEntity.swift` (or `CalculatorEntity.swift` if shared) will need new cases for `.naturalLogarithm`, `.base10Logarithm`, `.eToThePowerOfX`, `.tenToThePowerOfX`, `.xToThePowerOfY`, `.cubeRoot`, and `.factorial`.
- `CalculationState` struct in the `ScientificCalculator` module will need to be reviewed to ensure it can handle the state required for `x^y` (two operands).
- `CalculationError` enum will need specific cases tailored to errors related to these scientific calculations (e.g., `logarithmOfNonPositiveNumber`, `factorialOfNegativeNumber`).
  [Source: architecture.md#Entity]

**API Specifications**: No specific guidance found in architecture docs (not applicable for this internal calculation story).

**Component Specifications**:

- The `ScientificCalculatorView` will need additional buttons for `ln`, `log10`, `e^x`, `10^x`, `x^y`, `³√`, and `x!` operators.
- The `ScientificCalculatorPresenter` will need new methods to handle the gestures for these new functions (e.g., `didTapNaturalLogarithm()`, `didTapXToThePowerOfY()`).
- The `ScientificCalculatorPresenter` will be responsible for formatting the display of these scientific results.
  [Source: architecture.md#View, architecture.md#Presenter, architecture.md#VIPER Component Breakdown, architecture.md#UI/UX Implementation]

**File Locations**:

- `Calculator/Modules/ScientificCalculator/ScientificCalculatorInteractor.swift`: Will contain the core logic for these new scientific calculations.
- `Calculator/Modules/ScientificCalculator/ScientificCalculatorPresenter.swift`: Will handle UI interaction and data formatting for these new functions.
- `Calculator/Modules/ScientificCalculator/ScientificCalculatorEntity.swift`: Will define the new `Operation` enum cases and potentially update `CalculationState`.
- `Calculator/Modules/ScientificCalculator/ScientificCalculatorView.swift`: Will include the new scientific buttons.
- `Calculator/Modules/ScientificCalculator/ScientificCalculatorContract.swift`: Protocols might need updates for these new scientific operations.
  [Source: architecture.md#Folder Structure, architecture.md#VIPER Component Breakdown]

**Testing Requirements**:

- **Interactor (Unit Tests with XCTest):**
  - Test `applyNaturalLogarithm()`, `applyBase10Logarithm()`, `applyEToThePowerOfX()`, `applyTenToThePowerOfX()`, `applyXToThePowerOfY()`, `applyCubeRoot()`, and `applyFactorial()` methods with various scenarios.
  - Test edge cases for each function (e.g., `ln(0)`, `log10(-5)`, `0^0`, `(-2)!`).
  - Assert that the correct `CalculationError` is produced, with tailored error messages, when invalid operations occur.
- **Presenter (Unit Tests with XCTest):**
  - Test that `didTap...()` methods for new functions correctly call the Interactor's respective methods.
  - Test that scientific results from the Interactor are correctly formatted for display.
- **View (UI Tests with XCUITest):**
  - Verify the new scientific buttons are present and tappable in the `ScientificCalculatorView`.
  - Simulate calculations involving these functions and assert the final display value.
    [Source: architecture.md#Finalized Testing Strategy]

**Technical Constraints**:

- High decimal precision will be maintained internally and displayed to the user, leveraging the `Decimal` type.
- Error handling for invalid scientific operations (e.g., logarithms of non-positive numbers, factorial of negative numbers or non-integers) will be tailored to each specific function and error condition.
- Consideration for the order of operations, especially for `x^y`.
  [Source: architecture.md#Core Logic Implementation]

---

### Tasks / Subtasks

- [x] **Update `ScientificCalculatorEntity.swift`:**
- [x] **Update `ScientificCalculatorContract.swift`:**
- [x] **Implement New Scientific Logic in `ScientificCalculatorInteractor.swift`:**
- [x] **Update `ScientificCalculatorPresenter.swift`:**
- [x] **Update `ScientificCalculatorView.swift`:**
- [x] **Write Unit Tests for `ScientificCalculatorInteractorTests.swift`:**
- [x] **Write Unit Tests for `ScientificCalculatorPresenterTests.swift`:**
- [x] **Write UI Tests for `ScientificCalculatorUITests.swift`:**

### File List

- `CalculatorApp/Calculator/CalculatorEntity.swift`
- `CalculatorApp/Calculator/Modules/ScientificCalculator/ScientificCalculatorView.swift`
- `CalculatorApp/Calculator/Modules/ScientificCalculator/ScientificCalculatorInteractor.swift`
- `CalculatorApp/Calculator/Modules/ScientificCalculator/ScientificCalculatorPresenter.swift`
- `CalculatorApp/Calculator/Modules/ScientificCalculator/ScientificCalculatorEntity.swift`
- `CalculatorApp/Calculator/Modules/ScientificCalculator/ScientificCalculatorRouter.swift`
- `CalculatorApp/Calculator/Modules/ScientificCalculator/ScientificCalculatorContract.swift`
- `CalculatorApp/CalculatorTests/ScientificCalculatorInteractorTests.swift`
- `CalculatorApp/CalculatorTests/ScientificCalculatorPresenterTests.swift`
- `CalculatorApp/CalculatorUITests/ScientificCalculatorUITests.swift`

### Completion Notes

- Implemented additional scientific functions (logarithms, exponentiation, cube root, factorial).
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
*   Project Structure: The file list indicates correct placement of files within the `ScientificCalculator` module.
*   Testing Strategy: The testing requirements are comprehensive and appropriate for the new scientific functions.
*   All ACs Met: Cannot verify without code/tests.

### Improvements Checklist
*   [ ] Verify comprehensive unit tests for `ScientificCalculatorInteractor` covering `applyNaturalLogarithm()`, `applyBase10Logarithm()`, `applyEToThePowerOfX()`, `applyTenToThePowerOfX()`, `applyXToThePowerOfY()`, `applyCubeRoot()`, and `applyFactorial()` with various scenarios and edge cases (e.g., `ln(0)`, `log10(-5)`, `0^0`, `(-2)!`).
*   [ ] Confirm unit tests assert correct `CalculationError` for invalid scientific operations.
*   [ ] Verify `ScientificCalculatorPresenter` unit tests confirm correct handling of gestures and proper formatting of results.
*   [ ] Verify UI tests confirm the presence and functionality of the new scientific buttons in the `ScientificCalculatorView`.
*   [ ] Ensure the tailored error messages for invalid scientific input are user-friendly and clear.
*   [ ] Pay close attention to the implementation and testing of `x^y` and `x!` for edge cases and performance.

### Security Review
Not directly applicable to this story.

### Performance Considerations
Scientific calculations should be instantaneous.

### Files Modified During Review
None.

### Gate Status
Gate: CONCERNS → qa.qaLocation/gates/14-implement-additional-scientific-functions-logarithms-exponentiation-etc.yml
Risk profile: qa.qaLocation/assessments/14-implement-additional-scientific-functions-logarithms-exponentiation-etc-risk-20250922.md
NFR assessment: qa.qaLocation/assessments/14-implement-additional-scientific-functions-logarithms-exponentiation-etc-nfr-20250922.md

### Recommended Status
✗ Changes Required - See unchecked items above. The primary concern is the lack of concrete code and test results to review the implementation of these new, complex functions.
