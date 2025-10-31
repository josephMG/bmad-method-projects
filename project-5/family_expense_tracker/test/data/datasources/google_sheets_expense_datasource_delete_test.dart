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
    when(mockSheetsService.getSheetId(any)).thenAnswer((_) async => sheetId);
  });

  group('deleteExpense', () {
    const authorizedUserEmail = 'user@test.com';
    const unauthorizedUserEmail = 'other@test.com';

    test('should call deleteRow on the service when deletion is successful and authorized', () async {
      // arrange
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => sheetData);
      when(mockSheetsService.getSheetId(any)).thenAnswer((_) async => sheetId);
      when(mockSheetsService.deleteRow(any, any)).thenAnswer((_) async => Future.value());

      // act
      await repository.deleteExpense("${expenseToDelete.date.year}-${expenseToDelete.date.month}", expenseToDelete.id, authorizedUserEmail);

      // assert
      verify(mockSheetsService.getSheet(any)).called(1);
      verify(mockSheetsService.getSheetId(any)).called(1);
      verify(mockSheetsService.deleteRow(sheetId, 2)).called(1); // rowIndex 2 for uuid1 (1-indexed, skip header)
    });

    test('should throw UnauthorizedException when user is not authorized to delete', () async {
      // arrange
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => sheetData);
      // act & assert
      expect(
            () async => await repository.deleteExpense("${expenseToDelete.date.year}-${expenseToDelete.date.month}", expenseToDelete.id, unauthorizedUserEmail),
        throwsA(isA<UnauthorizedException>().having(
              (e) => e.message,
          'message',
          contains('You are not authorized to delete this expense record.'),
        )),
      );
    });

    test('should throw an exception if expense record not found for deletion', () async {
      // arrange
      final List<List<Object>> localSheetData = [
        ['RecordID', 'Date', 'Description', 'Category', 'Amount', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
        ['uuid2', '2025-10-11', 'Lunch', 'Food', 15.0, 'Cash', 'user@test.com', '2025-10-11T10:00:00.000Z', '2025-10-11T10:00:00.000Z', ''],
      ];
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => localSheetData);

      // act & assert
      expect(
        () => repository.deleteExpense('2025-10', 'uuid1', authorizedUserEmail),
        throwsA(predicate((e) => e is AppException && e.message == 'Expense record not found for deletion.')),
      );
      verify(mockSheetsService.getSheet(any)).called(1);
      verifyNever(mockSheetsService.getSheetId(any));
      verifyNever(mockSheetsService.deleteRow(any, any));
    });

    test('should throw an exception if sheet not found for deletion', () async {
      // arrange
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => null);

      // act & assert
      expect(
            () => repository.deleteExpense('2025-10', 'uuid1', authorizedUserEmail),

        throwsA(predicate((e) => e is AppException && e.message == 'Sheet not found for the given month to delete from.')),
      );
      verify(mockSheetsService.getSheet(any)).called(1);
      verifyNever(mockSheetsService.getSheetId(any));
      verifyNever(mockSheetsService.deleteRow(any, any));
    });

    test('should throw an exception if sheetId cannot be found', () async {
      // arrange
      when(mockSheetsService.getSheet('2025-10')).thenAnswer((_) async => sheetData);
      when(mockSheetsService.getSheetId(any)).thenAnswer((_) async => null);

      // act & assert
      await expectLater(
        () => repository.deleteExpense("2025-10",expenseToDelete.id, authorizedUserEmail),
        throwsA(predicate((e) => e is AppException && e.message == 'Could not find sheetId for 2025-10')),
      );

      // assert (verify interactions that happened before the exception)
      verify(mockSheetsService.getSheet(any)).called(1);
      verify(mockSheetsService.getSheetId(any)).called(1);
      verifyNever(mockSheetsService.deleteRow(any, any));
    });
  });
}