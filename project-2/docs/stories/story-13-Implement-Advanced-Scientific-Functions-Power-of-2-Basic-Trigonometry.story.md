### Story: Implement Advanced Scientific Functions (Power of 2, Basic Trigonometry)

**Description:** As a power user, I want to perform advanced scientific calculations including power of 2, sine, cosine, and tangent, within a dedicated scientific calculator view.

**Status:** Done

**Acceptance Criteria:**

- User can input a number and apply the "power of 2" (`x²`) operator.
- App correctly calculates the square of the number.
- User can input a number and apply the "sine" (`sin`) operator.
- App correctly calculates the sine of the number.
- User can input a number and apply the "cosine" (`cos`) operator.
- App correctly calculates the cosine of the number.
- User can input a number and apply the "tangent" (`tan`) operator.
- App correctly calculates the tangent of the number.
- The scientific functions are accessible only within the dedicated scientific calculator view.
- App handles invalid inputs for these scientific functions gracefully, with tailored error messages.

---

### Dev Notes

**Previous Story Insights**: No specific guidance found in architecture docs.

**Data Models**:

- `CalculationState` struct will need to be updated to handle these new scientific operations. It currently has `firstOperand`, `secondOperand`, `pendingOperation`, `currentDisplayValue`, `isEnteringDecimal`. New `Operation` types will be needed.
- `Operation` enum will need new cases for `.powerOfTwo`, `.sine`, `.cosine`, and `.tangent`.
- `CalculationError` enum will need specific cases tailored to errors related to these scientific calculations (e.g., `invalidInputForTrigonometricFunction`).
  [Source: architecture.md#Entity]

**API Specifications**: No specific guidance found in architecture docs (not applicable for this internal calculation story).

**Component Specifications**:

- A dedicated `ScientificCalculatorView` will need to be created to house these scientific functions. This view will be separate from the `CalculatorView`.
- The `ScientificCalculatorView` will need buttons for the "power of 2" (`x²`), "sine" (`sin`), "cosine" (`cos`), and "tangent" (`tan`) operators.
- A new `ScientificCalculatorPresenter` will be needed to handle the `didTapPowerOfTwo()`, `didTapSine()`, `didTapCosine()`, and `didTapTangent()` gestures and translate them to a `ScientificCalculatorInteractor`.
- The `ScientificCalculatorPresenter` will also be responsible for formatting the display of these scientific results.
- A mechanism for navigating to and from the `ScientificCalculatorView` will be required, likely managed by the `Router`.
  [Source: architecture.md#View, architecture.md#Presenter, architecture.md#Router, architecture.md#VIPER Component Breakdown, architecture.md#UI/UX Implementation]

**File Locations**:

- `Calculator/Modules/ScientificCalculator/ScientificCalculatorView.swift`: New SwiftUI View for scientific functions.
- `Calculator/Modules/ScientificCalculator/ScientificCalculatorInteractor.swift`: New Interactor for scientific business logic.
- `Calculator/Modules/ScientificCalculator/ScientificCalculatorPresenter.swift`: New Presenter for scientific view logic and formatting.
- `Calculator/Modules/ScientificCalculator/ScientificCalculatorEntity.swift`: New Entity for scientific data models (or extend existing `CalculatorEntity.swift` if appropriate).
- `Calculator/Modules/ScientificCalculator/ScientificCalculatorRouter.swift`: New Router for scientific module navigation.
- `Calculator/Modules/ScientificCalculator/ScientificCalculatorContract.swift`: New Protocols for scientific component interfaces.
- `Calculator/Modules/Calculator/CalculatorRouter.swift`: Will need updates to handle navigation to the `ScientificCalculatorView`.
  [Source: architecture.md#Folder Structure, architecture.md#VIPER Component Breakdown]

**Testing Requirements**:

- **Interactor (Unit Tests with XCTest):**
  - Test `applyPowerOfTwo()` method with various scenarios (e.g., `2²`, `0²`, `(-3)²`).
  - Test `applySine()`, `applyCosine()`, `applyTangent()` methods with various angle inputs (e.g., `sin(0)`, `cos(90)`, `tan(45)`).
  - Test edge cases for these scientific functions (e.g., `tan(90)` should produce an error).
  - Assert that the correct `CalculationError` is produced, with tailored error messages, when invalid operations occur.
- **Presenter (Unit Tests with XCTest):**
  - Test that `didTapPowerOfTwo()`, `didTapSine()`, `didTapCosine()`, `didTapTangent()` correctly call the Interactor's respective methods.
  - Test that scientific results from the Interactor are correctly formatted for display.
- **View (UI Tests with XCUITest):**
  - Verify the "power of 2", "sine", "cosine", and "tangent" buttons are present and tappable in the `ScientificCalculatorView`.
  - Simulate calculations involving these functions and assert the final display value.
  - Test navigation to and from the `ScientificCalculatorView`.
    [Source: architecture.md#Finalized Testing Strategy]

**Technical Constraints**:

- High decimal precision will be maintained internally and displayed to the user, leveraging the `Decimal` type.
- Trigonometric functions will default to using degrees for angle units.
- Error handling for invalid scientific operations (e.g., tangent of 90 degrees, very large/small numbers) will be tailored to each specific function and error condition.
  [Source: architecture.md#Core Logic Implementation]

---

### Tasks / Subtasks

1.  **Create New VIPER Module for Scientific Calculator:**
    - Create `Calculator/Modules/ScientificCalculator/` directory.
    - Create `ScientificCalculatorView.swift`, `ScientificCalculatorInteractor.swift`, `ScientificCalculatorPresenter.swift`, `ScientificCalculatorEntity.swift`, `ScientificCalculatorRouter.swift`, and `ScientificCalculatorContract.swift` within this new directory.
      [Source: architecture.md#Folder Structure, architecture.md#VIPER Component Breakdown]
2.  **Define Scientific Operations in `ScientificCalculatorEntity.swift`:**
    - Add `.powerOfTwo`, `.sine`, `.cosine`, and `.tangent` cases to the `Operation` enum (or a new `ScientificOperation` enum if preferred for separation).
    - Consider if `CalculationState` needs to be duplicated or shared/extended for the scientific module.
    - Add relevant `CalculationError` cases.
      [Source: architecture.md#Entity]
3.  **Implement Scientific Logic in `ScientificCalculatorInteractor.swift`:**
    - Add methods for `applyPowerOfTwo()`, `applySine()`, `applyCosine()`, and `applyTangent()`.
    - Implement the mathematical logic for each function.
    - Handle edge cases and potential errors (e.g., `tan(90)`).
      [Source: architecture.md#Interactor, architecture.md#Core Logic Implementation]
4.  **Update `ScientificCalculatorPresenter.swift`:**
    - Add `didTapPowerOfTwo()`, `didTapSine()`, `didTapCosine()`, and `didTapTangent()` methods to receive input from the `ScientificCalculatorView`.
    - Call the appropriate Interactor methods.
    - Handle `didUpdateDisplayValue` delegate calls from the Interactor and format results for the View.
      [Source: architecture.md#Presenter]
5.  **Create `ScientificCalculatorView.swift`:**
    - Design the UI for the scientific calculator, including buttons for the new functions.
    - Wire up button actions to call the respective methods in `ScientificCalculatorPresenter`.
      [Source: architecture.md#View]
6.  **Update `CalculatorRouter.swift` (or create `AppRouter.swift`):**
    - Implement navigation logic to switch between the `CalculatorView` and `ScientificCalculatorView`.
    - This will likely involve presenting the `ScientificCalculatorView` modally or using a navigation stack.
      [Source: architecture.md#Router]
7.  **Write Unit Tests for `ScientificCalculatorInteractorTests.swift`:**
    - Test `applyPowerOfTwo()`, `applySine()`, `applyCosine()`, `applyTangent()` with various scenarios and edge cases.
      [Source: architecture.md#Finalized Testing Strategy]
8.  **Write Unit Tests for `ScientificCalculatorPresenterTests.swift`:**
    - Test gesture handling and data formatting for the new scientific functions.
      [Source: architecture.md#Finalized Testing Strategy]
9.  **Write UI Tests for `ScientificCalculatorUITests.swift`:**
    - Verify the presence and functionality of the new scientific buttons.
    - Test navigation to and from the `ScientificCalculatorView`.
      [Source: architecture.md#Finalized Testing Strategy]
