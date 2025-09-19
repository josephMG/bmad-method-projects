# iOS Calculator App: VIPER Technical Specification

This document provides a detailed technical specification and data flow design for the iOS Calculator App, based on the VIPER architectural pattern.

## 1. VIPER Component Breakdown

The application will be divided into distinct modules, each with five core components: View, Interactor, Presenter, Entity, and Router. This separation of concerns ensures a clean, scalable, and highly testable codebase.

### View

The View layer will be implemented using **SwiftUI**. Its responsibilities are strictly limited to UI rendering and capturing user input.

-   **Implementation:** A `CalculatorView` struct will define the layout of buttons and the display screen. It will be lightweight and declarative.
-   **State Management:** The View will use SwiftUI's `@State` for transient UI state (e.g., button highlighting on tap). The primary display text and other core state will be provided by the Presenter via a data-bound ViewModel object (e.g., an `@ObservedObject`).
-   **Responsibilities:**
    -   Render the calculator grid and display.
    -   Receive the formatted display string from the Presenter.
    -   Forward user gestures (e.g., `onTapGesture`) to the Presenter for handling. It will not contain any business or formatting logic.

### Interactor

The Interactor is the heart of the module's business logic, containing the core calculation engine. It knows nothing about the UI.

-   **Inputs:** The Interactor will receive simple, validated input from the Presenter, defined by a protocol. Example inputs include:
    -   `appendDigit(_ digit: Int)`
    -   `setOperation(_ operation: Operation)`
    -   `performCalculation()`
    -   `clear()`
-   **Outputs:** After processing an input, the Interactor communicates results back to the Presenter via a delegate protocol. Outputs will be pure data, not formatted strings.
    -   `didUpdateDisplayValue(_ value: Decimal)`
    -   `didEncounterError(_ error: CalculationError)`
-   **Responsibilities:**
    -   Maintain the current calculation state (operands, pending operations).
    -   Execute all mathematical operations.
    -   Handle business rules and edge cases (e.g., division by zero).

### Presenter

The Presenter acts as the central coordinator, mediating between the View, Interactor, and Router.

-   **Data Formatting:** It receives raw `Decimal` or `Error` objects from the Interactor and formats them into user-friendly `String`s for the View. This includes handling decimal points, thousands separators, and error messages.
-   **Gesture Handling:** It receives raw gesture notifications from the View (e.g., `didTapPlusButton()`) and translates them into logical commands for the Interactor (e.g., `interactor.setOperation(.add)`).
-   **State Management:** It holds the state that the View needs to render, typically in an `ObservableObject`. This ViewModel will expose published properties like `displayText: String` that the SwiftUI View can bind to.

### Entity

Entities are the plain data structures that model the application's core concepts. They have no business logic.

-   **`CalculationState`:** A struct to encapsulate the calculator's memory.
    ```swift
    struct CalculationState {
        var firstOperand: Decimal?
        var secondOperand: Decimal?
        var pendingOperation: Operation?
        var currentDisplayValue: Decimal = 0
        var isEnteringDecimal = false
    }
    ```
-   **`Operation`:** An enum representing the mathematical operations.
    ```swift
    enum Operation {
        case add, subtract, multiply, divide
    }
    ```
-   **`CalculationError`:** An enum for handling business logic errors.
    ```swift
    enum CalculationError: Error {
        case divisionByZero
    }
    ```

### Router

The Router manages navigation and the view hierarchy.

-   **Responsibilities:** For this application, the Router's role is minimal but essential for structure.
    -   It will be responsible for instantiating and assembling the VIPER module (View, Presenter, Interactor).
    -   It will present the initial `CalculatorView` on screen.
-   **Future Scalability:** If the app were to expand (e.g., with a "Scientific Mode" or a "History" screen), the Router would handle the transitions between these views, ensuring the `CalculatorView` itself remains unaware of the broader navigation flow.

## 2. Data Flow Example: `2 + 3 =`

This sequence describes the flow of control and data for a simple calculation:

1.  **User taps "2"**:
    -   `View` captures the tap and calls `presenter.didTapDigit(2)`.
    -   `Presenter` calls `interactor.appendDigit(2)`.
    -   `Interactor` updates its internal `CalculationState` and calls its delegate method `presenter.didUpdateDisplayValue(2)`.
    -   `Presenter` formats the `Decimal` value `2` into the `String` "2" and updates its published `displayText` property.
    -   `View` automatically re-renders to show "2".

2.  **User taps "+"**:
    -   `View` calls `presenter.didTapAdd()`.
    -   `Presenter` calls `interactor.setOperation(.add)`.
    -   `Interactor` stores the first operand and the pending operation in its `CalculationState`. No display change is needed.

3.  **User taps "3"**:
    -   `View` calls `presenter.didTapDigit(3)`.
    -   `Presenter` calls `interactor.appendDigit(3)`.
    -   `Interactor` updates its state and calls `presenter.didUpdateDisplayValue(3)`.
    -   `Presenter` formats this into "3" and updates the `displayText`.
    -   `View` re-renders to show "3".

4.  **User taps "="**:
    -   `View` calls `presenter.didTapEquals()`.
    -   `Presenter` calls `interactor.performCalculation()`.
    -   `Interactor` executes `2 + 3`, calculates the result `5`, updates its state, and calls `presenter.didUpdateDisplayValue(5)`.
    -   `Presenter` formats the result into "5" and updates the `displayText`.
    -   `View` re-renders to show the final result, "5".

## 3. Folder Structure

A clear folder structure is crucial for maintaining separation of concerns.

```
Calculator/
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
├── Modules/
│   └── Calculator/
│       ├── CalculatorView.swift         // SwiftUI View
│       ├── CalculatorInteractor.swift   // Business Logic
│       ├── CalculatorPresenter.swift    // View Logic & Formatting
│       ├── CalculatorEntity.swift       // Data Models
│       ├── CalculatorRouter.swift       // Navigation
│       └── CalculatorContract.swift     // Protocols for component interfaces
│
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

## 4. Finalized CI/CD Plan (GitHub Actions)

The CI/CD pipeline will automate testing and building on every push to the `main` branch or pull request targeting `main`.

**Workflow File:** `.github/workflows/ci.yml`

```yaml
name: iOS CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build_and_test:
    name: Build and Test
    runs-on: macos-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Select Xcode version
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '14.2' # Specify the project's Xcode version

    - name: Run Tests
      run: |
        xcodebuild test \
          -scheme Calculator \
          -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' \
          -enableCodeCoverage YES \
          | xcpretty

    - name: Build Application
      run: |
        xcodebuild build \
          -scheme Calculator \
          -destination 'platform=iOS Simulator,name=iPhone 14,OS=16.2' \
          | xcpretty
```

## 5. Finalized Testing Strategy

Each component of the VIPER module will be tested independently.

-   **View (UI Tests with XCUITest):**
    -   Verify that all buttons and the display label are present on the screen.
    -   Simulate user taps on digit and operator buttons and assert that the display label updates correctly.
    -   Test UI behavior in both portrait and landscape orientations.

-   **Interactor (Unit Tests with XCTest):**
    -   Test the calculation logic in complete isolation.
    -   Provide a sequence of inputs (e.g., `appendDigit`, `setOperation`) and assert that the final output delegate call returns the mathematically correct `Decimal`.
    -   Test edge cases: division by zero, calculations with negative numbers, and repeated operations.
    -   Assert that the correct `CalculationError` is produced when invalid operations occur.

-   **Presenter (Unit Tests with XCTest):**
    -   Use mock objects for the Interactor, View, and Router.
    -   Test data formatting: Given the Interactor's delegate returns `Decimal(3.14159)`, assert that the Presenter provides a correctly formatted `String` (e.g., "3.14159") to the View.
    -   Test gesture handling: When a `didTapAdd()` function is called, assert that the Presenter calls the `interactor.setOperation(.add)` method on its mock Interactor.

-   **Router (Unit Tests with XCTest):**
    -   Use a mock navigation controller to test navigation logic.
    -   Assert that the `createModule()` function correctly assembles the VIPER stack with all dependencies properly injected.
