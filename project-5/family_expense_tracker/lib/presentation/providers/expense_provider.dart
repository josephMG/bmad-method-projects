import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/features/expenses/data/expense_repository.dart';
import 'package:family_expense_tracker/presentation/providers/month_provider.dart';
import 'package:intl/intl.dart';

final expensesProvider = FutureProvider<List<ExpenseRecord>>((ref) async {
  final currentMonth = ref.watch(currentMonthProvider);
  final expenseRepository = ref.watch(expenseRepositoryProvider);

  final monthSheetName = DateFormat('yyyy-MM').format(currentMonth);
  return expenseRepository.getExpensesForMonth(monthSheetName);
});
