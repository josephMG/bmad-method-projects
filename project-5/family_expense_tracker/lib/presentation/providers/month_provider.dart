import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:intl/intl.dart'; // For YYYY-MM formatting
import 'package:logging/logging.dart';

final _logger = Logger('CurrentMonthNotifier');

final currentMonthProvider = StateNotifierProvider<CurrentMonthNotifier, DateTime>((ref) {
  return CurrentMonthNotifier(ref.watch(googleSheetsServiceProvider));
});

class CurrentMonthNotifier extends StateNotifier<DateTime> {
  final GoogleSheetsService _googleSheetsService;

  CurrentMonthNotifier(this._googleSheetsService) : super(DateTime.now()) {
    _ensureMonthTabExists(state);
  }

  Future<void> goToNextMonth() async {
    state = DateTime(state.year, state.month + 1, 1);
    await _ensureMonthTabExists(state);
  }

  Future<void> goToPreviousMonth() async {
    state = DateTime(state.year, state.month - 1, 1);
    await _ensureMonthTabExists(state);
  }

  Future<void> goToMonth(DateTime month) async {
    state = DateTime(month.year, month.month, 1);
    await _ensureMonthTabExists(state);
  }

  Future<void> _ensureMonthTabExists(DateTime month) async {
    final sheetName = DateFormat('yyyy-MM').format(month);
    try {
      if (!await _googleSheetsService.sheetExists(sheetName)) {
        await _googleSheetsService.createSheet(sheetName);
      }
    } catch (e) {
      _logger.severe('Error ensuring month tab exists for $sheetName: $e');
      // Optionally, provide user feedback here
    }
  }
}