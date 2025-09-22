# 7. Open Questions and Future Considerations

## 7.1. Open Questions / Decisions to Be Made

*   **OQ1: Specific Scientific Functions:** All standard scientific functions typically found in an iOS scientific calculator will be included.
    *   *Decision Point:* All standard scientific functions will be implemented for the initial release.
*   **OQ2: Error Handling Details:** Error messages and display mechanisms will be tailored to each specific function and error condition.
    *   *Decision Point:* Error messages and display mechanisms will be defined on a per-function/per-error basis.
*   **OQ3: Operator Precedence:** The system will strictly follow mathematical precedence (PEMDAS/BODMAS) for basic operations.
    *   *Decision Point:* Strict mathematical precedence (PEMDAS/BODMAS) will be followed for basic operations.
*   **OQ4: Decimal Precision:** The application will maintain high decimal precision for calculations and display, leveraging the capabilities of the `Decimal` type.
    *   *Decision Point:* High decimal precision will be maintained internally and displayed to the user, leveraging the `Decimal` type.

## 7.2. Future Considerations / Out of Scope for V1

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
