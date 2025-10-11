## Product Requirements Document (PRD) for BMad-FamilyExpenseTracker

### 1. Introduction

#### 1.1 Project Overview

The `BMad-FamilyExpenseTracker` is a cross-platform Flutter application designed to help families collaboratively manage and track their monthly expenses. The core functionality revolves around real-time synchronization with Google Sheets, allowing multiple family members to record, view, and modify expense data. Each month's expenses are automatically saved to a dedicated Google Sheet tab (e.g., `2025-10`), and users can easily navigate through different months within the app to review records and total expenditures.

#### 1.2 Goals

*   To provide a user-friendly mobile application for tracking family expenses.
*   To enable collaborative expense management among family members.
*   To leverage Google Sheets as a flexible and accessible backend for data storage and synchronization.
*   To offer a clear overview of monthly spending.

### 2. Functional Requirements

#### 2.1 Application Platform

*   **Requirement:** Use Flutter to build for iOS and Android.
*   **Analysis:**
    *   **Ambiguities/Clarifications:** None. This is a clear statement of the target platforms and framework.
    *   **Dependencies:** Flutter SDK, platform-specific build tools (Xcode for iOS, Android Studio for Android).
    *   **Missing Requirements:** N/A.

#### 2.2 Category Management

*   **Requirement:** All expense categories are stored in the first Google Sheet tab named `Category`. Each category includes `CategoryName` and an optional `ColorCode`. Adding, deleting, or editing categories in Google Sheets should automatically sync with the application.
*   **Analysis:**
    *   **Ambiguities/Clarifications:**
        *   "Automatically sync": Does this imply real-time push notifications from Google Sheets to the app, or is a pull-based mechanism (e.g., refreshing on app launch/foreground) sufficient for the initial version? The "Google Sheet Sync" section clarifies manual refresh for the initial version.
        *   How are `ColorCode` values validated? What format is expected (e.g., hex codes like `#RRGGBB`)?
        *   What happens if a `CategoryName` is deleted from Google Sheets but existing expense records still reference it?
    *   **Dependencies:** Google Sheets API for reading category data.
    *   **Missing Requirements:**
        *   **Category Validation:** The app should handle cases where `CategoryName` is missing or `ColorCode` is invalid.
        *   **Referential Integrity:** Define behavior when a category used in existing expenses is deleted. Options include: preventing deletion, marking expenses with a "deleted category" placeholder, or reassigning to a default category.
        *   **In-app Category Management:** While the spec mentions managing categories in Google Sheets, allowing users to add/edit/delete categories directly within the app would significantly enhance usability. This could then write back to Google Sheets.

#### 2.3 Monthly Data Structure

*   **Requirement:** Each month has its own Google Sheet tab, named `YYYY-MM`. Each tab stores that month's expense records.
*   **Analysis:**
    *   **Ambiguities/Clarifications:**
        *   Who creates these monthly tabs? Does the app create them automatically when a user navigates to a new month, or are they expected to be pre-created in Google Sheets? The former is more user-friendly.
        *   What happens if a `YYYY-MM` tab is deleted or renamed in Google Sheets?
    *   **Dependencies:** Google Sheets API for reading/writing to specific tabs, and for creating new tabs.
    *   **Missing Requirements:**
        *   **Tab Creation Logic:** The app should automatically create a new `YYYY-MM` tab if it doesn't exist when a user attempts to view/add expenses for that month.
        *   **Error Handling for Missing Tabs:** Graceful handling if a tab is unexpectedly missing or inaccessible.

#### 2.4 Expense Record Format

*   **Requirement:** Each record should contain `Date` (YYYY-MM-DD), `Name` (item name), `Category` (matching `Category` tab), `Amount` (integer or float). Users can add/delete/modify records in the app, with updates written back to the corresponding monthly Google Sheet tab.
*   **Analysis:**
    *   **Ambiguities/Clarifications:**
        *   **Data Types:** Clarify exact data types for `Amount` (e.g., `double` in Flutter).
        *   **Validation:** What are the validation rules for each field (e.g., `Date` format, `Amount` non-negative, `Category` must exist)?
        *   **Uniqueness/IDs:** How are individual expense records uniquely identified for modification or deletion? Google Sheets rows don't have inherent stable IDs. This is a critical point for reliable CRUD operations.
    *   **Dependencies:** Google Sheets API for CRUD operations on rows.
    *   **Missing Requirements:**
        *   **Unique Identifier for Records:** A hidden column in Google Sheets (e.g., `RecordID` or `UUID`) would be crucial for reliably updating and deleting specific records. This ID should be generated by the app.
        *   **User Field:** To support multi-user collaboration, a `User` field (e.g., `RecordedBy`) indicating who added the expense would be beneficial.
        *   **Timestamp:** A `CreatedAt` or `LastModified` timestamp would be useful for auditing and conflict resolution.
        *   **Notes/Description:** An optional `Notes` field for additional details.

#### 2.5 Expense List

*   **Requirement:** Display all current month's records (sorted by date). Each record shows Date, Name, Category, Amount. Monthly total expenditure displayed at the bottom. Supports swipe-to-delete and long-press-to-edit.
*   **Analysis:**
    *   **Ambiguities/Clarifications:**
        *   **Sorting Order:** Ascending or descending date? (Typically descending for most recent first).
        *   **UI/UX for CRUD:** How will the long-press-to-edit interaction work (e.g., modal dialog, navigate to new screen)?
    *   **Dependencies:** Data layer for fetching and manipulating expense records.
    *   **Missing Requirements:**
        *   **Filtering/Searching:** Ability to filter expenses by category or search by name.
        *   **Grouping:** Option to group expenses by category or day.
        *   **Visual Feedback:** Clear visual feedback for swipe-to-delete and successful edits/deletions.

#### 2.6 Month Navigation

*   **Requirement:** Provide a month navigator UI component. Users can quickly navigate to previous/next month or jump to a specific month using a month picker. App automatically loads data from the corresponding Google Sheet tab when switching months.
*   **Analysis:**
    *   **Ambiguities/Clarifications:**
        *   **Month Picker UI:** Specify the type of month picker (e.g., calendar-based, dropdown).
    *   **Dependencies:** UI components, data loading logic.
    *   **Missing Requirements:**
        *   **Year Navigation:** Ability to navigate between years, not just months.
        *   **Current Month Button:** A quick way to return to the current month.

#### 2.7 Google Sheet Sync

*   **Requirement:** App automatically loads categories and current month's data on startup. If users directly edit the spreadsheet, the app can refresh to sync changes. Initial version supports manual sync; automatic background sync can be added later.
*   **Analysis:**
    *   **Ambiguities/Clarifications:**
        *   **Manual Sync Trigger:** How is manual sync initiated (e.g., pull-to-refresh, dedicated button)?
        *   **Conflict Resolution:** What happens if the app has unsynced local changes and a manual refresh pulls conflicting changes from Google Sheets? This is a major challenge for real-time/two-way sync.
    *   **Dependencies:** Google Sheets API, network connectivity.
    *   **Missing Requirements:**
        *   **Offline Mode (Future):** While manual sync is initial, a robust offline mode with eventual consistency is crucial for a good user experience.
        *   **Sync Status Indicator:** Visual feedback to the user about sync status (e.g., "Syncing...", "Last synced: X minutes ago", "Offline").
        *   **Error Handling for Sync Failures:** Clear messages and retry mechanisms for network issues or API errors.

### 3. Non-Functional Requirements

*   **Performance:**
    *   App startup time should be minimal (e.g., < 3 seconds).
    *   Data loading for a month should be fast (e.g., < 2 seconds for typical data volumes).
    *   Smooth UI transitions and responsiveness.
*   **Security:**
    *   Secure handling of Google OAuth tokens.
    *   Data transmission to/from Google Sheets API must be encrypted (HTTPS).
    *   Protection against unauthorized access to Google Sheets data.
*   **Usability:**
    *   Intuitive and easy-to-use interface for all family members.
    *   Clear feedback for all user actions (e.g., success messages, error messages).
    *   Adherence to Material 3 design guidelines for a consistent look and feel.
*   **Scalability:**
    *   The Google Sheets backend has inherent limitations (e.g., row limits, API rate limits). The initial design should acknowledge these.
    *   The architecture should allow for a future transition to a more scalable backend (e.g., PostgreSQL) without a complete rewrite of the frontend.
*   **Maintainability:**
    *   Clean, well-documented Flutter codebase.
    *   Modular architecture using Riverpod/Provider for state management.
    *   Automated testing (unit, widget, integration) to ensure code quality.
*   **Reliability:**
    *   Robust error handling for API calls, network issues, and data inconsistencies.
    *   Data integrity should be maintained even during sync operations.

### 4. Technical Design Considerations

*   **Flutter Framework:** Leverage Flutter's widget-based architecture for UI development.
*   **Google Sheets API Integration:**
    *   Use a dedicated Flutter package for Google Sheets API interaction (e.g., `googleapis_auth`, `googleapis`).
    *   **Challenges:**
        *   **Authentication:** Implementing Google OAuth securely for mobile applications.
        *   **API Rate Limits:** Google Sheets API has rate limits. Design the app to minimize API calls, especially for frequent operations. Caching will be crucial.
        *   **Data Structure Mapping:** Mapping Google Sheets row data to Flutter data models and vice-versa.
        *   **Real-time Sync:** True real-time sync (push notifications from Google Sheets) is not directly supported by the Sheets API. A polling mechanism or manual refresh will be necessary for the initial version.
        *   **Unique Row Identification:** As noted in functional requirements, Google Sheets lacks stable row IDs. A custom ID column will be needed.
*   **State Management (Riverpod/Provider):** Choose one (Riverpod is generally preferred for new projects due to its robustness and testability) and apply it consistently for managing application state, especially data fetched from Google Sheets.
*   **UI/UX (Material 3):** Adhere to Material 3 guidelines for a modern and consistent user experience.
*   **Data Layer:** Abstract Google Sheets API calls behind a repository pattern to decouple the UI from the data source, making it easier to switch to a different backend later.
*   **Error Handling:** Implement a global error handling strategy to catch and display errors gracefully.

### 5. Data Model

#### 5.1 Proposed Schema Review

*   **Worksheet: `Category`**
    *   `CategoryName`: String. (Good)
    *   `ColorCode`: String (e.g., hex code). (Good, but needs validation).
*   **Worksheet: `YYYY-MM`**
    *   `Date`: String (YYYY-MM-DD). (Good)
    *   `Name`: String. (Good)
    *   `Category`: String (matches `CategoryName`). (Good, but needs referential integrity checks).
    *   `Amount`: Number (integer or float). (Good)

#### 5.2 Suggested Improvements / Additional Fields

*   **Worksheet: `Category`**
    *   `CategoryID`: (Hidden column, UUID) - For stable internal referencing, especially if `CategoryName` can change.
    *   `IsActive`: Boolean - To soft-delete categories instead of hard deletion, preserving historical data integrity.
*   **Worksheet: `YYYY-MM`**
    *   `RecordID`: (Hidden column, UUID) - **CRITICAL** for reliable update and delete operations on specific expense records. This should be generated by the app.
    *   `RecordedBy`: String (e.g., Google User ID or Name) - To track which family member added the expense.
    *   `CreatedAt`: Timestamp - For auditing and potential conflict resolution.
    *   `LastModified`: Timestamp - For auditing and potential conflict resolution.
    *   `Notes`: String (optional) - For additional details about the expense.
    *   `Currency`: String (e.g., "USD", "TWD") - If multi-currency support is ever considered, or just to explicitly state the currency.

### 6. Future Enhancements/Roadmap

#### 6.1 Discussion and Prioritization

1.  **Offline Caching + Automatic Sync (High Priority):**
    *   **Discussion:** This is crucial for a robust mobile experience. Users expect to be able to use the app without constant internet connectivity. Automatic background sync would greatly improve convenience.
    *   **Prerequisites:**
        *   Local database (e.g., Hive, Sqflite, Isar) for caching.
        *   Robust conflict resolution strategy (e.g., last-write-wins, user-prompted resolution).
        *   Background task execution for automatic sync.
    *   **Architectural Changes:** Introduction of a local data layer, sync manager service.

2.  **Google Drive JSON Config Sync (Medium Priority):**
    *   **Discussion:** This would make the app more flexible by allowing users to easily switch Google Sheets or configure other parameters without code changes.
    *   **Prerequisites:** Google Drive API integration.
    *   **Architectural Changes:** Configuration service to read/write JSON from Google Drive.

3.  **Add Visual Analytics (Pie/Bar Charts) (Medium Priority):**
    *   **Discussion:** `fl_chart` is already in the tech stack. Visualizations are key for understanding spending patterns.
    *   **Prerequisites:** Data aggregation logic (e.g., sum expenses by category, by day).
    *   **Architectural Changes:** Analytics service/provider to prepare data for charts.

4.  **Replace Google Sheet with Python FastAPI + PostgreSQL Backend (Low Priority, but strategic):**
    *   **Discussion:** This is a significant architectural shift, moving from a "serverless" Google Sheets backend to a full-fledged custom backend. It addresses scalability, custom logic, and advanced features like user roles.
    *   **Prerequisites:**
        *   Design and implementation of FastAPI backend with PostgreSQL.
        *   Migration strategy for existing Google Sheets data.
        *   New authentication system (e.g., JWT).
    *   **Architectural Changes:** Complete overhaul of the data layer, new API client in Flutter, new authentication flow.
    *   **Sub-features:**
        *   **Family Account Login / Role-based Permissions:** Essential for a custom backend.
        *   **Expense/Category CRUD:** Core functionality, but now via custom API.
        *   **Export Reports (CSV/PDF):** Can be implemented on the backend.

### 7. Risk Analysis

*   **Development Risks:**
    *   **Google Sheets API Complexity:** Learning curve for API, handling rate limits, and managing authentication tokens securely.
    *   **Real-time Sync Challenges:** Achieving reliable two-way synchronization with Google Sheets, especially conflict resolution, is complex.
    *   **Flutter Learning Curve:** If the team is new to Flutter, initial development might be slower.
    *   **UI/UX Implementation:** Ensuring a smooth and intuitive user experience across both platforms.
*   **Deployment Risks:**
    *   **Platform-Specific Issues:** Potential issues with iOS/Android build processes, permissions, or specific device behaviors.
    *   **Google OAuth Configuration:** Correctly configuring OAuth credentials for production environments.
*   **Maintenance Risks:**
    *   **Google Sheets API Changes:** Future changes to the Google Sheets API could break existing functionality.
    *   **Flutter Version Upgrades:** Keeping the app updated with the latest Flutter versions and managing dependencies.
    *   **Data Integrity Issues:** Inconsistent data due to sync conflicts or manual edits in Google Sheets.
*   **Scalability Risks:**
    *   **Google Sheets Limitations:** Google Sheets has row limits (currently 10 million cells) and API rate limits. For very large families or extensive historical data, this could become a bottleneck.
    *   **Performance with Large Data:** Loading and processing large amounts of data from Google Sheets might become slow.

---

## Development-Ready Task Breakdown

Here is a numbered list of actionable tasks, with estimated effort levels and suggested agent assignments.

1.  **Project Setup & Core Dependencies**
    *   **Task:** Initialize Flutter project, configure `pubspec.yaml` with core dependencies (e.g., `http`, `provider`/`riverpod`, `google_sign_in`, `googleapis_auth`, `googleapis`).
    *   **Effort:** Small
    *   **Agent:** @bmad-dev
2.  **Google OAuth Integration**
    *   **Task:** Implement Google OAuth for user authentication, ensuring secure token storage and refresh mechanisms.
    *   **Effort:** Medium
    *   **Agent:** @bmad-dev, @bmad-architect (for security review)
3.  **Google Sheets API Client & Data Layer**
    *   **Task:** Develop a service/repository to interact with Google Sheets API (read/write). Implement methods for fetching categories, reading monthly expenses, and writing/updating/deleting expense records.
    *   **Effort:** Large
    *   **Agent:** @bmad-dev, @bmad-architect (for API design)
4.  **Category Management Implementation**
    *   **Task:** Implement logic to read categories from the `Category` sheet. Handle `ColorCode` parsing and display. Implement basic validation for category data.
    *   **Effort:** Medium
    *   **Agent:** @bmad-dev
5.  **Monthly Tab Management**
    *   **Task:** Implement logic to check for existing `YYYY-MM` tabs and automatically create new ones if they don't exist when a user navigates to a new month.
    *   **Effort:** Medium
    *   **Agent:** @bmad-dev
6.  **Expense Record Data Model & CRUD Operations**
    *   **Task:** Define Flutter data models for `ExpenseRecord`. Implement CRUD operations (Add, Edit, Delete) that interact with the Google Sheets API, including generating and managing `RecordID` (UUID) for each expense.
    *   **Effort:** Large
    *   **Agent:** @bmad-dev
7.  **Expense List UI**
    *   **Task:** Design and implement the UI for displaying the current month's expense list, including date, name, category, amount, and monthly total. Implement sorting by date.
    *   **Effort:** Medium
    *   **Agent:** @bmad-ux-expert, @bmad-dev
8.  **Swipe-to-Delete & Long-Press-to-Edit UI/Logic**
    *   **Task:** Implement swipe-to-delete functionality for expense records with confirmation. Implement long-press-to-edit, opening an edit form/dialog.
    *   **Effort:** Medium
    *   **Agent:** @bmad-ux-expert, @bmad-dev
9.  **Month Navigation UI**
    *   **Task:** Develop the month navigator UI component (previous/next buttons, month picker). Implement logic to load data for the selected month.
    *   **Effort:** Medium
    *   **Agent:** @bmad-ux-expert, @bmad-dev
10. **Manual Sync & Refresh Mechanism**
    *   **Task:** Implement a manual refresh mechanism (e.g., pull-to-refresh or a dedicated button) to re-fetch data from Google Sheets.
    *   **Effort:** Small
    *   **Agent:** @bmad-dev
11. **Error Handling & User Feedback**
    *   **Task:** Implement robust error handling for API calls and network issues. Provide clear user feedback for success/failure of operations and sync status.
    *   **Effort:** Medium
    *   **Agent:** @bmad-dev, @bmad-ux-expert
12. **Initial Data Model Enhancements (Hidden Columns)**
    *   **Task:** Modify the data layer to include `RecordID`, `RecordedBy`, `CreatedAt`, `LastModified` as hidden columns in Google Sheets for new records.
    *   **Effort:** Medium
    *   **Agent:** @bmad-dev, @bmad-architect
13. **Unit & Widget Testing**
    *   **Task:** Write unit tests for data models, services, and state management logic. Write widget tests for key UI components.
    *   **Effort:** Large (ongoing)
    *   **Agent:** @bmad-dev, @bmad-qa
14. **Integration Testing**
    *   **Task:** Develop integration tests to verify end-to-end flows, especially involving Google Sheets API interactions.
    *   **Effort:** Medium
    *   **Agent:** @bmad-dev, @bmad-qa
15. **Documentation**
    *   **Task:** Document API usage, data models, state management patterns, and deployment steps.
    *   **Effort:** Medium (ongoing)
    *   **Agent:** @bmad-dev, @bmad-architect
