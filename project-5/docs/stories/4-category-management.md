# Story: Category Management

## Status
Draft

## Story
**As a** user,
**I want** to manage expense categories in Google Sheets, including adding, editing, and deleting them, and have these changes automatically reflected in the application,
**so that** my expense tracking is consistent and up-to-date.

## Description
This story focuses on enabling users to define and organize their spending categories through a seamless integration with Google Sheets. The 'Category' Google Sheet tab will serve as the single source of truth for all expense categories. Users will be able to add new categories, modify existing ones, and delete categories directly within this Google Sheet.

A critical aspect of this feature is the automatic synchronization between the Google Sheet and the application. Any changes made by the user in the 'Category' Google Sheet tab (additions, edits, or deletions) must be immediately visible and usable within the application. This ensures data consistency across all platforms and eliminates the need for manual updates within the application itself, providing a unified and up-to-date expense tracking experience.

## Acceptance Criteria
-   The application successfully reads and displays all `CategoryName` and `ColorCode` entries from the 'Category' Google Sheet tab.
-   Changes (additions, edits, deletions) made to categories in the Google Sheet are reflected in the application upon manual refresh (initial version).
-   The application handles cases where `CategoryName` or `ColorCode` might be invalid or missing from Google Sheets gracefully (e.g., using default values or error indicators).
-   The application prevents the deletion of a category from Google Sheets if it is actively used in existing expense records, or provides a clear mechanism for reassigning such expenses.

## Tasks / Subtasks
- [ ] Implement Google Sheets API client for reading 'Category' tab (AC: 1)
  - [ ] Define API call to fetch all rows from 'Category' sheet
  - [ ] Handle API authentication and error responses
- [ ] Develop data models for `Category` (CategoryName, ColorCode) (AC: 1)
  - [ ] Create Dart class for Category with `fromJson` and `toJson` methods
- [ ] Implement logic to read and display categories in the app (AC: 1)
  - [ ] Create a Provider/Riverpod state for categories
  - [ ] Display categories in a list or dropdown UI component
- [ ] Handle `ColorCode` parsing and display (AC: 1)
  - [ ] Convert hex string `ColorCode` to Flutter `Color` object
  - [ ] Apply colors to category display in UI
- [ ] Implement basic validation for category data (AC: 3)
  - [ ] Ensure `CategoryName` is not empty
  - [ ] Validate `ColorCode` format (e.g., hex string)
- [ ] Implement manual refresh mechanism for categories (AC: 2)
  - [ ] Add a refresh button or pull-to-refresh gesture to trigger category re-fetch
- [ ] Implement logic to prevent deletion of categories used in expenses (or reassign) (AC: 4)
  - [ ] (Consideration: This might depend on Expense Record CRUD being available to check for usage)

## Dev Notes
### General
This story focuses on integrating category management with Google Sheets. The 'Category' sheet is the single source of truth. The application will primarily read from this sheet, with manual refresh for updates. Referential integrity for category deletion is a key consideration.

### Relevant Source Tree Info
- `lib/models/category.dart`: New file for Category data model.
- `lib/services/google_sheets_service.dart`: Existing or new service for Google Sheets API interactions.
- `lib/providers/category_provider.dart`: New file for state management of categories.
- `lib/widgets/category_list.dart` or similar: UI component to display categories.

### Testing
- **Test file location:** `test/models/category_test.dart`, `test/services/google_sheets_service_test.dart`, `test/providers/category_provider_test.dart`.
- **Test standards:** Unit tests for data model parsing, service methods (mocking API calls), and provider logic. Widget tests for UI display of categories.
- **Testing frameworks and patterns to use:** `flutter_test`, `mockito` for mocking API responses.
- **Any specific testing requirements for this story:**
  - Verify successful parsing of `CategoryName` and `ColorCode`.
  - Test graceful handling of invalid `ColorCode` formats.
  - Confirm categories are displayed correctly in the UI.
  - Test manual refresh functionality.
  - Test the logic for preventing/handling category deletion when in use (once expense records are available).

## Change Log
| Date       | Version | Description                | Author |
|------------|---------|----------------------------|--------|
| 2025-10-11 | 1.0     | Initial detailed story draft | Sarah  |

## Dev Agent Record
### Agent Model Used
{{agent_model_name_version}}

### Debug Log References
- None yet

### Completion Notes List
- None yet

### File List
- None yet

## QA Results
- None yet
