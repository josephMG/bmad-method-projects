import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:family_expense_tracker/presentation/providers/month_provider.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:intl/intl.dart';

import '../../mock/google_sheets_service_mocks.mocks.dart' as generated_mocks;

void main() {
  group('CurrentMonthNotifier', () {
    late generated_mocks.MockGoogleSheetsService mockGoogleSheetsService;
    late ProviderContainer container;

    setUp(() {
      mockGoogleSheetsService = generated_mocks.MockGoogleSheetsService();
      // Mock sheetExists to return true by default to avoid creating sheets in most tests
      when(mockGoogleSheetsService.sheetExists(any)).thenAnswer((_) async => true);
      when(mockGoogleSheetsService.createSheet(any)).thenAnswer((_) async => Future.value());

      container = ProviderContainer(
        overrides: [
          googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes with current month and ensures tab exists', () async {
      final now = DateTime.now();
      final expectedSheetName = DateFormat('yyyy-MM').format(now);

      // Access the notifier to trigger initialization
      container.read(currentMonthProvider);
      await Future.microtask(() {}); // Allow async operations to complete

      // Verify that sheetExists was called for the current month
      verify(mockGoogleSheetsService.sheetExists(expectedSheetName)).called(1);
      // Verify that createSheet was NOT called since sheetExists is mocked to return true
      verifyNever(mockGoogleSheetsService.createSheet(any));
    });

    test('creates a new tab if it does not exist on initialization', () async {
      final now = DateTime.now();
      final expectedSheetName = DateFormat('yyyy-MM').format(now);

      // Mock sheetExists to return false for the initial month
      when(mockGoogleSheetsService.sheetExists(expectedSheetName)).thenAnswer((_) async => false);

      // Re-initialize container to apply new mock behavior
      container.dispose();
      container = ProviderContainer(
        overrides: [
          googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
        ],
      );

      container.read(currentMonthProvider);
      await Future.microtask(() {}); // Allow async operations to complete

      // Verify that sheetExists was called and then createSheet was called
      verify(mockGoogleSheetsService.sheetExists(expectedSheetName)).called(1);
      verify(mockGoogleSheetsService.createSheet(expectedSheetName)).called(1);
    });

    test('goToNextMonth updates month and ensures tab exists', () async {
      final notifier = container.read(currentMonthProvider.notifier);
      final initialMonth = notifier.state;

      await notifier.goToNextMonth(); // Await the async operation

      final nextMonth = DateTime(initialMonth.year, initialMonth.month + 1, 1);
      final expectedSheetName = DateFormat('yyyy-MM').format(nextMonth);

      expect(notifier.state.year, nextMonth.year);
      expect(notifier.state.month, nextMonth.month);
      verify(mockGoogleSheetsService.sheetExists(expectedSheetName)).called(1);
    });

    test('goToPreviousMonth updates month and ensures tab exists', () async {
      final notifier = container.read(currentMonthProvider.notifier);
      final initialMonth = notifier.state;

      await notifier.goToPreviousMonth(); // Await the async operation

      final previousMonth = DateTime(initialMonth.year, initialMonth.month - 1, 1);
      final expectedSheetName = DateFormat('yyyy-MM').format(previousMonth);

      expect(notifier.state.year, previousMonth.year);
      expect(notifier.state.month, previousMonth.month);
      verify(mockGoogleSheetsService.sheetExists(expectedSheetName)).called(1);
    });

    test('handles error during sheet creation gracefully', () async {
      final now = DateTime.now();
      final expectedSheetName = DateFormat('yyyy-MM').format(now);

      when(mockGoogleSheetsService.sheetExists(expectedSheetName)).thenAnswer((_) async => false);
      when(mockGoogleSheetsService.createSheet(expectedSheetName)).thenThrow(Exception('API Error'));

      container.dispose();
      container = ProviderContainer(
        overrides: [
          googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
        ],
      );

      container.read(currentMonthProvider);
      await Future.microtask(() {}); // Allow async operations to complete

      verify(mockGoogleSheetsService.sheetExists(expectedSheetName)).called(1);
      verify(mockGoogleSheetsService.createSheet(expectedSheetName)).called(1);
      // In a real app, this would likely involve logging or showing a user-facing error.
      // For this test, we just ensure it doesn't crash.
    });

    test('goToMonth updates month and ensures tab exists', () async {
      final notifier = container.read(currentMonthProvider.notifier);
      final targetMonth = DateTime(2024, 5, 15); // A specific month to go to

      await notifier.goToMonth(targetMonth); // Await the async operation

      final expectedMonth = DateTime(targetMonth.year, targetMonth.month, 1);
      final expectedSheetName = DateFormat('yyyy-MM').format(expectedMonth);

      expect(notifier.state.year, expectedMonth.year);
      expect(notifier.state.month, expectedMonth.month);
      verify(mockGoogleSheetsService.sheetExists(expectedSheetName)).called(1);
    });
  });
}
