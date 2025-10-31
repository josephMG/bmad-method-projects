import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:family_expense_tracker/core/utils/error_handler.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/data/repositories/expense_repository.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:uuid/uuid.dart';

/// An implementation of the [ExpenseRepository] that uses Google Sheets as the data source.
class GoogleSheetsExpenseRepository implements ExpenseRepository {
  final GoogleSheetsService _sheetsService;
  final Uuid _uuid;

  GoogleSheetsExpenseRepository(this._sheetsService) : _uuid = const Uuid();

  String _sheetNameFor(int year, int month) => '$year-${month.toString().padLeft(2, '0')}';

  @override
  Future<List<ExpenseRecord>> getExpensesForMonth(int year, int month) async {
    final sheetName = _sheetNameFor(year, month);
    try {
      final values = await _sheetsService.getSheet(sheetName);

      if (values == null || values.isEmpty) {
        // Before returning empty, check if the sheet exists. If not, create it.
        // This logic is simplified here; a more robust implementation would check sheet metadata.
        try {
          await _sheetsService.createSheet(sheetName);
        } catch (e) {
          // Ignore if sheet already exists, handle other errors as needed.
          // Re-throw through handler to ensure consistency
          ErrorHandler.handleApiError(e);
        }
        return [];
      }

      final expenses = <ExpenseRecord>[];
      // Skip header row
      for (int i = 1; i < values.length; i++) {
        final row = values[i];
        if (row.isNotEmpty && row[0].toString().isNotEmpty) { // Check for valid RecordID
          expenses.add(ExpenseRecord.fromGoogleSheetRow(row));
        }
      }
      return expenses;
    } catch (e) {
      ErrorHandler.handleApiError(e);
      rethrow; // Re-throw the handled exception
    }
  }

  @override
  Future<void> addExpense(String monthSheetName, ExpenseRecord expense) async {
    if (!expense.isValid()) {
      throw AppException('Invalid expense record provided for addition.');
    }
    try {
      await _sheetsService.appendSheet(monthSheetName, [expense.toGoogleSheetRow()]);
    } catch (e) {
      ErrorHandler.handleApiError(e);
      rethrow;
    }
  }

  @override
  Future<void> updateExpense(String monthSheetName, ExpenseRecord expense) async {
    if (!expense.isValid()) {
      throw AppException('Invalid expense record provided for update.');
    }
    try {
      final values = await _sheetsService.getSheet(monthSheetName);
      if (values == null) throw AppException('Sheet not found for the given month.');

      int rowIndex = -1;
      for (int i = 1; i < values.length; i++) { // Start from 1 to skip header
                  if (values[i].isNotEmpty && values[i][0] == expense.id) {          rowIndex = i + 1; // Sheet rows are 1-indexed
          break;
        }
      }

      if (rowIndex == -1) {
        throw AppException('Expense record not found for update.');
      }

      final range = '$monthSheetName!A$rowIndex';
      await _sheetsService.updateSheet(range, [expense.toGoogleSheetRow()]);
    } catch (e) {
      ErrorHandler.handleApiError(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String monthSheetName, String recordID, String currentUserEmail) async {
    try {
      final values = await _sheetsService.getSheet(monthSheetName);
      if (values == null) {
        throw AppException('Sheet not found for the given month to delete from.');
      }

      int rowIndex = -1;
      ExpenseRecord? expenseToDelete;
      for (int i = 1; i < values.length; i++) { // Start from 1 to skip header
                  if (values[i].isNotEmpty && values[i][0].toString() == recordID) {          rowIndex = i + 1; // Sheet rows are 1-indexed for deletion
                      expenseToDelete = ExpenseRecord.fromGoogleSheetRow(values[i]);          break;
        }
      }

      if (rowIndex == -1) {
        throw AppException('Expense record not found for deletion.');
      }

      // Authorization check
      if (expenseToDelete == null || expenseToDelete.recordedBy != currentUserEmail) {
        throw UnauthorizedException('You are not authorized to delete this expense record.');
      }

      // We need the sheetId to delete a row, which is not the same as the sheet name.
      // This requires another API call. This highlights the inefficiency of Google Sheets as a DB.
      final sheetId = await _sheetsService.getSheetId(monthSheetName);
      if (sheetId == null) {
        throw AppException('Could not find sheetId for $monthSheetName');
      }

      await _sheetsService.deleteRow(sheetId, rowIndex);
    } catch (e) {
      ErrorHandler.handleApiError(e);
      rethrow;
    }
  }
}

