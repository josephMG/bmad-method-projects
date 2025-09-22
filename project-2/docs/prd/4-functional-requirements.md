# 4. Functional Requirements

## 4.1. Core Calculator Operations (Portrait Mode)

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

## 4.2. Scientific Calculator Operations (Landscape Mode)

*   **FR5: Advanced Mathematical Functions:**
    *   The system SHALL provide scientific functions including, but not limited to, trigonometric functions (sin, cos, tan), inverse trigonometric functions, logarithms (ln, log10), exponentiation (e^x, 10^x, x^y), square root, cube root, and factorial.
    *   These functions SHALL become accessible only when the device is in landscape orientation.
    *   The system SHALL correctly calculate the results of these scientific operations.

## 4.3. User Interface and Experience

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

## 4.4. Technical Requirements (from Project Brief)

*   **FR9: Platform and Framework:**
    *   The system SHALL be built using the latest iOS SDK and SwiftUI.
*   **FR10: Testing:**
    *   The system SHALL include comprehensive unit tests for critical calculation logic (>90% coverage).
    *   The system SHALL include basic UI tests.
*   **FR11: App Store Compliance:**
    *   The system SHALL adhere to all Apple App Store guidelines.
