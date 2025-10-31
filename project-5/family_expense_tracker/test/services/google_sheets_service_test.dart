import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:google_sign_in/google_sign_in.dart';

import '../mock/auth_mocks.mocks.dart';
import '../mock/google_sheets_service_mocks.mocks.dart';

void main() {
  const String testSpreadsheetId = 'test-spreadsheet-id';

  group('GoogleSheetsService Expense CRUD', () {
    late MockAuthRepository mockAuthRepository;
    late MockSheetsApi mockSheetsApi;
    late MockSpreadsheetsResource mockSpreadsheetsResource;
    late MockSpreadsheetsValuesResource mockSpreadsheetsValuesResource;
    late MockGoogleSignIn mockGoogleSignIn;
    late GoogleSheetsService googleSheetsService;


    const String testSheetName = '2023-10';
    final testExpense = ExpenseRecord(
      id: 'test-uuid-123',
      date: DateTime(2023, 10, 26),
      description: 'Groceries',
      categoryId: 'Food',
      amount: 50.0,
      paymentMethod: 'Cash',
      recordedBy: 'user@example.com',
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
      notes: 'Weekly shopping',
    );

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockSheetsApi = MockSheetsApi();
      mockSpreadsheetsResource = MockSpreadsheetsResource();
      mockSpreadsheetsValuesResource = MockSpreadsheetsValuesResource();
      mockGoogleSignIn = MockGoogleSignIn();

      final mockSpreadsheet = sheets.Spreadsheet(
        sheets: [
          sheets.Sheet(properties: sheets.SheetProperties(
              title: testSheetName, sheetId: 123))
        ],
      );

      when(mockSheetsApi.spreadsheets).thenReturn(mockSpreadsheetsResource);
      when(mockSpreadsheetsResource.values).thenReturn(
          mockSpreadsheetsValuesResource);
      // Add this line to mock the get call for getSheetId
      when(mockSpreadsheetsResource.get(testSpreadsheetId)).thenAnswer(( 
          _) async => mockSpreadsheet);
      when(mockAuthRepository.getGoogleSignInInstance()).thenReturn(
          mockGoogleSignIn);
      when(mockGoogleSignIn.onCurrentUserChanged).thenAnswer((_) =>
          Stream.value(null));

      googleSheetsService = GoogleSheetsService(
        mockAuthRepository,
        testSpreadsheetId,
        sheetsApi: mockSheetsApi,
      );
    });

    test('should throw UnauthorizedException if no user is signed in', () async {
      when(mockAuthRepository.getGoogleSignInInstance()).thenReturn(mockGoogleSignIn);
      when(mockGoogleSignIn.currentUser).thenReturn(null);

      // Create a new service instance without sheetsApiOverride to ensure _getSheetsApi() logic is executed
      final serviceWithoutOverride = GoogleSheetsService(
        mockAuthRepository,
        testSpreadsheetId,
      );

      expect(
            () => serviceWithoutOverride.getSheet(testSheetName),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('addExpense should append a new row to the sheet', () async {
      when(mockSpreadsheetsValuesResource.append(
        any,
        testSpreadsheetId,
        testSheetName,
        valueInputOption: anyNamed('valueInputOption'),
      )).thenAnswer((_) async => sheets.AppendValuesResponse());

      await googleSheetsService.addExpense(testSheetName, testExpense);

      verify(mockSpreadsheetsValuesResource.append(
        argThat(isA<sheets.ValueRange>().having((vr) => vr.values, 'values',
            [testExpense.toGoogleSheetRow()])),
        testSpreadsheetId,
        testSheetName,
        valueInputOption: 'USER_ENTERED',
      )).called(1);
    });

    test(
        'findExpenseRowIndex should return the correct 0-based index', () async {
      when(mockSpreadsheetsValuesResource.get(
        testSpreadsheetId,
        testSheetName,
      )).thenAnswer((_) async =>
          sheets.ValueRange(values: [
            ['RecordID', 'Date', 'Name'],
            ['other-uuid', '2023-10-25', 'Old Item'],
            [testExpense.id, '2023-10-26', 'Groceries'],
          ]));

      final index = await googleSheetsService.findExpenseRowIndex(
          testSheetName, testExpense.id);
      // The service returns the 0-based index, which is 2 for the third row.
      expect(index, 2);
    });

    test(
        'findExpenseRowIndex should return null if expense not found', () async {
      when(mockSpreadsheetsValuesResource.get(
        testSpreadsheetId,
        testSheetName,
      )).thenAnswer((_) async =>
          sheets.ValueRange(values: [
            ['RecordID', 'Date', 'Name'],
            ['other-uuid', '2023-10-25', 'Old Item'],
          ]));

      final index = await googleSheetsService.findExpenseRowIndex(
          testSheetName, 'non-existent-uuid');
      expect(index, isNull);
    });

    test('updateExpense should update the correct row', () async {
      final updatedExpense = testExpense.copyWith(
          description: 'Updated Groceries');

      when(mockSpreadsheetsValuesResource.get(
        testSpreadsheetId,
        testSheetName,
      )).thenAnswer((_) async =>
          sheets.ValueRange(values: [
            ['RecordID', 'Date', 'Name'],
            ['other-uuid', '2023-10-25', 'Old Item'],
            [testExpense.id, '2023-10-26', 'Groceries'],
          ]));

      when(mockSpreadsheetsValuesResource.update(
        any,
        testSpreadsheetId,
        any,
        valueInputOption: anyNamed('valueInputOption'),
      )).thenAnswer((_) async => sheets.UpdateValuesResponse());

      await googleSheetsService.updateExpense(testSheetName, updatedExpense);

      verify(mockSpreadsheetsValuesResource.update(
        argThat(isA<sheets.ValueRange>().having((vr) => vr.values, 'values',
            [updatedExpense.toGoogleSheetRow()])),
        testSpreadsheetId,
        '${testSheetName}!A3',
        valueInputOption: 'USER_ENTERED',
      )).called(1);
    });

    test(
        'updateExpense should throw GoogleSheetsApiException on API error', () async {
      final updatedExpense = testExpense.copyWith(
          description: 'Updated Groceries');

      // Mock findExpenseRowIndex dependencies
      when(mockSpreadsheetsValuesResource.get(
        testSpreadsheetId,
        testSheetName,
      )).thenAnswer((_) async =>
          sheets.ValueRange(values: [
            ['RecordID', 'Date', 'Name'],
            [testExpense.id, '2023-10-26', 'Groceries'],
          ]));

      // Mock the update call to throw an error
      when(mockSpreadsheetsValuesResource.update(
        any,
        testSpreadsheetId,
        any,
        valueInputOption: anyNamed('valueInputOption'),
      )).thenThrow(Exception('API Error'));

      // Expect the service method to throw the wrapped exception
      expect(
            () =>
            googleSheetsService.updateExpense(testSheetName, updatedExpense),
        throwsA(isA<NetworkException>()),
      );
    });

    test('updateExpense should throw if expense not found', () async {
      final updatedExpense = testExpense.copyWith(
          description: 'Updated Groceries');

      when(mockSpreadsheetsValuesResource.get(
        testSpreadsheetId,
        testSheetName,
      )).thenAnswer((_) async =>
          sheets.ValueRange(values: [
            ['RecordID', 'Date', 'Name'],
            ['other-uuid', '2023-10-25', 'Old Item'],
          ]));

      expect(
            () =>
            googleSheetsService.updateExpense(testSheetName, updatedExpense),
        throwsA(
            isA<GoogleSheetsApiException>().having((e) => e.message, 'message',
                contains('Expense not found for update'))),
      );
    });

    test(
        'deleteExpense should throw GoogleSheetsApiException on API error', () async {
      when(mockSpreadsheetsValuesResource.get(
        testSpreadsheetId,
        testSheetName,
      )).thenAnswer((_) async =>
          sheets.ValueRange(values: [
            ['RecordID', 'Date', 'Name'],
            [testExpense.id, '2023-10-26', 'Groceries'],
          ]));
      when(mockSpreadsheetsResource.batchUpdate(
        argThat(isA<sheets.BatchUpdateSpreadsheetRequest>()),
        testSpreadsheetId,
      )).thenThrow(Exception('API Error'));

      expect(
            () =>
            googleSheetsService.deleteExpense(testSheetName, testExpense.id),
        throwsA(isA<NetworkException>()),
      );
    });

    test('deleteExpense should delete the correct row', () async {
      when(mockSpreadsheetsValuesResource.get(
        testSpreadsheetId,
        testSheetName,
      )).thenAnswer((_) async =>
          sheets.ValueRange(values: [
            ['RecordID', 'Date', 'Name'],
            ['other-uuid', '2023-10-25', 'Old Item'],
            [testExpense.id, '2023-10-26', 'Groceries'],
          ]));

      when(mockSpreadsheetsResource.batchUpdate(
        argThat(isA<sheets.BatchUpdateSpreadsheetRequest>()),
        testSpreadsheetId,
      )).thenAnswer((_) async => sheets.BatchUpdateSpreadsheetResponse());

      await googleSheetsService.deleteExpense(testSheetName, testExpense.id);

      final captured = verify(mockSpreadsheetsResource.batchUpdate(
        captureThat(isA<sheets.BatchUpdateSpreadsheetRequest>()),
        testSpreadsheetId,
      )).captured;

      final request = captured.first as sheets.BatchUpdateSpreadsheetRequest;
      final deleteRequest = request.requests!.first.deleteDimension!;
      expect(deleteRequest.range!.sheetId, 123);
      expect(deleteRequest.range!.startIndex, 2);
      expect(deleteRequest.range!.endIndex, 3);
    });

    test('deleteExpense should throw if expense not found', () async {
      when(mockSpreadsheetsValuesResource.get(
        testSpreadsheetId,
        testSheetName,
      )).thenAnswer((_) async =>
          sheets.ValueRange(values: [
            ['RecordID', 'Date', 'Name'],
          ]));

      expect(
            () =>
            googleSheetsService.deleteExpense(testSheetName, testExpense.id),
        throwsA(
            isA<GoogleSheetsApiException>().having((e) => e.message, 'message',
                contains('Expense not found'))),
      );
    });
  });

  group('GoogleSheetsService Category Usage', () {
    late MockAuthRepository mockAuthRepository;
    late MockSheetsApi mockSheetsApi;
    late MockSpreadsheetsResource mockSpreadsheetsResource;
    late MockSpreadsheetsValuesResource mockSpreadsheetsValuesResource;
    late MockGoogleSignIn mockGoogleSignIn;
    late GoogleSheetsService googleSheetsService;



    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockSheetsApi = MockSheetsApi();
      mockSpreadsheetsResource = MockSpreadsheetsResource();
      mockSpreadsheetsValuesResource = MockSpreadsheetsValuesResource();
      mockGoogleSignIn = MockGoogleSignIn();

      when(mockSheetsApi.spreadsheets).thenReturn(mockSpreadsheetsResource);
      when(mockSpreadsheetsResource.values).thenReturn(
          mockSpreadsheetsValuesResource);

      when(mockAuthRepository.getGoogleSignInInstance()).thenReturn(
          mockGoogleSignIn);
      when(mockGoogleSignIn.onCurrentUserChanged).thenAnswer((_) =>
          Stream.value(null));

      // Default mock for mockSpreadsheetsValuesResource.get
      when(mockSpreadsheetsValuesResource.get(
        any,
        any,
      )).thenAnswer((_) async => sheets.ValueRange(values: [
        ['ID', 'Date', 'Description', 'Amount', 'CategoryId', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'], // Header row
      ]));



      googleSheetsService = GoogleSheetsService(
        mockAuthRepository,
        testSpreadsheetId,
        sheetsApi: mockSheetsApi,
      );
    });

    tearDown(() {
      reset(mockAuthRepository);
      reset(mockSheetsApi);
      reset(mockSpreadsheetsResource);
      reset(mockSpreadsheetsValuesResource);
      reset(mockGoogleSignIn);
    });

    test('getAllSheetNames should return a list of sheet names', () async {
      final mockSpreadsheet = sheets.Spreadsheet(
        sheets: [
          sheets.Sheet(properties: sheets.SheetProperties(title: '2023-01')),
          sheets.Sheet(properties: sheets.SheetProperties(title: '2023-02')),
          sheets.Sheet(properties: sheets.SheetProperties(title: 'Categories')),
        ],
      );
      when(mockSpreadsheetsResource.get(testSpreadsheetId)).thenAnswer((
          _) async => mockSpreadsheet);

      final sheetNames = await googleSheetsService.getAllSheetNames();

      expect(sheetNames, ['2023-01', '2023-02', 'Categories']);
      verify(mockSpreadsheetsResource.get(testSpreadsheetId)).called(1);
    });

    group('isCategoryUsed', () {
      const String categoryIdInUse = 'cat-1';
      const String categoryIdNotInUse = 'cat-2';

      test(
          'should return true if category is used in any monthly sheet', () async {
        // Explicitly mock getAllSheetNames for this test
        final allSheetNames = ['2023-01', '2023-02', 'Categories'];
        when(mockSpreadsheetsResource.get(testSpreadsheetId)).thenAnswer((_) async =>
            sheets.Spreadsheet(
              sheets: [
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-01', sheetId: 1)),
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-02', sheetId: 2)),
                sheets.Sheet(properties: sheets.SheetProperties(title: 'Categories', sheetId: 3)),
              ],
            ));
        // Mock getSheet for 2023-01
        when(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .thenAnswer((_) async =>
            sheets.ValueRange(values: [
              [
                'ID',
                'Date',
                'Description',
                'Amount',
                'CategoryId',
                'PaymentMethod',
                'RecordedBy',
                'CreatedAt',
                'LastModified',
                'Notes'
              ],
              [
                'exp-1',
                '2023-01-01',
                'Desc1',
                '10.0',
                categoryIdNotInUse,
                'Cash',
                'user1',
                DateTime(2023, 1, 1).toIso8601String(),
                DateTime(2023, 1, 1).toIso8601String(),
                ''
              ],
            ]));
        // Mock getSheet for 2023-02
        when(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-02'))
            .thenAnswer((_) async =>
            sheets.ValueRange(values: [
              [
                'ID',
                'Date',
                'Description',
                'Amount',
                'CategoryId',
                'PaymentMethod',
                'RecordedBy',
                'CreatedAt',
                'LastModified',
                'Notes'
              ],
              [
                'exp-2',
                '2023-02-01',
                'Desc2',
                '20.0',
                categoryIdInUse,
                'Cash',
                'user2',
                DateTime(2023, 2, 1).toIso8601String(),
                DateTime(2023, 2, 1).toIso8601String(),
                ''
              ],
            ]));

        final isUsed = await googleSheetsService.isCategoryUsed(categoryIdInUse, allSheetNames);

        expect(isUsed, isTrue);
        verify(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .called(1);
        verify(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-02'))
            .called(1);
      });

      test(
          'should return false if category is not used in any monthly sheet', () async {
        // Explicitly mock getAllSheetNames for this test
        final allSheetNames = ['2023-01', '2023-02', 'Categories'];
        when(mockSpreadsheetsResource.get(testSpreadsheetId)).thenAnswer((_) async =>
            sheets.Spreadsheet(
              sheets: [
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-01', sheetId: 1)),
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-02', sheetId: 2)),
                sheets.Sheet(properties: sheets.SheetProperties(title: 'Categories', sheetId: 3)),
              ],
            ));
        // Mock getSheet for 2023-01
        when(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .thenAnswer((_) async =>
            sheets.ValueRange(values: [
              [
                'ID',
                'Date',
                'Description',
                'Amount',
                'CategoryId',
                'PaymentMethod',
                'RecordedBy',
                'CreatedAt',
                'LastModified',
                'Notes'
              ],
              [
                'exp-1',
                '2023-01-01',
                'Desc1',
                '10.0',
                categoryIdNotInUse,
                'Cash',
                'user1',
                DateTime(2023, 1, 1).toIso8601String(),
                DateTime(2023, 1, 1).toIso8601String(),
                ''
              ],
            ]));
        // Mock getSheet for 2023-02
        when(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-02'))
            .thenAnswer((_) async =>
            sheets.ValueRange(values: [
              [
                'ID',
                'Date',
                'Description',
                'Amount',
                'CategoryId',
                'PaymentMethod',
                'RecordedBy',
                'CreatedAt',
                'LastModified',
                'Notes'
              ],
              [
                'exp-2',
                '2023-02-01',
                'Desc2',
                '20.0',
                categoryIdNotInUse,
                'Cash',
                'user2',
                DateTime(2023, 2, 1).toIso8601String(),
                DateTime(2023, 2, 1).toIso8601String(),
                ''
              ],
            ]));

        final isUsed = await googleSheetsService.isCategoryUsed(categoryIdInUse, allSheetNames);

        expect(isUsed, isFalse);
        verify(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .called(1);
        verify(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-02'))
            .called(1);
      });

      test('should handle malformed expense records gracefully', () async {
        // Explicitly mock getAllSheetNames for this test
        final allSheetNames = ['2023-01', '2023-02', 'Categories'];
        when(mockSpreadsheetsResource.get(testSpreadsheetId)).thenAnswer((_) async =>
            sheets.Spreadsheet(
              sheets: [
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-01', sheetId: 1)),
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-02', sheetId: 2)),
                sheets.Sheet(properties: sheets.SheetProperties(title: 'Categories', sheetId: 3)),
              ],
            ));
        // Mock getSheet for 2023-01
        when(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .thenAnswer((_) async =>
            sheets.ValueRange(values: [
              [
                'ID',
                'Date',
                'Description',
                'Amount',
                'CategoryId',
                'PaymentMethod',
                'RecordedBy',
                'CreatedAt',
                'LastModified',
                'Notes'
              ],
              [
                'exp-1',
                '2023-01-01',
                'Desc1',
                '10.0',
                categoryIdNotInUse,
                'Cash',
                'user1',
                DateTime(2023, 1, 1).toIso8601String(),
                DateTime(2023, 1, 1).toIso8601String(),
                ''
              ],
              ['malformed-row'], // Malformed
              [
                'exp-2',
                '2023-01-02',
                'Desc2',
                '20.0',
                categoryIdInUse,
                'Cash',
                'user2',
                DateTime(2023, 1, 2).toIso8601String(),
                DateTime(2023, 1, 2).toIso8601String(),
                ''
              ],
            ]));

        final isUsed = await googleSheetsService.isCategoryUsed(categoryIdInUse, allSheetNames);

        expect(isUsed, isTrue);
        verify(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .called(1);
      });
    });

    group('updateExpensesCategory', () {
      const String oldCategoryId = 'old-cat';
      const String newCategoryId = 'new-cat';

      test('should update category for all relevant expense records', () async {
        // Explicitly mock getAllSheetNames for this test
        final allSheetNames = ['2023-01', '2023-02', 'Categories'];
        when(mockSpreadsheetsResource.get(testSpreadsheetId)).thenAnswer((_) async =>
            sheets.Spreadsheet(
              sheets: [
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-01', sheetId: 1)),
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-02', sheetId: 2)),
                sheets.Sheet(properties: sheets.SheetProperties(title: 'Categories', sheetId: 3)),
              ],
            ));

        // Mock getSheet for 2023-01
        when(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .thenAnswer((_) async =>
            sheets.ValueRange(values: [
              [
                'ID',
                'Date',
                'Description',
                'Amount',
                'CategoryId',
                'PaymentMethod',
                'RecordedBy',
                'CreatedAt',
                'LastModified',
                'Notes'
              ],
              [
                'exp-1',
                '2023-01-01',
                'Desc1',
                '10.0',
                oldCategoryId,
                'Cash',
                'user1',
                DateTime(2023, 1, 1).toIso8601String(),
                DateTime(2023, 1, 1).toIso8601String(),
                ''
              ],
              [
                'exp-2',
                '2023-01-02',
                'Desc2',
                '20.0',
                'other-cat',
                'Card',
                'user2',
                DateTime(2023, 1, 2).toIso8601String(),
                DateTime(2023, 1, 2).toIso8601String(),
                ''
              ],
            ]));
        // Mock getSheet for 2023-02
        when(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-02'))
            .thenAnswer((_) async =>
            sheets.ValueRange(values: [
              [
                'ID',
                'Date',
                'Description',
                'Amount',
                'CategoryId',
                'PaymentMethod',
                'RecordedBy',
                'CreatedAt',
                'LastModified',
                'Notes'
              ],
              [
                'exp-3',
                '2023-02-01',
                'Desc3',
                '30.0',
                oldCategoryId,
                'Cash',
                'user3',
                DateTime(2023, 2, 1).toIso8601String(),
                DateTime(2023, 2, 1).toIso8601String(),
                ''
              ],
            ]));

        when(mockSpreadsheetsResource.batchUpdate(any, any)).thenAnswer((
            _) async => sheets.BatchUpdateSpreadsheetResponse());

        await googleSheetsService.updateExpensesCategory(
            oldCategoryId, newCategoryId, allSheetNames);

        final captured = verify(mockSpreadsheetsResource.batchUpdate(
          captureThat(isA<sheets.BatchUpdateSpreadsheetRequest>()),
          testSpreadsheetId,
        )).captured.first as sheets.BatchUpdateSpreadsheetRequest;

        expect(captured.requests!.length, 2); // Two updates expected

        // Verify first request
        final request1 = captured.requests![0].updateCells!;
        expect(request1.range!.sheetId, 1);
        expect(request1.range!.startRowIndex, 1);
        expect(request1.range!.endRowIndex, 2);
        expect(request1.range!.startColumnIndex, 4); // CategoryId column
        expect(request1.range!.endColumnIndex, 5);
        expect(request1.rows![0].values![0].userEnteredValue!.stringValue,
            newCategoryId);

        // Verify second request
        final request2 = captured.requests![1].updateCells!;
        expect(request2.range!.sheetId, 2);
        expect(request2.range!.startRowIndex, 1);
        expect(request2.range!.endRowIndex, 2);
        expect(request2.range!.startColumnIndex, 4); // CategoryId column
        expect(request2.range!.endColumnIndex, 5);
        expect(request2.rows![0].values![0].userEnteredValue!.stringValue,
            newCategoryId);

        verify(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .called(1);
        verify(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-02'))
            .called(1);
      });

      test(
          'should not call batchUpdate if no expenses need reassigning', () async {
        // Explicitly mock getAllSheetNames for this test
        final allSheetNames = ['2023-01', '2023-02', 'Categories'];
        when(mockSpreadsheetsResource.get(testSpreadsheetId)).thenAnswer((_) async =>
            sheets.Spreadsheet(
              sheets: [
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-01', sheetId: 1)),
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-02', sheetId: 2)),
                sheets.Sheet(properties: sheets.SheetProperties(title: 'Categories', sheetId: 3)),
              ],
            ));
        // Mock getSheet for 2023-01
        when(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .thenAnswer((_) async =>
            sheets.ValueRange(values: [
              [
                'ID',
                'Date',
                'Description',
                'Amount',
                'CategoryId',
                'PaymentMethod',
                'RecordedBy',
                'CreatedAt',
                'LastModified',
                'Notes'
              ],
              [
                'exp-1',
                '2023-01-01',
                'Desc1',
                '10.0',
                'other-cat',
                'Cash',
                'user1',
                DateTime(2023, 1, 1).toIso8601String(),
                DateTime(2023, 1, 1).toIso8601String(),
                ''
              ],
            ]));

        await googleSheetsService.updateExpensesCategory(
            oldCategoryId, newCategoryId, allSheetNames);

        verifyNever(mockSpreadsheetsResource.batchUpdate(any, any));
        verify(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .called(1);
      });

      test(
          'should handle malformed expense records gracefully during reassign', () async {
        // Explicitly mock getAllSheetNames for this test
        final allSheetNames = ['2023-01', '2023-02', 'Categories'];
        when(mockSpreadsheetsResource.get(testSpreadsheetId)).thenAnswer((_) async =>
            sheets.Spreadsheet(
              sheets: [
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-01', sheetId: 1)),
                sheets.Sheet(properties: sheets.SheetProperties(title: '2023-02', sheetId: 2)),
                sheets.Sheet(properties: sheets.SheetProperties(title: 'Categories', sheetId: 3)),
              ],
            ));
        // Mock getSheet for 2023-01
        when(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .thenAnswer((_) async =>
            sheets.ValueRange(values: [
              [
                'ID',
                'Date',
                'Description',
                'Amount',
                'CategoryId',
                'PaymentMethod',
                'RecordedBy',
                'CreatedAt',
                'LastModified',
                'Notes'
              ],
              [
                'exp-1',
                '2023-01-01',
                'Desc1',
                '10.0',
                oldCategoryId,
                'Cash',
                'user1',
                DateTime(2023, 1, 1).toIso8601String(),
                DateTime(2023, 1, 1).toIso8601String(),
                ''
              ],
              ['malformed-row'], // Malformed
              [
                'exp-2',
                '2023-01-02',
                'Desc2',
                '20.0',
                oldCategoryId,
                'Card',
                'user2',
                DateTime(2023, 1, 2).toIso8601String(),
                DateTime(2023, 1, 2).toIso8601String(),
                ''
              ],
            ]));

        when(mockSpreadsheetsResource.batchUpdate(any, any)).thenAnswer((
            _) async => sheets.BatchUpdateSpreadsheetResponse());

        await googleSheetsService.updateExpensesCategory(
            oldCategoryId, newCategoryId, allSheetNames);

        final captured = verify(mockSpreadsheetsResource.batchUpdate(
          captureThat(isA<sheets.BatchUpdateSpreadsheetRequest>()),
          testSpreadsheetId,
        )).captured.first as sheets.BatchUpdateSpreadsheetRequest;

        expect(captured.requests!.length,
            2); // Two updates expected, malformed skipped
        verify(mockSpreadsheetsValuesResource.get(testSpreadsheetId, '2023-01'))
            .called(1);
      });
    });
  });
}


