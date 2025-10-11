# Story: Expense List

## Status
Draft

## Story
**As a** user,
**I want** to view a list of all expenses for the current month, sorted by date, with a clear display of each record's details and the monthly total, and be able to easily delete or edit records,
**so that** I can quickly review and manage my family's spending.

## Description
The application will present the monthly expense data in a clear and organized list format. Each individual expense record will be displayed as a list item, prominently featuring the `Date`, `Name`, `Category`, and `Amount`. The `Date` will be displayed in a user-friendly format (e.g., "Oct 11, 2025"), the `Name` will be the user-defined description of the expense, the `Category` will indicate the assigned category (e.g., "Groceries", "Utilities"), and the `Amount` will show the monetary value of the expense.

At the bottom of the expense list, a prominent display will show the accurately calculated monthly total expenditure, providing an immediate overview of the family's spending for the selected month.

For efficient management, users will be able to interact with individual expense records:
-   **Swipe-to-Delete:** Swiping left or right on an expense record will reveal a "Delete" option. Upon tapping "Delete," a confirmation prompt will appear (e.g., "Are you sure you want to delete this expense? This action cannot be undone."), requiring user confirmation before permanent deletion.
-   **Long-Press-to-Edit:** A long-press gesture on an expense record will initiate an edit action. This will lead to an editable form or dialog pre-populated with the existing expense details, allowing the user to modify the `Date`, `Name`, `Category`, or `Amount`.

Clear visual feedback will be provided for all user interactions. For instance, a subtle animation or color change will indicate a successful swipe-to-delete action, and a toast message or similar notification will confirm successful deletions and edits.

## Acceptance Criteria
-   The application displays a list of all expense records for the currently selected month.
-   Expense records are sorted by date in descending order (most recent first).
-   Each record in the list clearly shows its `Date`, `Name`, `Category`, and `Amount`.
-   The monthly total expenditure is accurately calculated and prominently displayed at the bottom of the list.
-   Users can swipe left or right on an expense record to reveal a delete option, with a confirmation prompt.
-   Users can long-press on an expense record to initiate an edit action, leading to an editable form or dialog.
-   Visual feedback is provided for successful deletions and edits.
-   The application provides clear feedback to the user if an expense record deletion or edit fails due to a network error or API issue.

## Tasks / Subtasks
- [ ] Implement UI for displaying expense list (AC: 1, 3)
  - [ ] Design and implement list item widget for an expense record
  - [ ] Create a scrollable list view to display multiple expense records
- [ ] Implement logic for sorting expenses by date (AC: 2)
  - [ ] Ensure data fetched from Google Sheets is sorted before display
- [ ] Implement calculation and display of monthly total expenditure (AC: 4)
  - [ ] Aggregate `Amount` from all records for the current month
  - [ ] Display the total in a dedicated UI element at the bottom of the list
- [ ] Implement swipe-to-delete UI and logic with confirmation (AC: 5, 7)
  - [ ] Integrate `Dismissible` widget or similar for swipe action
  - [ ] Implement confirmation dialog before actual deletion
  - [ ] Call Expense Record CRUD delete method
- [ ] Implement long-press-to-edit UI and logic (AC: 6, 7)
  - [ ] Detect long-press gesture on list item
  - [ ] Navigate to an edit form/dialog pre-populated with record data
  - [ ] Call Expense Record CRUD update method upon form submission
- [ ] Implement visual feedback for CRUD operations (AC: 7)
  - [ ] Show loading indicators during API calls
  - [ ] Display success/error messages (e.g., SnackBar, Toast)
- [ ] Integrate with Expense Record CRUD functionality (AC: 5, 6)
  - [ ] Ensure the Expense List UI correctly calls the underlying CRUD service for delete and update operations.
- [ ] Implement error handling for list display and CRUD operations (AC: 8)
  - [ ] Display user-friendly error messages for failed data loads or CRUD actions.

## Dev Notes
### General
This story focuses on the core user interface for viewing and managing monthly expenses. Emphasis is on a clear, interactive, and responsive list display with intuitive gestures for common actions like deleting and editing records. Performance for potentially long lists is a key consideration.

### Relevant Source Tree Info
- `lib/screens/expense_list_screen.dart`: Main screen for displaying the expense list.
- `lib/widgets/expense_list_item.dart`: Widget for displaying a single expense record.
- `lib/providers/expense_provider.dart`: State management for expense records (fetching, sorting, calculating total).
- `lib/services/google_sheets_service.dart`: Interacts with Google Sheets API for CRUD operations.

### Testing
- **Test file location:** `test/screens/expense_list_screen_test.dart`, `test/widgets/expense_list_item_test.dart`, `test/providers/expense_provider_test.dart`.
- **Test standards:** Unit tests for sorting logic and total calculation. Widget tests for list item rendering, swipe-to-delete, and long-press-to-edit interactions. Integration tests for end-to-end CRUD operations with mocked Google Sheets API.
- **Testing frameworks and patterns to use:** `flutter_test`, `mockito` for mocking dependencies.
- **Any specific testing requirements for this story:**
  - Verify correct display of all expense record fields.
  - Test accurate calculation and display of monthly total.
  - Test swipe-to-delete flow, including confirmation dialog and actual deletion call.
  - Test long-press-to-edit flow, including form pre-population and update call.
  - Verify visual feedback for all interactions.
  - Test error handling for data loading and CRUD operations.

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
