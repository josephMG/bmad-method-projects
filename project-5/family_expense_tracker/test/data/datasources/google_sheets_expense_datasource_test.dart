import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:family_expense_tracker/data/datasources/google_sheets_expense_datasource.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart'; // Import UnauthorizedException

import '../../mock/google_sheets_service_mocks.mocks.dart';

void main() {
  late MockGoogleSheetsService mockSheetsService;
  late GoogleSheetsExpenseRepository repository;

  final expenseToDelete = ExpenseRecord(
    id: 'uuid1',
    date: DateTime(2025, 10, 11),
    description: 'Coffee',
    categoryId: 'Food',
    amount: 5.0,
    paymentMethod: 'Cash',
    recordedBy: 'user@test.com',
    createdAt: DateTime(2025, 10, 11, 10, 0, 0),
    lastModified: DateTime(2025, 10, 11, 10, 0, 0),
  );
  final List<List<Object>> sheetData = [
    ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
    ['uuid1', '2025-10-11', 'Coffee', 5.0, 'Food', 'Cash', 'user@test.com', '2025-10-11T10:00:00.000Z', '2025-10-11T10:00:00.000Z', ''],
  ];
  const sheetId = 12345;

  setUp(() {
    mockSheetsService = MockGoogleSheetsService();
    repository = GoogleSheetsExpenseRepository(mockSheetsService);
  });

  group('getExpensesForMonth', () {
    test('should return a list of expenses when the call to google sheets is successful', () async {
      // arrange
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => sheetData);
      // act
      final result = await repository.getExpensesForMonth(2025, 10);
      // assert
      expect(result, isA<List<ExpenseRecord>>());
      expect(result.length, 1);
      expect(result[0].description, 'Coffee');
    });
  });

  group('addExpense', () {
    test('should call appendSheet on the service with the correct data', () async {
      // arrange
      final expense = ExpenseRecord.createNew(
        date: DateTime(2025, 10, 11),
        description: 'Lunch',
        categoryId: 'Food',
        amount: 15.0,
        paymentMethod: 'Cash',
        recordedBy: 'user@test.com',
      );
      when(mockSheetsService.appendSheet(any, any)).thenAnswer((_) async => Future.value());
      // act
      await repository.addExpense('2025-10', expense);
      // assert
      final captured = verify(mockSheetsService.appendSheet(any, captureAny)).captured;
      final capturedList = captured.first as List<List<Object?>>;
      final capturedRow = capturedList.first;

      expect(capturedRow[0], isA<String>()); // RecordID is a generated UUID
      expect(capturedRow[2], 'Lunch');
      expect(capturedRow[5], 'Cash');
    });
  });

  group('updateExpense', () {
    test('should call updateSheet on the service with the correct data and updated lastModified', () async {
      // arrange
      final existingExpense = ExpenseRecord(
        id: 'uuid1',
        date: DateTime(2025, 10, 11),
        description: 'Old Coffee',
        categoryId: 'Food',
        amount: 5.0,
        paymentMethod: 'Cash',
        recordedBy: 'user@test.com',
        createdAt: DateTime(2025, 10, 11, 10, 0, 0),
        lastModified: DateTime(2025, 10, 11, 10, 0, 0),
      );
      final updatedExpense = existingExpense.copyWith(
        description: 'New Coffee',
        amount: 6.0,
      );

      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => [
        ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
        existingExpense.toGoogleSheetRow(),
      ]);
      when(mockSheetsService.updateSheet(any, any)).thenAnswer((_) async => Future.value());

      // act
      await repository.updateExpense('2025-10', updatedExpense);

      // assert
      final captured = verify(mockSheetsService.updateSheet(any, captureAny)).captured;
      final capturedList = captured.first as List<List<Object?>>;
      final capturedRow = capturedList.first;

      expect(capturedRow[0], updatedExpense.id);
      expect(capturedRow[2], 'New Coffee');
      expect(capturedRow[3], 6.0);
      // Verify that lastModified is updated (it should be different from existingExpense.lastModified)
      final updatedLastModified = DateTime.parse(capturedRow[8].toString());
      expect(updatedLastModified.isAfter(existingExpense.lastModified), isTrue);
    });
  });

  group('deleteExpense', () {
    const authorizedUserEmail = 'user@test.com';
    const unauthorizedUserEmail = 'other@test.com';

    test('should call deleteRow on the service when deletion is successful and authorized', () async {
      // arrange
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => sheetData);
      when(mockSheetsService.getSheetId('2025-10')).thenAnswer((_) async => sheetId);
      when(mockSheetsService.deleteRow(any, any)).thenAnswer((_) async => Future.value());
      // act
      await repository.deleteExpense('2025-10', expenseToDelete.id, authorizedUserEmail);
      // assert
      verify(mockSheetsService.deleteRow(sheetId, 2)).called(1); // rowIndex is 2 (1-indexed + header)
    });

    test('should throw UnauthorizedException when user is not authorized to delete', () async {
      // arrange
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => sheetData);
      // act & assert
      expect(
            () async => await repository.deleteExpense('2025-10', expenseToDelete.id, unauthorizedUserEmail),
        throwsA(isA<UnauthorizedException>().having(
              (e) => e.message,
          'message',
          contains('You are not authorized to delete this expense record.'),
        )),
      );
    });

    test('should throw an exception when the record to delete is not found', () async {
      // arrange
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => sheetData);
      // act & assert
      expect(
            () async => await repository.deleteExpense('2025-10', 'non-existent-id', authorizedUserEmail),
        throwsA(isA<AppException>().having(
              (e) => e.message,
          'message',
          contains('Expense record not found for deletion.'),
        )),
      );
    });

    test('should throw an exception when the sheet is not found', () async {
      // arrange
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => null);
      // act & assert
      expect(
            () async => await repository.deleteExpense('2025-10', expenseToDelete.id, authorizedUserEmail),
        throwsA(isA<AppException>().having(
              (e) => e.message,
          'message',
          contains('Sheet not found for the given month to delete from.'),
        )),
      );
    });

    test('should throw an exception when the sheetId cannot be found', () async {
      // arrange
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => sheetData);
      when(mockSheetsService.getSheetId('2025-10')).thenAnswer((_) async => null);
      // act & assert
      expect(
            () async => await repository.deleteExpense('2025-10', expenseToDelete.id, authorizedUserEmail),
        throwsA(isA<AppException>().having(
              (e) => e.message,
          'message',
          contains('Could not find sheetId for 2025-10'),
        )),
      );
    });
  });

}