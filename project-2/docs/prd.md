<!-- Powered by BMAD™ Core -->
# Product Requirements Document: iOS Calculator App

## 1. Goals and Background Context

### 1.1. Product Vision/Overall Goal:
To develop a clean, intuitive, and feature-rich iOS calculator app that mirrors the user experience of the native iOS calculator. This project will serve as a foundational portfolio piece, demonstrating core competencies in SwiftUI, modern architectural patterns, and the complete app development lifecycle, from concept to a store-ready product.

### 1.2. Target Audience:
General Users: People who need a simple, reliable tool for everyday calculations like budgeting, shopping, or quick math problems.

### 1.3. Key High-Level Features (to be detailed in subsequent sections):
*   Core Operations (Portrait Mode): Addition, Subtraction, Multiplication, Division, Percentage (%), Sign Change (+/−), All Clear (AC) / Clear (C) functionality.
*   Scientific Functions (Landscape Mode): Includes all core operations and adds advanced functions (e.g., trigonometric functions, logarithms, square roots, etc.).
*   User Interface & Experience (UI/UX): Clean, minimalist design inspired by the native iOS Calculator. Responsive layout that automatically switches between modes on device rotation.
*   Technical Foundation: Built using the latest iOS SDK and SwiftUI. Includes comprehensive unit and basic UI tests. Adheres to all Apple App Store guidelines.
*   Currency Exchange: Convert between TWD, USD, JPY, KRW with constant rates.

### 1.4. Key Non-Functional Requirements:
*   **Performance:** Quick launch (<2s), instantaneous calculations, and a smooth, responsive UI.
*   **Accuracy:** 100% accurate mathematical calculations.
*   **Usability:** Highly intuitive, requiring no instructions.
*   **Compatibility:** Supports the latest two major iOS versions and all standard iPhone screen sizes.

### 1.5. Success Metrics:
*   **Project Completion:** The app is fully built to spec.
*   **App Store Readiness:** The app successfully passes the App Store review process.
*   **Technical Proficiency:** The codebase is clean, well-documented, and demonstrates a strong understanding of SwiftUI and testing.
*   **Functionality:** The app operates without bugs or crashes.
*   **Test Coverage:** Unit tests cover >90% of critical calculation logic.

### 1.6. Project Timeline/Milestones:
*   **M1 (Weeks 1-2):** Project Kick-off & Design (PRD, Architecture, Backlog).
*   **M2 (Weeks 3-4):** Core App Development (Portrait Mode UI, Calc Engine, Unit Tests).
*   **M3 (Weeks 5-6):** Scientific Features & UI Polish (Landscape Mode, Advanced Functions, Rotation Logic).
*   **M4 (Week 7):** Testing & App Store Preparation (E2E Testing, Bug Fixes, Asset Creation).
*   **M5 (Week 8):** Submission & Release.

### 1.7. Key Risks and Mitigation Strategies:
*   **Technical Hurdles:** Mitigated by following a strict architecture plan and allocating time for research.
*   **Scope Creep:** Mitigated by adhering strictly to this PRD for version 1.
*   **App Store Rejection:** Mitigated by proactively reviewing Apple's guidelines throughout development.
*   **Design Complexity:** Mitigated by prioritizing function over pixel-perfect cloning of complex native animations.

## 2. Problem Statement

### 2.1. The Problem:
Users often seek a calculator application on iOS that is both highly functional for everyday and scientific calculations, and aesthetically aligned with the native iOS user experience. Existing alternatives may fall short in terms of design consistency, intuitive interaction, or comprehensive feature sets, leading to a fragmented or less satisfying user experience.

### 2.2. Impact of the Problem:
Without a well-designed and feature-rich calculator, users may resort to less efficient methods for calculations, switch between multiple apps for different types of math, or feel a disconnect from the overall iOS ecosystem due to inconsistent UI/UX. This can lead to frustration, reduced productivity, and a less cohesive mobile experience.

## 3. User Stories / Use Cases

### 3.1. Core Operations (Portrait Mode):

*   **As a general user, I want to perform basic arithmetic operations (addition, subtraction, multiplication, division) so that I can quickly solve everyday math problems.**
    *   *Acceptance Criteria:*
        *   User can input numbers and operators.
        *   App displays the current input and result accurately.
        *   App correctly calculates the result of the operation.
*   **As a general user, I want to calculate percentages so that I can easily figure out discounts, tips, or proportions.**
    *   *Acceptance Criteria:*
        *   User can input a number, then the percentage operator, and another number (e.g., 50 + 10%).
        *   App correctly calculates the percentage of a number or adds/subtracts a percentage.
*   **As a general user, I want to change the sign of a number (+/−) so that I can work with positive and negative values.**
    *   *Acceptance Criteria:*
        *   User can toggle the sign of the currently displayed number.
        *   App updates the displayed number with the correct sign.
*   **As a general user, I want to clear the current input (C) or all input (AC) so that I can correct mistakes or start a new calculation.**
    *   *Acceptance Criteria:*
        *   Pressing 'C' clears the last entered number or operation.
        *   Pressing 'AC' clears all input and resets the calculator.

### 3.2. Scientific Functions (Dedicated View):

*   **As a power user, I want to access advanced mathematical functions (e.g., trigonometric, logarithmic, square root) in a dedicated scientific calculator view so that I can perform complex scientific or engineering calculations without cluttering the basic calculator interface.**
    *   *Acceptance Criteria:*
        *   A clear mechanism (e.g., a button or mode switch) is provided to navigate to the scientific calculator view.
        *   The scientific calculator view presents all advanced functions.
        *   User can input numbers and apply scientific functions within this dedicated view.
        *   App correctly calculates the result of scientific operations.
        *   The scientific calculator view operates independently of the basic calculator view.

### 3.3. User Interface & Experience:

*   **As a user, I want the calculator's design to be clean and intuitive, similar to the native iOS calculator, so that I can use it without needing instructions.**
    *   *Acceptance Criteria:*
        *   The app's layout and button placement are familiar to native iOS users.
        *   Visual feedback is provided for button presses.
*   **As a user, I want the app to automatically switch between portrait (basic) and landscape (scientific) modes when I rotate my device, so that I can seamlessly access different functionalities.**
    *   *Acceptance Criteria:*
        *   Rotating the device from portrait to landscape displays scientific functions.
        *   Rotating the device from landscape to portrait displays basic functions.

## 4. Functional Requirements

### 4.1. Core Calculator Operations (Portrait Mode)

*   **FR1: Basic Arithmetic Operations:**
    *   The system SHALL support addition, subtraction, multiplication, and division of numerical inputs.
    *   The system SHALL display the current input and the calculated result in real-time.
    *   The system SHALL handle operator precedence correctly (e.g., multiplication and division before addition and subtraction, or follow a left-to-right evaluation for simplicity if specified).
*   **FR2: Percentage Calculation:**
    *   The system SHALL calculate percentages (e.g., `X + Y%`, `X - Y%`, `X * Y%`, `X / Y%`).
    *   The system SHALL interpret `X%` as `X/100` when used in multiplication or division.
    *   The system SHALL interpret `X + Y%` as `X + (X * Y/100)`.
*   **FR3: Sign Change:**
    *   The system SHALL allow users to toggle the sign of the currently displayed number (positive/negative).
*   **FR4: Clear Functionality:**
    *   The system SHALL provide an "All Clear" (AC) function to reset all input and the current calculation.
    *   The system SHALL provide a "Clear" (C) function to clear the last entered number or operation, allowing for correction without resetting the entire calculation.

### 4.2. Scientific Calculator Operations (Landscape Mode)

*   **FR5: Advanced Mathematical Functions:**
    *   The system SHALL provide scientific functions including, but not limited to, trigonometric functions (sin, cos, tan), inverse trigonometric functions, logarithms (ln, log10), exponentiation (e^x, 10^x, x^y), square root, cube root, and factorial.
    *   These functions SHALL become accessible only when the device is in landscape orientation.
    *   The system SHALL correctly calculate the results of these scientific operations.

### 4.3. User Interface and Experience

*   **FR6: Responsive Layout:**
    *   The system SHALL automatically switch between a basic calculator layout (portrait) and a scientific calculator layout (landscape) upon device rotation.
    *   The UI SHALL adapt seamlessly to different iPhone screen sizes.
*   **FR7: Visual Feedback:**
    *   The system SHALL provide visual feedback (e.g., button press animation, highlight) when a button is tapped.
*   **FR8: Display:**
    *   The system SHALL display input and results clearly, with appropriate formatting for large numbers and decimal precision.
    *   The system SHALL handle error messages (e.g., "Error" for division by zero).

*   **FR12: Currency Exchange:**
    *   The system SHALL allow users to convert between TWD, USD, JPY, and KRW.
    *   The system SHALL use constant, predefined exchange rates for these currencies.
    *   The system SHALL display the converted amount accurately.

### 4.4. Technical Requirements (from Project Brief)

*   **FR9: Platform and Framework:**
    *   The system SHALL be built using the latest iOS SDK and SwiftUI.
*   **FR10: Testing:**
    *   The system SHALL include comprehensive unit tests for critical calculation logic (>90% coverage).
    *   The system SHALL include basic UI tests.
*   **FR11: App Store Compliance:**
    *   The system SHALL adhere to all Apple App Store guidelines.

## 5. Non-Functional Requirements

### 5.1. Performance

*   **NFR1: Launch Time:** The application SHALL launch within 2 seconds on supported devices.
*   **NFR2: Calculation Speed:** All calculations SHALL be instantaneous, with no perceptible delay for the user.
*   **NFR3: UI Responsiveness:** The user interface SHALL be smooth and responsive, with no lag during interactions or device rotations.

### 5.2. Accuracy

*   **NFR4: Mathematical Accuracy:** The system SHALL perform all mathematical calculations with 100% accuracy, adhering to standard mathematical principles and floating-point precision requirements for a calculator application.

### 5.3. Usability

*   **NFR5: Intuitive Design:** The application SHALL be highly intuitive, requiring no explicit instructions for a typical iOS user to operate.
*   **NFR6: User Experience Consistency:** The UI/UX SHALL mirror the native iOS calculator experience as closely as possible to ensure familiarity and ease of use.

### 5.4. Compatibility

*   **NFR7: iOS Version Support:** The application SHALL support the latest two major iOS versions at the time of release.
*   **NFR8: Device Compatibility:** The application SHALL support all standard iPhone screen sizes.

### 5.5. Maintainability & Testability

*   **NFR9: Code Quality:** The codebase SHALL be clean, well-structured, and adhere to established Swift/SwiftUI coding standards.
*   **NFR10: Test Coverage:** Unit tests SHALL cover greater than 90% of critical calculation logic.
*   **NFR11: Documentation:** The codebase SHALL be well-documented to facilitate future maintenance and enhancements.

### 5.6. Security

*   **NFR12: Data Privacy:** The application SHALL NOT collect or store any personal user data.
*   **NFR13: Input Validation:** The application SHALL handle invalid inputs gracefully (e.g., division by zero) without crashing or producing incorrect results.

## 6. Technical Design Considerations

### 6.1. Architecture Pattern

*   **TDC1: VIPER Architecture:** The application SHALL adopt the VIPER (View, Interactor, Presenter, Entity, Router) architectural pattern.
    *   **Rationale:** VIPER promotes a clean separation of concerns, making the codebase more modular, testable, and maintainable. This is particularly beneficial for a foundational portfolio piece where demonstrating strong architectural principles is a key success metric.
    *   **Components:**
        *   **View:** Responsible for displaying the UI and forwarding user input to the Presenter. (e.g., `CalculatorView.swift`)
        *   **Interactor:** Contains the business logic and data manipulation. It interacts with Entities and provides data to the Presenter. (e.g., `CalculatorInteractor.swift`)
        *   **Presenter:** Acts as a mediator between the View and the Interactor. It receives input from the View, requests data from the Interactor, and formats data for the View. (e.g., `CalculatorPresenter.swift`)
        *   **Entity:** Represents the data models used by the application. (e.g., `CalculatorEntity.swift`)
        *   **Router:** Handles navigation between different modules/screens. (e.g., `CalculatorRouter.swift`)

### 6.2. Technology Stack

*   **TDC2: iOS SDK & SwiftUI:** The application SHALL be built exclusively using the latest available iOS SDK and SwiftUI for UI development.
    *   **Rationale:** Aligns with the Project Brief's goal of demonstrating core competencies in SwiftUI and leveraging modern iOS development practices.
*   **TDC3: Swift Programming Language:** All application logic SHALL be written in Swift.
    *   **Rationale:** Standard for iOS development, offering safety, performance, and modern language features.

### 6.3. Core Logic Implementation

*   **TDC4: Calculation Engine:** A dedicated, robust calculation engine SHALL be implemented within the Interactor layer to handle all arithmetic and scientific operations.
    *   **Rationale:** Centralizing calculation logic ensures accuracy, consistency, and simplifies testing. It also allows for easier updates or extensions of mathematical functions.
    *   **Considerations:**
        *   Handling of floating-point precision to avoid common errors.
        *   Order of operations (PEMDAS/BODMAS) for complex expressions.
        *   Error handling for invalid operations (e.g., division by zero, invalid input for scientific functions).

### 6.4. UI/UX Implementation

*   **TDC5: Adaptive Layout & View Separation:** SwiftUI's layout system SHALL be utilized to create a responsive UI that adapts to different device orientations (portrait/landscape) and screen sizes. The Scientific Calculator SHALL reside in a dedicated, separate view, accessible via a clear navigation mechanism, and SHALL NOT be mixed with the traditional calculator interface.
    *   **Rationale:** Directly addresses the requirement for seamless mode switching and broad device compatibility, while ensuring a clean separation of concerns for different calculator modes as explicitly requested by the user.
*   **TDC6: Native-like Experience:** Custom SwiftUI views and modifiers SHALL be designed to mimic the visual appearance and interaction patterns of the native iOS calculator.
    *   **Rationale:** Fulfills the product vision of mirroring the native iOS user experience.

### 6.5. Testing Strategy

*   **TDC7: Unit Testing:** Unit tests SHALL be written for all critical business logic within the Interactor and Entity layers, aiming for >90% coverage of calculation logic.
    *   **Rationale:** Ensures mathematical accuracy and reliability of the core functionality.
*   **TDC8: UI Testing:** Basic UI tests SHALL be implemented to verify key user flows and UI responsiveness across different orientations.
    *   **Rationale:** Confirms that the user interface behaves as expected and adapts correctly.

### 6.6. Version Control & CI/CD

*   **TDC9: Git for Version Control:** Git SHALL be used for source code management.
*   **TDC10: CI/CD Pipeline:** A Continuous Integration/Continuous Deployment (CI/CD) pipeline SHALL be set up to automate builds, run tests, and facilitate deployment.
    *   **Rationale:** Ensures code quality, speeds up development cycles, and supports the "App Store Readiness" success metric.

## 7. Open Questions and Future Considerations

### 7.1. Open Questions / Decisions to Be Made

*   **OQ1: Specific Scientific Functions:** All standard scientific functions typically found in an iOS scientific calculator will be included.
    *   *Decision Point:* All standard scientific functions will be implemented for the initial release.
*   **OQ2: Error Handling Details:** Error messages and display mechanisms will be tailored to each specific function and error condition.
    *   *Decision Point:* Error messages and display mechanisms will be defined on a per-function/per-error basis.
*   **OQ3: Operator Precedence:** The system will strictly follow mathematical precedence (PEMDAS/BODMAS) for basic operations.
    *   *Decision Point:* Strict mathematical precedence (PEMDAS/BODMAS) will be followed for basic operations.
*   **OQ4: Decimal Precision:** The application will maintain high decimal precision for calculations and display, leveraging the capabilities of the `Decimal` type.
    *   *Decision Point:* High decimal precision will be maintained internally and displayed to the user, leveraging the `Decimal` type.

### 7.2. Future Considerations / Out of Scope for V1

*   **FC1: History/Memory Functionality:**
    *   **Description:** Implement a history of past calculations or a memory function (M+, M-, MR, MC) for storing and recalling numbers.
    *   **Rationale:** Enhances usability for complex or repetitive calculations.
*   **FC2: Theming/Customization:**
    *   **Description:** Allow users to customize the app's theme (e.g., dark mode, different color schemes).
    *   **Rationale:** Improves personalization and accessibility.
*   **FC3: Haptic Feedback:**
    *   **Description:** Integrate haptic feedback for button presses.
    *   **Rationale:** Provides a more tactile and engaging user experience.
*   **FC4: iPad Support:**
    *   **Description:** Extend compatibility to iPad devices, potentially with a redesigned layout optimized for larger screens.
    *   **Rationale:** Broadens the user base and device reach.
*   **FC5: Advanced Graphing/Equation Solving:**
    *   **Description:** Introduce capabilities for graphing functions or solving complex equations.
    *   **Rationale:** Caters to a more advanced user segment (e.g., students, engineers).
*   **FC6: Unit Conversion:**
    *   **Description:** Add functionality for converting between different units (e.g., length, weight, temperature).
    *   **Rationale:** Increases the utility of the app beyond basic calculations.
