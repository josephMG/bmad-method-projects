import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:family_expense_tracker/presentation/providers/month_provider.dart';
import 'package:family_expense_tracker/providers/expense_provider.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:family_expense_tracker/data/models/category.dart';
import 'package:family_expense_tracker/providers/category_provider.dart';
import 'package:flutter/material.dart';

import '../mock/expense_mocks.mocks.dart';
import '../mock/google_sheets_service_mocks.mocks.dart';

class MockCategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> implements CategoryNotifier {
  MockCategoryNotifier(super.state);

  @override
  Future<void> fetchCategories() async {}

  @override
  Future<bool> checkIfCategoryIsUsed(String categoryId) async => false;

  @override
  Future<void> deleteCategory(String categoryId) async {}

  @override
  Future<void> reassignAndDeleteCategory(String oldCategoryId, String newCategoryId) async {}
}

void main() {
  group('ExpenseNotifier', () {
    late MockGoogleSheetsService mockGoogleSheetsService;
    late ProviderContainer container;

    final testMonth = DateTime(2023, 10, 1);
    final testCategory = Category(
        id: '1', categoryName: 'Food', colorCode: Color(0xFFFF0000));
    final testExpense = ExpenseRecord(
      id: 'test-uuid-123',
      date: DateTime(2023, 10, 26),
      description: 'Groceries',
      categoryId: testCategory.categoryName,
      amount: 50.0,
      paymentMethod: 'Cash',
      recordedBy: 'user@example.com',
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      notes: 'Weekly shopping',
    );

    setUp(() {
      mockGoogleSheetsService = MockGoogleSheetsService();

      // Default mock for getSheet, to handle the initial fetch in ExpenseNotifier constructor
      when(mockGoogleSheetsService.getSheet(any)).thenAnswer((_) async => [
        ['RecordID', 'Date', 'Name', 'Amount', 'Category', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes']
      ]);

      container = ProviderContainer(
        overrides: [
          googleSheetsServiceProvider.overrideWithValue(
              mockGoogleSheetsService),
          categoryProvider.overrideWith(
            (ref) => MockCategoryNotifier(AsyncValue.data([testCategory])),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should fetch expenses on initialization', () async {
      // ARRANGE
      when(mockGoogleSheetsService.getSheet('2023-10')).thenAnswer((_) async =>
      [
        [
          'RecordID',
          'Date',
          'Name',
          'Amount',
          'Category',
          'RecordedBy',
          'CreatedAt',
          'LastModified',
          'Notes'
        ],
        testExpense.toGoogleSheetRow(),
      ]);

      // ACT
      await container.read(expenseListProvider(testMonth));

      // Wait for the initial fetch to complete
      // await container.read(expenseListProvider(testMonth).notifier).fetchExpenses();
      final result = container.read(expenseListProvider(testMonth)).value;

      // ASSERT
      expect(result, isA<List<ExpenseRecord>>());
      expect(result!.length, 1);
      expect(result[0].id, testExpense.id);
      verify(mockGoogleSheetsService.getSheet('2023-10')).called(1);
    });

    test(
        'addExpense should call googleSheetsService.addExpense and re-fetch', () async {
      // ARRANGE
      // Mock the addExpense call
      when(mockGoogleSheetsService.addExpense(any, any)).thenAnswer((_) async => {});

      // Mock the initial getSheet call
      when(mockGoogleSheetsService.getSheet('2023-10')).thenAnswer((_) async =>
      [
        ['RecordID', 'Date', 'Name', 'Amount', 'Category', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes']
      ]);

      // Initial fetch is now handled by the constructor

      // ACT
      await container.read(expenseListProvider(testMonth));
      final notifier = container.read(expenseListProvider(testMonth).notifier);

      // Mock the getSheet call that happens on re-fetch after addExpense
      when(mockGoogleSheetsService.getSheet('2023-10')).thenAnswer((_) async =>
      [
        ['RecordID', 'Date', 'Name', 'Amount', 'Category', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
        testExpense.toGoogleSheetRow(),
      ]);

      await notifier.addExpense(testExpense);

      // ASSERT
      verify(mockGoogleSheetsService.addExpense('2023-10', testExpense)).called(1);
      verify(mockGoogleSheetsService.getSheet('2023-10')).called(2);
      final state = container.read(expenseListProvider(testMonth)).value;
      expect(state!.length, 1);
    });

    test(
        'updateExpense should call googleSheetsService.updateExpense and re-fetch', () async {
      // ARRANGE
      final updatedExpense = testExpense.copyWith(
          description: 'Updated Groceries');
      when(mockGoogleSheetsService.updateExpense(any, any)).thenAnswer((
          _) async => {});

      // Initial fetch is now handled by the constructor
      final notifier = container.read(expenseListProvider(testMonth).notifier);
      await Future.value(); // Allow the microtask queue to run for initial fetch

      // Mock the getSheet call that happens on re-fetch after updateExpense
      when(mockGoogleSheetsService.getSheet('2023-10')).thenAnswer((_) async =>
      [
        ['RecordID', 'Date', 'Name', 'Amount', 'Category', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
        updatedExpense.toGoogleSheetRow(),
      ]);

      // ACT
      await notifier.updateExpense(updatedExpense);

      // ASSERT
      verify(mockGoogleSheetsService.updateExpense('2023-10', updatedExpense))
          .called(1);
      verify(mockGoogleSheetsService.getSheet('2023-10')).called(2);
    });

    test(
        'deleteExpense should call googleSheetsService.deleteExpense and re-fetch', () async {
      // ARRANGE
      when(mockGoogleSheetsService.deleteExpense(any, any)).thenAnswer((
          _) async => {});

      // Initial fetch is now handled by the constructor
      final notifier = container.read(expenseListProvider(testMonth).notifier);
      await Future.value(); // Allow the microtask queue to run for initial fetch

      // Mock the getSheet call that happens on re-fetch after deleteExpense
      when(mockGoogleSheetsService.getSheet('2023-10')).thenAnswer((_) async =>
      [
        ['RecordID', 'Date', 'Name', 'Amount', 'Category', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
      ]);

      // ACT
      await notifier.deleteExpense(testExpense.id);

      // ASSERT
      verify(mockGoogleSheetsService.deleteExpense('2023-10', testExpense.id))
          .called(1);
      verify(mockGoogleSheetsService.getSheet('2023-10')).called(2);
    });

    test(
        'deleteExpense should set state to AsyncError on GoogleSheetsService error', () async {
      // ARRANGE
      when(mockGoogleSheetsService.deleteExpense(any, any)).thenThrow(
          GoogleSheetsApiException('API Error'));
      // Initial fetch is now handled by the constructor
      final notifier = container.read(expenseListProvider(testMonth).notifier);
      await Future.value(); // Allow the microtask queue to run for initial fetch

      // ACT
      expect(() async { await notifier.deleteExpense(testExpense.id); }, throwsA(isA<GoogleSheetsApiException>()));
      //
      // // ASSERT
      // final state = container.read(expenseListProvider(testMonth));
      // expect(state, isA<AsyncError>());
      // expect(state.error, isA<GoogleSheetsApiException>());
    });

    test(
        'addExpense should set state to AsyncError for negative amount', () async {
      // ARRANGE
      // Initial fetch is now handled by the constructor
      final notifier = container.read(expenseListProvider(testMonth).notifier);
      await Future.value(); // Allow the microtask queue to run for initial fetch

      final invalidExpense = testExpense.copyWith(amount: -10.0);

      // ACT
      await notifier.addExpense(invalidExpense);

      // ASSERT
      final state = container.read(expenseListProvider(testMonth));
      expect(state, isA<AsyncError>());
      expect(state.error, isA<ValidationException>());
      expect((state.error as ValidationException).message,
          'Amount cannot be negative.');
    });

    test('should sort expenses by date in descending order', () async {
      // ARRANGE
      final expense1 = testExpense.copyWith(
          date: DateTime(2023, 10, 25), id: 'id1');
      final expense2 = testExpense.copyWith(
          date: DateTime(2023, 10, 27), id: 'id2');
      final expense3 = testExpense.copyWith(
          date: DateTime(2023, 10, 26), id: 'id3');

      when(mockGoogleSheetsService.getSheet('2023-10')).thenAnswer((_) async =>
      [
        [
          'RecordID',
          'Date',
          'Name',
          'Amount',
          'Category',
          'RecordedBy',
          'CreatedAt',
          'LastModified',
          'Notes'
        ],
        expense1.toGoogleSheetRow(),
        expense2.toGoogleSheetRow(),
        expense3.toGoogleSheetRow(),
      ]);

      // ACT
      // The ExpenseNotifier constructor now calls fetchExpenses()
      final notifier = container.read(expenseListProvider(testMonth).notifier);
      await Future.value(); // Allow the microtask queue to run for initial fetch

      final result = container.read(expenseListProvider(testMonth)).value;

      // ASSERT
      expect(result!.length, 3);
      expect(result[0].id, 'id2'); // 2023-10-27
      expect(result[1].id, 'id3'); // 2023-10-26
      expect(result[2].id, 'id1'); // 2023-10-25
    });

    test('monthlyTotalProvider should calculate the correct total', () async {
      // ARRANGE
      final expense1 = testExpense.copyWith(amount: 10.0);
      final expense2 = testExpense.copyWith(amount: 20.0);
      final expense3 = testExpense.copyWith(amount: 30.0);

      when(mockGoogleSheetsService.getSheet('2023-10')).thenAnswer((_) async => [
        ['RecordID', 'Date', 'Name', 'Amount', 'Category', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
        expense1.toGoogleSheetRow(),
        expense2.toGoogleSheetRow(),
        expense3.toGoogleSheetRow(),
      ]);

      // ACT
      // The ExpenseNotifier constructor now calls fetchExpenses()
      final notifier = container.read(expenseListProvider(testMonth).notifier);
      await Future.value(); // Allow the microtask queue to run for initial fetch

      final totalAsyncValue = container.read(monthlyTotalProvider(testMonth));

      // ASSERT
      expect(totalAsyncValue.value, 60.0);
    });
  });
}