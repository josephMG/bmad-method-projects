import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(googleSheetsServiceProvider));
});

class ExpenseRepository {
  final GoogleSheetsService _googleSheetsService;

  ExpenseRepository(this._googleSheetsService);

  Future<List<ExpenseRecord>> getExpensesForMonth(String monthSheetName) async {
    final sheetData = await _googleSheetsService.getSheet(monthSheetName);

    if (sheetData == null || sheetData.isEmpty) {
      return [];
    }

    // Assuming the first row is the header
    final List<List<dynamic>> dataRows = sheetData.sublist(1);

    return dataRows.map((row) {
      // Generate a unique ID for each expense, or use an existing one if available
      // For now, we'll use a simple index + timestamp as a placeholder ID
      final String id = '${monthSheetName}_${dataRows.indexOf(row)}_${DateTime.now().millisecondsSinceEpoch}';
      return ExpenseRecord.fromGoogleSheet(id, row);
    }).toList();
  }
}