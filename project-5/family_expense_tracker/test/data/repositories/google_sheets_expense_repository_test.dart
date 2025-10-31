import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:family_expense_tracker/data/datasources/google_sheets_expense_datasource.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';

import '../../mock/google_sheets_service_mocks.mocks.dart';

@GenerateMocks([GoogleSheetsService])
void main() {
  late MockGoogleSheetsService mockSheetsService;
  late GoogleSheetsExpenseRepository repository;

  setUp(() {
    mockSheetsService = MockGoogleSheetsService();
    repository = GoogleSheetsExpenseRepository(mockSheetsService);
  });

  group('addExpense', () {
    test('should call appendSheet with the correct data', () async {
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
      expect(capturedRow[6], 'user@test.com');
      expect(DateTime.tryParse(capturedRow[7].toString()), isNotNull); // CreatedAt
      expect(DateTime.tryParse(capturedRow[8].toString()), isNotNull); // LastModified
    });
  });

  group('updateExpense', () {
    test('should call updateSheet with the correct data and updated lastModified', () async {
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
}
