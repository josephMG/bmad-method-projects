# Technology Stack for BMad-FamilyExpenseTracker

This document details the core technologies and frameworks used in the development of the `BMad-FamilyExpenseTracker` application.

## 1. Frontend

*   **Framework:** Flutter 3.x
    *   **Platform Support:** iOS, Android
    *   **Language:** Dart
*   **UI Framework:** Material 3 Design
*   **State Management:** Riverpod (preferred) or Provider
*   **Charting/Visualization (Future):** `fl_chart`

## 2. Backend / Data Storage

*   **Primary Data Source:** Google Sheets API
    *   **Purpose:** Collaborative data storage, real-time synchronization (via manual refresh initially).
*   **Authentication:** Google OAuth
    *   **Purpose:** Secure user authentication and authorization for Google services.

## 3. Data Layer

*   **API Interaction:** REST API calls to Google Sheets API, potentially using Flutter packages like `googleapis_auth` and `googleapis`.
*   **Data Models:** Custom Dart classes for mapping Google Sheets data (e.g., `ExpenseRecord`, `Category`).

## 4. Development Tools & Environment

*   **IDE:** VS Code, Android Studio, Xcode
*   **Version Control:** Git
*   **Package Management:** `pub` (Dart/Flutter package manager)

## 5. Future Considerations (Scalability & Evolution)

The architecture is designed to allow for a future transition to a more robust backend if Google Sheets limitations become a bottleneck.

*   **Potential Backend Replacement:** Python FastAPI + PostgreSQL
    *   **Features:** Custom API, user authentication/roles, advanced querying, improved scalability.
*   **Local Caching:** Introduction of local databases (e.g., Hive, Sqflite, Isar) for offline support and performance optimization.
