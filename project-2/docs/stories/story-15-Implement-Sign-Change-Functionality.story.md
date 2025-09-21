### Story: Implement Sign Change (+/−) Functionality

**Description:** As a general user, I want to change the sign of a number (+/−) so that I can work with positive and negative values in my calculations.

**Status:** Done

**Acceptance Criteria:**

- User can input a number and then apply the sign change (+/−) operator.
- App correctly toggles the sign of the currently displayed number (positive to negative, and negative to positive).
- Applying sign change to zero should result in zero.
- App handles any potential invalid inputs gracefully, with tailored error messages.

---

### Dev Notes

**Previous Story Insights**: No specific guidance found in architecture docs.

**Data Models**:

- The `Operation` enum within `CalculatorEntity.swift` will need a new case for `.signChange`.
- `CalculationState` struct in the `Calculator` module will need to be reviewed to ensure it can handle the state required for applying sign change to the `currentDisplayValue`.
- `CalculationError` enum will need specific cases tailored to errors related to sign change (unlikely for this simple operation, but ready for future expansion).
  [Source: architecture.md#Entity]

**API Specifications**: No specific guidance found in architecture docs (not applicable for this internal calculation story).

**Component Specifications**:

- The `CalculatorView` will need a button for the sign change (+/−) operator.
- The `Presenter` will need a new method (e.g., `didTapSignChange()`) to handle the gesture and translate it to the Interactor.
- The `Presenter` will be responsible for formatting the display of the number after its sign has been changed.
  [Source: architecture.md#View, architecture.md#Presenter, architecture.md#VIPER Component Breakdown, architecture.md#UI/UX Implementation]

**File Locations**:

- `Calculator/Modules/Calculator/CalculatorInteractor.swift`: Will contain the core logic for sign change.
- `Calculator/Modules/Calculator/CalculatorPresenter.swift`: Will handle UI interaction and data formatting for sign change.
- `Calculator/Modules/Calculator/CalculatorEntity.swift`: Will define the new `Operation` enum case.
- `Calculator/Modules/Calculator/CalculatorView.swift`: Will include the sign change button.
- `Calculator/Modules/Calculator/CalculatorContract.swift`: Protocols might need updates for sign change operation.
  [Source: architecture.md#Folder Structure, architecture.md#VIPER Component Breakdown]

**Testing Requirements**:

- **Interactor (Unit Tests with XCTest):**
  - Test `applySignChange()` method with positive numbers, negative numbers, and zero.
  - Test applying sign change multiple times.
  - Assert that the correct `CalculationError` is produced, with tailored error messages, when invalid operations occur.
- **Presenter (Unit Tests with XCTest):**
  - Test that `didTapSignChange()` correctly calls the Interactor's sign change method.
  - Test that the result from the Interactor is correctly formatted for display.
- **View (UI Tests with XCUITest):**
  - Verify the sign change button is present and tappable.
  - Simulate inputting a number, tapping sign change, and asserting the displayed value.
    [Source: architecture.md#Finalized Testing Strategy]

**Technical Constraints**:

- High decimal precision will be maintained internally and displayed to the user, leveraging the `Decimal` type.
- Error handling for any potential invalid inputs will be tailored to each specific function and error condition.
  [Source: architecture.md#Core Logic Implementation]

---

### Tasks / Subtasks

- [x] **Update `CalculatorEntity.swift`:**
- [x] **Update `CalculatorContract.swift`:**
- [x] **Implement Sign Change Logic in `CalculatorInteractor.swift`:**
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

- Implemented sign change functionality.
- Added unit and UI tests for the new feature.
- All tests are passing.
