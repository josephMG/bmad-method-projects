# State Management Documentation

This document details the state management strategy employed in the Family Expense Tracker application, which leverages Riverpod. It covers core Riverpod principles, key providers, and best practices for managing application state, especially data fetched from Google Sheets.

## 1. Introduction to Riverpod

Riverpod is a reactive caching and data-binding framework for Flutter, designed to be type-safe and testable. It focuses on making state management robust by addressing common issues like provider declaration outside the widget tree and difficult testing.

### 1.1 Core Principles

- **Provider Scoping:** Providers can be scoped to specific parts of the widget tree, optimizing performance and resource usage.
- **Unidirectional Data Flow:** Data flows in one direction, making the application state predictable and easier to debug.
- **Immutability:** Riverpod encourages immutability for state objects, ensuring that state changes are always explicit.
- **Compile-time Safety:** Strong type safety helps catch errors early in the development cycle.

### 1.2 Key Riverpod Concepts Used

- **`Provider`:** For read-only values that never change.
- **`StateProvider`:** For simple, mutable state that can be directly modified.
- **`StateNotifierProvider`:** For more complex state logic encapsulated within a `StateNotifier` class. This is commonly used for managing collections of data or business logic.
- **`FutureProvider`:** For asynchronously fetching and exposing data, handling loading and error states automatically.
- **`StreamProvider`:** For listening to streams of data, often used for real-time updates or continuous events.

## 2. Key Application Providers

The following are some of the central providers used in the application for managing various aspects of the state:

### 2.1 Authentication & User State

- **`authRepositoryProvider` (`Provider<AuthRepository>`):** Provides an instance of `AuthRepository`, enabling authentication operations.
    ```dart
    final authRepositoryProvider = Provider<AuthRepository>((ref) {
      return AuthRepository();
    });
    ```

- **`userProvider` (`StreamProvider<User?>`):** Exposes the authentication state of the user as a stream, emitting `User` objects on sign-in and `null` on sign-out.
    ```dart
    final userProvider = StreamProvider<User?>((ref) async* {
      final authRepository = ref.watch(authRepositoryProvider);
      // ... logic to provide user stream
    });
    ```

### 2.2 Google Sheets Service

- **`googleSheetsServiceProvider` (`Provider<GoogleSheetsService>`):** Provides an instance of `GoogleSheetsService` for interacting with the Google Sheets API.
    ```dart
    final googleSheetsServiceProvider = Provider<GoogleSheetsService>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return GoogleSheetsService.create(authRepository);
    });
    ```

### 2.3 Connectivity & Sync Status

- **`connectivityStatusProvider` (`StreamProvider<ConnectivityStatus>`):** Provides a stream of the device's connectivity status.

- **`syncStatusProvider` (`StateNotifierProvider<SyncStatusNotifier, SyncStatus>`):** Manages and exposes the application's synchronization status (e.g., idle, syncing, offline).

### 2.4 Expense Records

- **`currentMonthProvider` (`StateNotifierProvider<CurrentMonthNotifier, DateTime>`):** Manages the currently selected month for which expenses are displayed.
    ```dart
    final currentMonthProvider = StateNotifierProvider<CurrentMonthNotifier, DateTime>((ref) {
      // ... logic to manage current month
      return CurrentMonthNotifier(ref.watch(googleSheetsServiceProvider));
    });
    ```

- **`expenseListProvider` (`StateNotifierProvider.family<ExpenseNotifier, AsyncValue<List<ExpenseRecord>>, DateTime>`):** A family provider that provides expense records for a given month. The `ExpenseNotifier` handles fetching, adding, updating, and deleting expenses.
    ```dart
    final expenseListProvider = StateNotifierProvider.family<
        ExpenseNotifier, AsyncValue<List<ExpenseRecord>>, DateTime>((ref, month) {
      final googleSheetsService = ref.watch(googleSheetsServiceProvider);
      // ... returns ExpenseNotifier
    });
    ```

- **`monthlyTotalProvider` (`Provider.family<AsyncValue<double>, DateTime>`):** Provides the calculated total expenses for a specific month.

### 2.5 Categories

- **`categoryProvider` (`StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>`):** Manages the list of categories. The `CategoryNotifier` handles operations like fetching, adding, updating, and deleting categories.
    ```dart
    final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
      final categoryRepository = ref.watch(googleSheetsCategoryRepositoryProvider);
      // ... returns CategoryNotifier
    });
    ```

- **`categoriesProvider` (`FutureProvider<List<Category>>`):** A simpler `FutureProvider` that directly exposes the list of categories for read-only purposes.

## 3. Data Flow and Widget Interaction

The typical data flow involves widgets consuming data from providers and interacting with notifiers to trigger state changes. Riverpod ensures that widgets automatically rebuild when the data they are listening to changes.

### 3.1 Example: Reading Expenses in a Widget

Consider a widget that displays a list of expenses for the currently selected month:

```dart
class ExpenseListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(currentMonthProvider);
    final expensesAsyncValue = ref.watch(expenseListProvider(selectedMonth));

    return expensesAsyncValue.when(
      data: (expenses) => ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ListTile(
            title: Text(expense.description),
            subtitle: Text('Amount: ${expense.amount}'),
          );
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: ${error}'),
    );
  }
}
```

In this example:
1.  `ref.watch(currentMonthProvider)` listens to changes in the selected month.
2.  `ref.watch(expenseListProvider(selectedMonth))` watches the `expenseListProvider` for the `selectedMonth`. This provider returns an `AsyncValue`, which conveniently handles loading, data, and error states.
3.  The `when` method of `AsyncValue` is used to gracefully handle the different states, displaying a loading indicator, the expense list, or an error message as appropriate.

### 3.2 Triggering State Changes

To modify state, a widget typically *reads* the notifier of a `StateNotifierProvider` and calls its methods:

```dart
// Example: Adding a new expense
ref.read(expenseListProvider(selectedMonth).notifier).addExpense(newExpense);

// Example: Deleting a category
ref.read(categoryProvider.notifier).deleteCategory(categoryId);
```
