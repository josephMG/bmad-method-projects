import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart'
    show AuthRepository, authRepositoryProvider, User;
import 'package:family_expense_tracker/main.dart';
import 'package:family_expense_tracker/main.dart' as app;
import 'package:family_expense_tracker/presentation/pages/expense_list_page.dart';
import 'package:family_expense_tracker/presentation/providers/month_provider.dart';
import 'package:family_expense_tracker/providers/expense_provider.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import '../mock/auth_mocks.mocks.dart';
import '../mock/connectivity_mocks.dart';
import '../mock/google_sheets_service_mocks.mocks.dart';
import '../mock/category_repository_mocks.mocks.dart';
import 'package:family_expense_tracker/data/models/category.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart';


// Define a test spreadsheet ID. This should be a dedicated spreadsheet for testing.
// IMPORTANT: Replace with a real test spreadsheet ID that the test account has access to.
const String testSpreadsheetId = '1_h5-b-v-p_s_i_y_h_o_l_e_-_t_e_s_t'; // Placeholder

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleUser;
  late MockGoogleSignInAuthentication mockAuth;
  late MockGoogleSheetsService mockGoogleSheetsService;
  late MockCategoryRepository mockCategoryRepository;

  User? _currentUser; // To simulate the current user state
  late ProviderContainer container;

  setUpAll(() async {
    mockAuthRepository = MockAuthRepository();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleUser = MockGoogleSignInAccount();
    mockAuth = MockGoogleSignInAuthentication();
    mockGoogleSheetsService = MockGoogleSheetsService();
    mockCategoryRepository = MockCategoryRepository();

    final mockUser =
        User(id: '123', email: 'test@test.com', displayName: 'Test User');

    // Stub AuthRepository
    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);
    when(mockAuthRepository.getGoogleSignInInstance())
        .thenReturn(mockGoogleSignIn);
    when(mockAuthRepository.getAccessToken())
        .thenAnswer((_) async => 'mock_access_token');
    when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => mockUser);


    // Stub GoogleSignIn
    when(mockGoogleSignIn.currentUser).thenReturn(mockGoogleUser);
    when(mockGoogleSignIn.signInSilently())
        .thenAnswer((_) async => mockGoogleUser);
    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
    when(mockGoogleSignIn.onCurrentUserChanged)
        .thenAnswer((_) => Stream.value(null));
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

    // Stub GoogleSignInAccount
    when(mockGoogleUser.authentication).thenAnswer((_) async => mockAuth);

    // Stub GoogleSignInAuthentication
    when(mockAuth.accessToken).thenReturn('mock_access_token');
    when(mockAuth.idToken).thenReturn('mock_id_token');

    // Stub GoogleSheetsService

    when(mockGoogleSheetsService.createSheet(any)).thenAnswer((_) async => {});
    when(mockGoogleSheetsService.appendSheet(any, any)).thenAnswer((_) async => {});
    when(mockGoogleSheetsService.getSheetId(any)).thenAnswer((_) async => 123);
    when(mockGoogleSheetsService.batchUpdate(any)).thenAnswer((_) async => sheets.BatchUpdateSpreadsheetResponse());
    when(mockGoogleSheetsService.getSheet('Categories')).thenAnswer((_) async => [
      ['ID', 'Name', 'Color'],
      ['Food', '#FF0000'],
      ['Transport', '#0000FF'],
    ]);

    when(mockGoogleSheetsService.getSheet(argThat(startsWith('20')))).thenAnswer((_) async => [
      ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
    ]);
    when(mockGoogleSheetsService.addExpense(any, any)).thenAnswer((_) async => Future.value());
    when(mockGoogleSheetsService.updateExpense(any, any)).thenAnswer((_) async => Future.value());
    when(mockGoogleSheetsService.deleteExpense(any, any)).thenAnswer((_) async => {});
    when(mockGoogleSheetsService.sheetExists(any)).thenAnswer((_) async => true);


    // Stub CategoryRepository
    when(mockCategoryRepository.getCategories()).thenAnswer((_) async => [
      Category(id: 'Food', categoryName: 'Food', colorCode: Colors.red),
      Category(id: 'Transport', categoryName: 'Transport', colorCode: Colors.blue),
    ]);

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
        googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
      ],
    );

    // Initial setup for categories sheet
    final googleSheetsService = container.read(googleSheetsServiceProvider);
    try {
      await googleSheetsService.createSheet('Categories');
      await googleSheetsService.appendSheet('Categories', [
        ['Category', 'Color'],
        ['Food', '#FF0000'],
        ['Transport', '#0000FF'],
      ]);
    } catch (e) {
      print('Error setting up test sheet: $e');
      // It might already exist, which is fine.
    }
  });

  tearDownAll(() async {
    final googleSheetsService = container.read(googleSheetsServiceProvider);
    try {
      final sheetId = await googleSheetsService.getSheetId('Categories');
      if (sheetId != null) {
        final request = sheets.Request.fromJson({
          'deleteSheet': {'sheetId': sheetId}
        });
        await googleSheetsService.batchUpdate([request]);
      }
    } catch (e) {
      print('Error tearing down test sheet: $e');
    }
    container.dispose();
  });

  setUp(() {
    reset(mockAuthRepository);
    reset(mockGoogleSignIn);
    reset(mockGoogleUser);
    reset(mockAuth);
    reset(mockGoogleSheetsService);
    reset(mockCategoryRepository);

    MockConnectivityPlatform.setMockConnectivityPlatform();
    _currentUser = null; // Reset current user for each test

    // Re-stub essential mocks for each test
    final mockUser =
        User(id: '123', email: 'test@test.com', displayName: 'Test User');

    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => _currentUser);
    when(mockAuthRepository.getGoogleSignInInstance())
        .thenReturn(mockGoogleSignIn);
    when(mockGoogleSignIn.onCurrentUserChanged)
        .thenAnswer((_) => Stream.value(null));
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
    when(mockAuthRepository.getAccessToken())
        .thenAnswer((_) async => 'mock_access_token');
    when(mockGoogleUser.authentication).thenAnswer((_) async => mockAuth);
    when(mockAuth.accessToken).thenReturn('mock_access_token');
    when(mockAuth.idToken).thenReturn('mock_id_token');
    when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => mockUser);


    // Re-stub GoogleSheetsService for each test
    when(mockGoogleSheetsService.createSheet(any)).thenAnswer((_) async => {});
    when(mockGoogleSheetsService.appendSheet(any, any)).thenAnswer((_) async => {});
    when(mockGoogleSheetsService.getSheetId(any)).thenAnswer((_) async => 123);
    when(mockGoogleSheetsService.batchUpdate(any)).thenAnswer((_) async => sheets.BatchUpdateSpreadsheetResponse());
    when(mockGoogleSheetsService.getSheet('Categories')).thenAnswer((_) async => [
      ['ID', 'Name', 'Color'],
      ['Food', '#FF0000'],
      ['Transport', '#0000FF'],
    ]);
    when(mockGoogleSheetsService.getSheet(argThat(startsWith('20')))).thenAnswer((_) async => [
      ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
    ]);
    // Dynamic mock for addExpense
    when(mockGoogleSheetsService.addExpense(any, any)).thenAnswer((_) async => Future.value());
    when(mockGoogleSheetsService.updateExpense(any, any)).thenAnswer((_) async => Future.value());
    when(mockGoogleSheetsService.deleteExpense(any, any)).thenAnswer((_) async => {});
    when(mockGoogleSheetsService.sheetExists(any)).thenAnswer((_) async => true);


    // Re-stub CategoryRepository
    when(mockCategoryRepository.getCategories()).thenAnswer((_) async => [
      Category(id: 'Food', categoryName: 'Food', colorCode: Colors.red),
      Category(id: 'Transport', categoryName: 'Transport', colorCode: Colors.blue),
    ]);
  });

  Future<void> signIn(WidgetTester tester) async {
    _currentUser = User(id: '123', email: 'test@test.com', displayName: 'Test User');
    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => _currentUser);
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Expense Management Integration Tests', () {
    testWidgets('should add, update, and delete an expense record', (WidgetTester tester) async {
      // ARRANGE: Sign in and pump the app
      await signIn(tester);
      await pumpApp(tester);

      // Ensure ExpenseListPage is fully rendered before interacting with it
      expect(find.byType(ExpenseListPage), findsOneWidget);
      await tester.pumpAndSettle();

      // ADD a new expense
      await tester.tap(find.byKey(const Key('addExpenseButton')));
      await tester.pumpAndSettle(); // Wait for dialog to open and categories to load

      // Fill out the form
      await tester.enterText(find.byKey(const Key('descriptionField')), 'Test Expense');
      await tester.enterText(find.byKey(const Key('amountField')), '10.0');
      await tester.enterText(find.byKey(const Key('paymentMethodField')), 'Cash');
      
      // Select a category
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      // This assumes a 'Food' category exists in the test data.
      await tester.tap(find.text('Food').last);
      await tester.pumpAndSettle(); // Wait for selection to register

      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();

      // Update list
      final capturedAdd = verify(mockGoogleSheetsService.addExpense(any, captureAny)).captured;
      final addedExpense = capturedAdd.first as ExpenseRecord;
      final sheetDataWithExpense = [
        ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
        addedExpense.toGoogleSheetRow(),
      ];
      when(mockGoogleSheetsService.getSheet(any)).thenAnswer((_) async => sheetDataWithExpense);

      final container = ProviderScope.containerOf(tester.element(find.byType(MyApp)));
      final currentMonth = container.read(currentMonthProvider);
      container.invalidate(expenseListProvider(currentMonth));
      await tester.pumpAndSettle();

      // ASSERT: Verify the new expense is displayed
      expect(find.text('Test Expense'), findsOneWidget);

      // UPDATE the expense
      await tester.longPress(find.text('Test Expense'));
      await tester.pumpAndSettle(); // Wait for dialog to open and categories to load

      // Fill out the form with updated details
      await tester.enterText(find.byKey(const Key('descriptionField')), 'Updated Expense');
      await tester.enterText(find.byKey(const Key('amountField')), '25.50');
      await tester.enterText(find.byKey(const Key('paymentMethodField')), 'Credit Card');

      // Select a different category
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      // This assumes a 'Transport' category exists in the test data.
      await tester.tap(find.text('Transport').last);
      await tester.pumpAndSettle(); // Wait for selection to register

      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();

      // Update list
      final capturedUpdate = verify(mockGoogleSheetsService.updateExpense(any, captureAny)).captured;
      final updatedExpense = capturedUpdate.first as ExpenseRecord;
      when(mockGoogleSheetsService.getSheet(any)).thenAnswer((_) async => [
        ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
        updatedExpense.toGoogleSheetRow(),
      ]);
      container.invalidate(expenseListProvider(currentMonth));
      await tester.pumpAndSettle();

      // ASSERT: Verify the updated expense is displayed
      expect(find.text('Updated Expense'), findsOneWidget);
      expect(find.text('Test Expense'), findsNothing);

      // DELETE the expense
      await tester.drag(find.text('Updated Expense'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // Update list
      when(mockGoogleSheetsService.getSheet(any)).thenAnswer((_) async => [
        ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
      ]);
      container.invalidate(expenseListProvider(currentMonth));
      await tester.pumpAndSettle();

      // ASSERT: Verify the expense is no longer displayed
      expect(find.text('Updated Expense'), findsNothing);
    });

    testWidgets('should fetch expenses for a given month', (WidgetTester tester) async {
      await signIn(tester);
      await pumpApp(tester);

      expect(find.byType(ExpenseListPage), findsOneWidget);
      await tester.pumpAndSettle();

      // Add expenses for the current month
      await tester.tap(find.byKey(const Key('addExpenseButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('descriptionField')), 'Monthly Expense 1');
      await tester.enterText(find.byKey(const Key('amountField')), '50.0');
      await tester.enterText(find.byKey(const Key('paymentMethodField')), 'Bank');
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();
      final capturedAdd = verify(mockGoogleSheetsService.addExpense(any, captureAny)).captured;
      final addedExpense1 = capturedAdd.first as ExpenseRecord;

      await tester.tap(find.byKey(const Key('addExpenseButton')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('descriptionField')), 'Monthly Expense 2');
      await tester.enterText(find.byKey(const Key('amountField')), '75.0');
      await tester.enterText(find.byKey(const Key('paymentMethodField')), 'Credit');
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transport').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();

      final captured2Add = verify(mockGoogleSheetsService.addExpense(any, captureAny)).captured;
      final addedExpense2 = captured2Add.first as ExpenseRecord;
      final sheetDataWithExpense = [
        ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
        addedExpense1.toGoogleSheetRow(),
        addedExpense2.toGoogleSheetRow(),
      ];
      when(mockGoogleSheetsService.getSheet(any)).thenAnswer((_) async => sheetDataWithExpense);

      final container = ProviderScope.containerOf(tester.element(find.byType(MyApp)));
      final currentMonth = container.read(currentMonthProvider);
      container.invalidate(expenseListProvider(currentMonth));
      await tester.pumpAndSettle();

      // Verify expenses are displayed
      expect(find.text('Monthly Expense 1'), findsOneWidget);
      expect(find.text('Monthly Expense 2'), findsOneWidget);

      // Clean up
      await tester.drag(find.text('Monthly Expense 1'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      await tester.drag(find.text('Monthly Expense 2'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      when(mockGoogleSheetsService.getSheet(any)).thenAnswer((_) async => [
        ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
      ]);
      container.invalidate(expenseListProvider(currentMonth));
      await tester.pumpAndSettle();

      expect(find.text('Monthly Expense 1'), findsNothing);
      expect(find.text('Monthly Expense 2'), findsNothing);
    });

    group('Error Handling Tests', () {
      testWidgets('should display error when fetching expenses fails due to API error', (WidgetTester tester) async {
        await signIn(tester);
        await pumpApp(tester);

        // ARRANGE: Mock getSheet to throw a GoogleSheetsApiException
        when(mockGoogleSheetsService.getSheet(any)).thenThrow(GoogleSheetsApiException('Failed to fetch expenses'));

        // ACT: Invalidate the provider to trigger a re-fetch with the mocked error
        final container = ProviderScope.containerOf(tester.element(find.byType(MyApp)));
        final currentMonth = container.read(currentMonthProvider);
        container.invalidate(expenseListProvider(currentMonth));
        await tester.pumpAndSettle();

        // ASSERT: Verify that an error message is displayed
        expect(find.textContaining('Error: GoogleSheetsApiException: Failed to fetch expenses'), findsOneWidget);
      });

      testWidgets('should display error when adding an expense fails due to network error', (WidgetTester tester) async {
        await signIn(tester);
        await pumpApp(tester);

        // ARRANGE: Mock addExpense to throw a NetworkException
        when(mockGoogleSheetsService.addExpense(any, any)).thenThrow(NetworkException('No internet connection'));

        // ACT: Tap the add expense button
        await tester.tap(find.byKey(const Key('addExpenseButton')));
        await tester.pumpAndSettle();

        // Fill out the form
        await tester.enterText(find.byKey(const Key('descriptionField')), 'Error Expense');
        await tester.enterText(find.byKey(const Key('amountField')), '100.0');
        await tester.enterText(find.byKey(const Key('paymentMethodField')), 'Cash');
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('saveButton')));
        await tester.pumpAndSettle();

        final container = ProviderScope.containerOf(tester.element(find.byType(MyApp)));
        await container.pump();
        await tester.pumpAndSettle();

        // ASSERT: Verify that a network error message is displayed
        expect(find.textContaining('Network Error: No internet connection'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Error Expense'), findsNothing); // Expense should not be added to UI
      });

      testWidgets('should display error when deleting an expense fails due to unauthorized access', (WidgetTester tester) async {
        await signIn(tester);
        await pumpApp(tester);

        // ARRANGE: Add an expense first to have something to delete
        await tester.tap(find.byKey(const Key('addExpenseButton')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('descriptionField')), 'Unauthorized Expense');
        await tester.enterText(find.byKey(const Key('amountField')), '20.0');
        await tester.enterText(find.byKey(const Key('paymentMethodField')), 'Debit');
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Food').last);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('saveButton')));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle(); // Allow UI to update after adding

        // Update list
        final capturedAdd = verify(mockGoogleSheetsService.addExpense(any, captureAny)).captured;
        final addedExpense = capturedAdd.first as ExpenseRecord;
        final sheetDataWithExpense = [
          ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
          addedExpense.toGoogleSheetRow(),
        ];
        when(mockGoogleSheetsService.getSheet(any)).thenAnswer((_) async => sheetDataWithExpense);

        final container = ProviderScope.containerOf(tester.element(find.byType(MyApp)));
        final currentMonth = container.read(currentMonthProvider);
        container.invalidate(expenseListProvider(currentMonth));
        await tester.pumpAndSettle();

        expect(find.text('Unauthorized Expense'), findsOneWidget);
        app.scaffoldMessengerKey.currentState?.clearSnackBars();
        await tester.pumpAndSettle(); // let it clear

        // ARRANGE: Mock deleteExpense to throw UnauthorizedException
        when(mockGoogleSheetsService.deleteExpense(any, any)).thenThrow(UnauthorizedException('You are not authorized'));


        // ACT: Attempt to delete the expense
        await tester.drag(find.text('Unauthorized Expense'), const Offset(-500.0, 0.0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete')); // Confirm deletion
        await tester.pumpAndSettle(); // Let the snackbar appear

        // final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        // final snackBarText = snackBar.content as Text;
        // print('SnackBar text: ##${snackBarText.data}##');

        // ASSERT: Verify that an unauthorized error message is displayed
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('You are not authorized'), findsOneWidget);

        expect(find.text('Unauthorized Expense'), findsOneWidget); // Expense should still be in the list
      });
    });
  });
}
