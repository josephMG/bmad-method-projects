### Story: Implement Currency Exchange (TWD, USD, JPY, KRW)

**Description:** As a general user, I want to convert amounts between TWD, USD, JPY, and KRW using constant exchange rates, within a dedicated currency exchange view.

**Status:** Done

**Acceptance Criteria:**

- A clear mechanism (e.g., a button or mode switch) is provided to navigate to the currency exchange view.
- The currency exchange view allows users to select a source currency (TWD, USD, JPY, KRW) and a target currency (TWD, USD, JPY, KRW).
- User can input an amount in the source currency.
- App correctly calculates and displays the converted amount in the target currency using predefined constant rates.
- The currency exchange view operates independently of the basic and scientific calculator views.
- App handles invalid inputs (e.g., non-numeric input) gracefully, with tailored error messages.

---

### Dev Notes

**Previous Story Insights**: No specific guidance found in architecture docs.

**Data Models**:

- A new `Currency` enum will be needed to represent TWD, USD, JPY, KRW.
- A data structure (e.g., a dictionary or struct) will be needed to store the constant exchange rates between these currencies.
- `CalculationState` (or a new `CurrencyExchangeState` struct) will need to manage the selected currencies, input amount, and converted amount.
- `Operation` enum (or a new `CurrencyOperation` enum) might need a case for currency conversion.
- `CalculationError` enum (or a new `CurrencyError` enum) will need specific cases tailored to errors related to currency exchange (e.g., `invalidCurrencyInput`).
  [Source: architecture.md#Entity]

**API Specifications**: No specific guidance found in architecture docs (not applicable for this internal calculation story, as rates are constant).

**Component Specifications**:

- A dedicated `CurrencyExchangeView` will need to be created to house the currency conversion functionality. This view will be separate from the `CalculatorView` and `ScientificCalculatorView`.
- The `CurrencyExchangeView` will need UI elements for selecting source/target currencies, inputting amounts, and displaying results.
- A new `CurrencyExchangePresenter` will be needed to handle user interactions (e.g., `didSelectSourceCurrency()`, `didEnterAmount()`, `didSelectTargetCurrency()`) and translate them to a `CurrencyExchangeInteractor`.
- The `CurrencyExchangePresenter` will be responsible for formatting the display of currency amounts.
- A mechanism for navigating to and from the `CurrencyExchangeView` will be required, likely managed by the `Router`.
  [Source: architecture.md#View, architecture.md#Presenter, architecture.md#Router, architecture.md#VIPER Component Breakdown, architecture.md#UI/UX Implementation]

**File Locations**:

- `Calculator/Modules/CurrencyExchange/CurrencyExchangeView.swift`: New SwiftUI View for currency exchange.
- `Calculator/Modules/CurrencyExchange/CurrencyExchangeInteractor.swift`: New Interactor for currency exchange business logic.
- `Calculator/Modules/CurrencyExchange/CurrencyExchangePresenter.swift`: New Presenter for currency exchange view logic and formatting.
- `Calculator/Modules/CurrencyExchange/CurrencyExchangeEntity.swift`: New Entity for currency exchange data models.
- `Calculator/Modules/CurrencyExchange/CurrencyExchangeRouter.swift`: New Router for currency exchange module navigation.
- `Calculator/Modules/CurrencyExchange/CurrencyExchangeContract.swift`: New Protocols for currency exchange component interfaces.
- `Calculator/Modules/Calculator/CalculatorRouter.swift`: Will need updates to handle navigation to the `CurrencyExchangeView`.
  [Source: architecture.md#Folder Structure, architecture.md#VIPER Component Breakdown]

**Testing Requirements**:

- **Interactor (Unit Tests with XCTest):**
  - Test currency conversion logic for all supported currency pairs with various amounts.
  - Test edge cases (e.g., converting zero, very large/small amounts).
  - Assert that the correct `CalculationError` (or `CurrencyError`) is produced, with tailored error messages, when invalid operations occur.
- **Presenter (Unit Tests with XCTest):**
  - Test that user interactions (e.g., selecting currencies, entering amounts) correctly call the Interactor's methods.
  - Test that converted amounts from the Interactor are correctly formatted for display.
- **View (UI Tests with XCUITest):**
  _ Verify the presence and functionality of currency selection elements and input/output fields in the `CurrencyExchangeView`.
  _ Simulate currency conversions and assert the final displayed values. \* Test navigation to and from the `CurrencyExchangeView`.
  [Source: architecture.md#Finalized Testing Strategy]

**Technical Constraints**:

- High decimal precision will be maintained internally and displayed to the user, leveraging the `Decimal` type.
- Storage of constant exchange rates (e.g., hardcoded in the Interactor or a dedicated `ExchangeRateProvider`).
- Error handling for invalid currency inputs will be tailored to each specific function and error condition.
  [Source: architecture.md#Core Logic Implementation]

---

### Tasks / Subtasks

1.  **Create New VIPER Module for Currency Exchange:**
    - Create `Calculator/Modules/CurrencyExchange/` directory.
    - Create `CurrencyExchangeView.swift`, `CurrencyExchangeInteractor.swift`, `CurrencyExchangePresenter.swift`, `CurrencyExchangeEntity.swift`, `CurrencyExchangeRouter.swift`, and `CurrencyExchangeContract.swift` within this new directory.
      [Source: architecture.md#Folder Structure, architecture.md#VIPER Component Breakdown]
2.  **Define Currency Models and Rates in `CurrencyExchangeEntity.swift`:**
    - Create a `Currency` enum (TWD, USD, JPY, KRW).
    - Define a data structure to store constant exchange rates (e.g., `[Currency: [Currency: Decimal]]`).
    - Consider if `CalculationState` needs to be duplicated or shared/extended for the currency exchange module.
    - Add relevant `CalculationError` (or `CurrencyError`) cases.
      [Source: architecture.md#Entity]
3.  **Implement Currency Exchange Logic in `CurrencyExchangeInteractor.swift`:**
    - Add methods for `convertAmount(amount: Decimal, from: Currency, to: Currency)`.
    - Implement the conversion logic using the constant exchange rates.
    - Handle edge cases and potential errors.
      [Source: architecture.md#Interactor, architecture.md#Core Logic Implementation]
4.  **Update `CurrencyExchangePresenter.swift`:**
    - Add `didSelectSourceCurrency()`, `didEnterAmount()`, `didSelectTargetCurrency()`, and `didTapConvert()` methods to receive input from the `CurrencyExchangeView`.
    - Call the appropriate Interactor methods.
    - Handle `didUpdateConvertedAmount` delegate calls from the Interactor and format results for the View.
      [Source: architecture.md#Presenter]
5.  **Create `CurrencyExchangeView.swift`:**
    - Design the UI for the currency exchange, including currency selectors, input field, and display for converted amount.
    - Wire up UI actions to call the respective methods in `CurrencyExchangePresenter`.
      [Source: architecture.md#View]
6.  **Update `CalculatorRouter.swift` (or create `AppRouter.swift`):**
    - Implement navigation logic to switch between the `CalculatorView`, `ScientificCalculatorView`, and `CurrencyExchangeView`.
      [Source: architecture.md#Router]
7.  **Write Unit Tests for `CurrencyExchangeInteractorTests.swift`:**
    - Test `convertAmount()` method with various currency pairs and amounts.
    - Test edge cases and error conditions.
      [Source: architecture.md#Finalized Testing Strategy]
8.  **Write Unit Tests for `CurrencyExchangePresenterTests.swift`:**
    - Test gesture handling and data formatting for currency exchange.
      [Source: architecture.md#Finalized Testing Strategy]
9.  **Write UI Tests for `CurrencyExchangeUITests.swift`:**
    - Verify the presence and functionality of currency exchange UI elements.
    - Simulate currency conversions and assert the final display value.
    - Test navigation to and from the `CurrencyExchangeView`.
      [Source: architecture.md#Finalized Testing Strategy]

## QA Results

### Review Date: 2025-09-22

### Reviewed By: Quinn (Test Architect)

### Code Quality Assessment
Cannot assess without code.

### Refactoring Performed
None, as code is not available for review.

### Compliance Check
*   Coding Standards: Cannot verify without code.
*   Project Structure: The detailed file locations and new VIPER module structure are well-defined.
*   Testing Strategy: The testing requirements are comprehensive and appropriate for the new currency exchange functionality and module.
*   All ACs Met: Cannot verify without code/tests.

### Improvements Checklist
*   [ ] Verify the creation of the new `CurrencyExchange` VIPER module with all specified components.
*   [ ] Verify comprehensive unit tests for `CurrencyExchangeInteractor` covering `convertAmount()` for all supported currency pairs and various amounts.
*   [ ] Confirm unit tests assert correct `CalculationError` (or `CurrencyError`) for invalid conversion operations.
*   [ ] Verify `CurrencyExchangePresenter` unit tests confirm correct handling of user interactions (selecting currencies, entering amounts) and proper formatting of results.
*   [ ] Verify UI tests confirm the presence and functionality of currency selection elements, input/output fields, and correct display of converted amounts in the `CurrencyExchangeView`.
*   [ ] Verify UI tests confirm correct navigation to and from the `CurrencyExchangeView`.
*   [ ] Ensure the tailored error messages for invalid inputs are user-friendly and clear.
*   [ ] Confirm the use of predefined constant exchange rates.

### Security Review
Not directly applicable to this story.

### Performance Considerations
Currency conversions should be instantaneous, and module transitions smooth.

### Files Modified During Review
None.

### Gate Status
Gate: CONCERNS → qa.qaLocation/gates/16-implement-currency-exchange-twd-usd-jpy-krw.yml
Risk profile: qa.qaLocation/assessments/16-implement-currency-exchange-twd-usd-jpy-krw-risk-20250922.md
NFR assessment: qa.qaLocation/assessments/16-implement-currency-exchange-twd-usd-jpy-krw-nfr-20250922.md

### Recommended Status
✗ Changes Required - See unchecked items above. The primary concern is the lack of concrete code and test results to review the implementation of this new, complex module.
