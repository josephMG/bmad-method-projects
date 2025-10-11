# Story: Expense Record Format

## Status
Draft

## Story
**As a** user,
**I want** to add, edit, and delete individual expense records, including details like date, name, category, and amount, and have these changes accurately saved to the correct monthly Google Sheet,
**so that** I can maintain a precise and up-to-date log of my family's spending.

## Description
This story details the process of creating, updating, and deleting individual expense records within the application. Each record will require specific fields: `Date` (YYYY-MM-DD), `Name` (a descriptive item name), `Category` (selected from predefined categories), and `Amount` (integer or float). Robust data types and validation rules will be applied to ensure data quality.

A critical aspect is the implementation of a unique identifier (`RecordID`, preferably a UUID) for each expense record. This `RecordID` will be crucial for reliably performing Create, Read, Update, and Delete (CRUD) operations, especially when interacting with Google Sheets where native row IDs are not stable. All changes made within the application will be accurately reflected in the corresponding monthly Google Sheet tab.

Furthermore, to enhance data integrity and auditing capabilities, additional fields such as `RecordedBy` (to track which user made the entry), `CreatedAt` (timestamp of creation), `LastModified` (timestamp of last modification), and an optional `Notes` field for additional details will be automatically managed by the application.

## Acceptance Criteria
-   Users can successfully add a new expense record with valid `Date`, `Name`, `Category`, and `Amount`.
-   Each new expense record is assigned a unique `RecordID` (UUID) by the application.
-   Users can select an existing category from the list for new and edited expenses.
-   Users can successfully edit an existing expense record, and the changes are accurately saved to the Google Sheet.
-   Users can successfully delete an existing expense record, and it is removed from the Google Sheet.
-   All CRUD operations are validated (e.g., `Amount` is non-negative, `Date` is valid, `Category` exists).
-   The `RecordedBy`, `CreatedAt`, and `LastModified` fields are automatically populated/updated for each record.
-   The application gracefully handles errors during CRUD operations (e.g., network issues, API errors), providing clear user feedback.

## Tasks / Subtasks
- [ ] Define Flutter data model for `ExpenseRecord` (AC: 1, 2, 7)
  - [ ] Include fields: `Date`, `Name`, `Category`, `Amount`, `RecordID`, `RecordedBy`, `CreatedAt`, `LastModified`, `Notes`
  - [ ] Implement `fromJson` and `toJson` methods for serialization
- [ ] Implement unique `RecordID` (UUID) generation (AC: 2)
  - [ ] Use a UUID generation library (e.g., `uuid` package)
- [ ] Implement UI for adding new expense records (form with validation) (AC: 1, 6)
  - [ ] Create a form with input fields for `Date`, `Name`, `Category`, `Amount`, `Notes`
  - [ ] Integrate category selection (dropdown/picker) from Category Management
  - [ ] Implement client-side validation for form fields
- [ ] Implement UI for editing existing expense records (form pre-populated with data) (AC: 4, 6)
  - [ ] Reuse the add form, pre-populate with existing record data
- [ ] Implement logic for saving new records to Google Sheets (AC: 1, 7)
  - [ ] Call Google Sheets API to append a new row to the `YYYY-MM` tab
- [ ] Implement logic for updating existing records in Google Sheets (AC: 4, 7)
  - [ ] Call Google Sheets API to update a specific row based on `RecordID`
- [ ] Implement logic for deleting records from Google Sheets (AC: 5, 7)
  - [ ] Call Google Sheets API to delete a specific row based on `RecordID`
- [ ] Implement data validation for all fields (AC: 6)
  - [ ] Validate `Amount` is non-negative and numeric
  - [ ] Validate `Date` format and ensure it's a valid date
  - [ ] Ensure selected `Category` exists in the master list
- [ ] Implement automatic population of `RecordedBy`, `CreatedAt`, `LastModified` (AC: 7)
  - [ ] Use `google_sign_in` for `RecordedBy` (user's email/ID)
  - [ ] Use `DateTime.now()` for timestamps
- [ ] Integrate with Category Management for category selection (AC: 3)
  - [ ] Ensure the expense form can retrieve and display available categories.
- [ ] Implement error handling for CRUD operations (AC: 8)
  - [ ] Display user-friendly error messages for network issues, API errors, or validation failures.

## Dev Notes
### General
This story is critical for the core functionality of the expense tracker, enabling users to manage their individual expense records. The use of a `RecordID` is paramount for reliable CRUD operations with Google Sheets. Robust data validation and automatic population of audit fields are essential for data integrity.

### Relevant Source Tree Info
- `lib/models/expense_record.dart`: New file for ExpenseRecord data model.
- `lib/services/google_sheets_service.dart`: Extend with methods for `addExpense`, `updateExpense`, `deleteExpense`.
- `lib/screens/expense_form_screen.dart` or `lib/widgets/expense_form_dialog.dart`: UI for adding/editing expenses.
- `lib/providers/expense_provider.dart`: State management for expense records.

### Testing
- **Test file location:** `test/models/expense_record_test.dart`, `test/services/google_sheets_service_test.dart`, `test/providers/expense_provider_test.dart`, `test/widgets/expense_form_test.dart`.
- **Test standards:** Unit tests for data model serialization, UUID generation, and validation logic. Integration tests for CRUD operations with mocked Google Sheets API responses. Widget tests for the add/edit expense forms.
- **Testing frameworks and patterns to use:** `flutter_test`, `mockito` for mocking API responses and dependencies.
- **Any specific testing requirements for this story:**
  - Verify successful creation, update, and deletion of records in mocked Google Sheets.
  - Test all validation rules for `Date`, `Name`, `Category`, `Amount`.
  - Confirm `RecordID`, `RecordedBy`, `CreatedAt`, `LastModified` are correctly generated/populated.
  - Test error handling for various API failure scenarios.
  - Verify category selection integration.

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
