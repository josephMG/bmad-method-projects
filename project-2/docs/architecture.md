# iOS Calculator App - Architecture Document

## 1. Introduction

This document outlines the software architecture for the iOS Calculator App. It details the technology stack, project structure, architectural patterns, and key design decisions to guide development and ensure maintainability. This document reflects the actual state of the codebase.

### 1.1. Document Scope

This architecture document covers the entire iOS Calculator application, including the core calculator functionality and the scientific and currency exchange modules.

## 2. High-Level Architecture

The application follows a modular, protocol-oriented design based on the **VIPER** architectural pattern. This approach ensures a clean separation of concerns, making the application scalable, testable, and maintainable.

The application is divided into three primary, independent VIPER modules:
1.  **Calculator:** The main module providing basic arithmetic operations. It also acts as the entry point and router to the other modules.
2.  **ScientificCalculator:** A distinct module for advanced mathematical functions.
3.  **CurrencyExchange:** A module for converting between different currencies.

### 2.1. Technology Stack

| Category | Technology | Notes |
| :--- | :--- | :--- |
| **Platform** | iOS | Supports the latest two major iOS versions. |
| **Language** | Swift | The entire codebase is written in Swift. |
| **UI Framework** | SwiftUI | Used for all UI components and layouts. |
| **Architecture** | VIPER | Enforces separation of concerns. |
| **IDE** | Xcode | Required for development and building. |

### 2.2. Repository Structure

The project is organized within the `CalculatorApp` directory, which contains the Xcode project, source code, and tests.

```
CalculatorApp/
├── Calculator/              # Main application source code
│   ├── Modules/             # Sub-modules for distinct features
│   │   ├── ScientificCalculator/
│   │   └── CurrencyExchange/
│   ├── CalculatorApp.swift  # App entry point
│   ├── CalculatorContract.swift # VIPER protocols for the main module
│   ├── CalculatorView.swift   # Main module's View
│   ├── ... (Interactor, Presenter, etc.)
│   └── ContentView.swift
├── Calculator.xcodeproj/    # Xcode project configuration
├── CalculatorTests/         # Unit tests
└── CalculatorUITests/       # UI tests
```

## 3. Detailed Architecture - VIPER

Each module (`Calculator`, `ScientificCalculator`, `CurrencyExchange`) is self-contained and adheres to the VIPER pattern.

*   **View**: A SwiftUI `View` responsible for displaying the UI and capturing user input. It is owned by a `UIHostingController`. It communicates user actions to the Presenter.
    *   *Files*: `*View.swift`
*   **Interactor**: Contains the business logic for a module. It processes data, performs calculations, and is independent of the UI. It receives requests from the Presenter and sends results back via a protocol.
    *   *Files*: `*Interactor.swift`
*   **Presenter**: The "middle-man" of the module. It receives user actions from the View, sends requests to the Interactor for business logic, gets data back from the Interactor, formats it, and publishes the final state for the View to display. It also communicates with the Router for navigation.
    *   *Files*: `*Presenter.swift`
*   **Entity**: Simple data structures or models used by the Interactor.
    *   *Files*: `*Entity.swift` (e.g., `CalculationState`, `Currency`, `ExchangeRates`)
*   **Router**: Handles navigation between modules. It is responsible for creating and presenting new VIPER modules.
    *   *Files*: `*Router.swift`
*   **Contract**: A central file defining all the `protocols` for a module's V, I, P, and R components, ensuring clear boundaries and responsibilities.
    *   *Files*: `*Contract.swift`

### 3.1. Module Interaction and Navigation

The main `CalculatorRouter` is responsible for instantiating and presenting the other modules.

-   When the user taps the "Scientific" button in the `CalculatorView`, the `CalculatorPresenter` calls the `CalculatorRouter`.
-   The `CalculatorRouter` then calls `ScientificCalculatorRouter.createModule()` to build the entire scientific calculator VIPER stack.
-   The new module's initial view (`UIHostingController`) is then presented modally over the current view.
-   The same flow applies to the `CurrencyExchange` module.

This design keeps the modules completely decoupled. The main `Calculator` module does not need to know anything about the internal workings of the `ScientificCalculator` or `CurrencyExchange` modules.

## 4. Data Models

-   **`CalculationState`**: A struct within the `CalculatorEntity.swift` file that holds the current state of a calculation (display value, operands, pending operation).
-   **`Operation`**: An enum that defines all possible mathematical operations.
-   **`Currency` & `ExchangeRates`**: Found in `CurrencyExchangeEntity.swift`, these define the supported currencies and their fixed conversion rates.

## 5. Testing Strategy

The project structure includes dedicated folders for testing, aligning with the VIPER pattern's high testability.

-   **`CalculatorTests/`**: This directory is intended for unit tests. The Interactors and Presenters of each module should be thoroughly tested here, as they contain the core business logic and view logic, respectively.
-   **`CalculatorUITests/`**: This directory is for UI tests, which verify user flows and the correct behavior of the SwiftUI views.

## 6. Technical Debt and Known Issues

-   The `ScientificCalculatorEntity.swift` file is currently empty. It should be populated with any data models specific to scientific calculations if needed.
-   The exchange rates in `CurrencyExchangeEntity.swift` are hardcoded. For a real-world application, this would be considered technical debt and should be replaced with an API call to fetch live rates.
-   Error handling is basic and displays a simple "Error" message. A more robust system would provide specific error details to the user.