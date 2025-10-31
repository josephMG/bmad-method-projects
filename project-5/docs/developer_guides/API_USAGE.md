# API Usage Documentation

This document outlines how to interact with the Google Sheets API within the Family Expense Tracker application, focusing on authentication, the `GoogleSheetsService`, and CRUD operations for expense records and categories.

## 1. Authentication

The application uses Google OAuth for user authentication, managed by the `AuthRepository`. The `AuthRepository` handles the sign-in/sign-out flow and securely manages OAuth tokens.

### 1.1 `AuthRepository` Overview

The `AuthRepository` class provides methods for:
- `signInWithGoogle()`: Initiates the Google sign-in process.
- `signOut()`: Signs out the current user and clears stored tokens.
- `getAccessToken()`: Retrieves a valid access token, refreshing it if necessary.
- `isSignedIn()`: Checks if a user is currently signed in.
- `getCurrentUser()`: Returns the currently signed-in `User` object.

**Example Usage (from a Riverpod provider):**

```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// To get the current user:
final user = ref.watch(authRepositoryProvider).getCurrentUser();
```

The `GoogleSheetsService` internally uses the `AuthRepository` to obtain the necessary credentials for API calls.

## 2. `GoogleSheetsService` Overview

The `GoogleSheetsService` (`family_expense_tracker/lib/services/google_sheets_service.dart`) is responsible for low-level interactions with the Google Sheets API. It abstracts away the complexities of API calls, error handling, and rate limit retries.

It is provided via Riverpod:
```dart
final googleSheetsServiceProvider = Provider<GoogleSheetsService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GoogleSheetsService.create(authRepository);
});
```

## 3. CRUD Operations

The `GoogleSheetsService` provides methods for performing CRUD (Create, Read, Update, Delete) operations on expense records and categories within the Google Sheet.

### 3.1 Reading Data

- **`getSheet(String sheetName)`:** Fetches all rows from a given sheet (e.g., a monthly sheet like "2023-10" or "Categories"). Returns a `Future<List<List<dynamic>>?>`.

  ```dart
  // Example: Fetch all data from the "2023-10" sheet
  final sheetsService = ref.read(googleSheetsServiceProvider);
  final monthlyExpensesData = await sheetsService.getSheet('2023-10');
  // monthlyExpensesData will be List<List<dynamic>> where inner list is a row
  ```

- **`getAllSheetNames()`:** Retrieves a list of all sheet names (tabs) in the spreadsheet.

  ```dart
  final sheetsService = ref.read(googleSheetsServiceProvider);
  final sheetNames = await sheetsService.getAllSheetNames();
  // sheetNames will be List<String>
  ```

- **`findExpenseRowIndex(String sheetName, String recordID)`:** Finds the 0-based row index of an expense record by its `RecordID` within a specific sheet.

### 3.2 Creating Data

- **`addExpense(String sheetName, ExpenseRecord expense)`:** Appends a new expense record to the specified monthly sheet. The `ExpenseRecord` object is converted to a Google Sheet row format internally.

  ```dart
  final sheetsService = ref.read(googleSheetsServiceProvider);
  final newExpense = ExpenseRecord(...); // Create an ExpenseRecord instance
  await sheetsService.addExpense('2023-10', newExpense);
  ```

- **`createSheet(String sheetName)`:** Creates a new sheet (tab) in the spreadsheet.

### 3.3 Updating Data

- **`updateExpense(String sheetName, ExpenseRecord expense)`:** Updates an existing expense record in the specified monthly sheet. It uses the `expense.id` to locate the record.

  ```dart
  final sheetsService = ref.read(googleSheetsServiceProvider);
  final updatedExpense = existingExpense.copyWith(amount: 150.0); // Modify an existing expense
  await sheetsService.updateExpense('2023-10', updatedExpense);
  ```

- **`updateExpensesCategory(String oldCategoryId, String newCategoryId, List<String> allSheetNames)`:** Updates the category ID for all expense records across all monthly sheets from `oldCategoryId` to `newCategoryId`. This is used when a category is edited.

### 3.4 Deleting Data

- **`deleteExpense(String sheetName, String recordID)`:** Deletes an expense record from the specified monthly sheet using its `recordID`.

  ```dart
  final sheetsService = ref.read(googleSheetsServiceProvider);
  await sheetsService.deleteExpense('2023-10', 'some-record-id');
  ```

- **`deleteRow(int sheetId, int rowIndex)`:** Deletes a row by its 0-based index and sheet ID.

## 4. API Rate Limits and Error Handling

The `GoogleSheetsService` includes built-in mechanisms to handle API rate limits and other transient errors:

- **Retry Logic:** The `_handleApiCall` method implements an exponential backoff retry mechanism for `429 (Too Many Requests)` errors and `5xx` server errors.
- **Exception Handling:** API errors are caught and re-thrown as `GoogleSheetsApiException` or `NetworkException`, providing a structured way to handle errors at a higher level.

Developers should still design features to minimize API calls where possible (e.g., client-side caching) and provide user feedback when rate limits are encountered.
