import 'package:family_expense_tracker/data/models/expense_record.dart';

/// Abstract repository for managing expense records.
abstract class ExpenseRepository {
  /// Fetches all expense records for a given month.
  Future<List<ExpenseRecord>> getExpensesForMonth(int year, int month);

  /// Adds a new expense record.
  Future<void> addExpense(String monthSheetName, ExpenseRecord expense);

  /// Updates an existing expense record.
  Future<void> updateExpense(String monthSheetName, ExpenseRecord expense);

  /// Deletes an expense record by its ID within a specific month,
  /// ensuring the action is performed by an authorized user.
  Future<void> deleteExpense(String monthSheetName, String recordID, String currentUserEmail);
}
