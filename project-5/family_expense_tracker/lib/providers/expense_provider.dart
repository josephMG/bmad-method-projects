import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:family_expense_tracker/presentation/providers/sync_status_provider.dart';

final _logger = Logger('ExpenseProvider');

final expenseListProvider = StateNotifierProvider.family<ExpenseNotifier, AsyncValue<List<ExpenseRecord>>, DateTime>((ref, month) {
  final googleSheetsService = ref.watch(googleSheetsServiceProvider);
  final notifier = ExpenseNotifier(googleSheetsService, month, ref);
  notifier.fetchExpenses();
  return notifier;
});

class ExpenseNotifier extends StateNotifier<AsyncValue<List<ExpenseRecord>>> {
  final GoogleSheetsService _googleSheetsService;
  final DateTime _month;
  final Ref ref;

  ExpenseNotifier(this._googleSheetsService, this._month, this.ref) : super(const AsyncValue.loading()) {
  }

  Future<void> fetchExpenses() async {
    state = const AsyncValue.loading();
    try {
      final String sheetName = DateFormat('yyyy-MM').format(_month);
      final sheetData = await _googleSheetsService.getSheet(sheetName);

      if (sheetData == null || sheetData.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      // Assuming the first row is headers, skip it.
      final List<ExpenseRecord> expenses = [];
      for (int i = 0; i < sheetData.length; i++) {
        try {
          final ExpenseRecord expense = ExpenseRecord.fromGoogleSheetRow(sheetData[i]);
          expenses.add(expense);
        } catch (e) {
          _logger.warning('Skipping malformed expense record: ${sheetData[i]} - $e');
        }
      }
      expenses.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
      state = AsyncValue.data(expenses);
    } on GoogleSheetsApiException catch (e) {
      _logger.severe('Google Sheets API exception while fetching expenses: ${e.message}', e);
      state = AsyncValue.error(e, StackTrace.current);
    } on NetworkException catch (e) {
      _logger.severe('Network exception while fetching expenses: ${e.message}', e);
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      _logger.severe('An unexpected error occurred while fetching expenses: $e', e, st);
      state = AsyncValue.error(e, st);
    }
  }

  // Add methods for CRUD operations
  Future<void> addExpense(ExpenseRecord expense) async {
    try {
      if (expense.amount < 0) {
        throw ValidationException('Amount cannot be negative.');
      }
      final String sheetName = DateFormat('yyyy-MM').format(_month);
      await _googleSheetsService.addExpense(sheetName, expense);
      await fetchExpenses(); // Re-fetch to update the list and ensure sorting
    } on ValidationException catch (e) {
      _logger.warning('Validation error adding expense: ${e.message}');
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      _logger.severe('Error adding expense: $e', e, st);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateExpense(ExpenseRecord updatedExpense) async {
    try {
      final String sheetName = DateFormat('yyyy-MM').format(_month);
      await _googleSheetsService.updateExpense(sheetName, updatedExpense);
      await fetchExpenses(); // Re-fetch to update the list and ensure sorting
    } catch (e, st) {
      _logger.severe('Error updating expense: $e', e, st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      final String sheetName = DateFormat('yyyy-MM').format(_month);
      await _googleSheetsService.deleteExpense(sheetName, expenseId);
      await fetchExpenses(); // Re-fetch to update the list and ensure sorting
    } catch (e, st) {
      _logger.severe('Error deleting expense: $e', e, st);
      // state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final monthlyTotalProvider = Provider.family<AsyncValue<double>, DateTime>((ref, month) {
  final expensesAsyncValue = ref.watch(expenseListProvider(month));

  return expensesAsyncValue.when(
    data: (expenses) => AsyncValue.data(expenses.fold(0.0, (sum, expense) => sum + expense.amount)),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});


