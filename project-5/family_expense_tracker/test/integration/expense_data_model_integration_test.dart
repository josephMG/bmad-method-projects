
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:family_expense_tracker/main.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart' show AuthRepository, authRepositoryProvider, User;
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/presentation/pages/expense_list_page.dart';
import 'package:family_expense_tracker/presentation/widgets/expense_form_dialog.dart';
import 'package:family_expense_tracker/data/models/category.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart';
import 'package:family_expense_tracker/presentation/widgets/expense_list_item.dart';
import 'package:family_expense_tracker/presentation/pages/authentication_page.dart' show userProvider;
import 'package:family_expense_tracker/providers/expense_provider.dart';
import 'package:family_expense_tracker/presentation/providers/month_provider.dart';

import '../mock/auth_mocks.mocks.dart';
import '../mock/google_sheets_service_mocks.mocks.dart';
import '../mock/connectivity_mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockGoogleSheetsService mockGoogleSheetsService;
  final mockUser = User(id: '123', email: 'test@test.com', displayName: 'Test User');

  setUp(() {
    MockConnectivityPlatform.setMockConnectivityPlatform();
    mockAuthRepository = MockAuthRepository();
    mockGoogleSheetsService = MockGoogleSheetsService();

    // Mock user as already logged in
    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);
    when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => mockUser);
    when(mockAuthRepository.getGoogleSignInInstance()).thenAnswer((_) => MockGoogleSignIn());
  });

  group('Expense Data Model Integration Tests', () {
    testWidgets('Adding and updating an expense includes all required fields', (WidgetTester tester) async {
      // ARRANGE: Mock initial data and service calls
      when(mockGoogleSheetsService.getSheet(any)).thenAnswer((_) async => [
        ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
      ]);
      when(mockGoogleSheetsService.addExpense(any, any)).thenAnswer((_) async => Future.value());
      when(mockGoogleSheetsService.updateExpense(any, any)).thenAnswer((_) async => Future.value());

      // ACT: Build the app with mocked providers
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
            categoriesProvider.overrideWith((ref) => Future.value([
              Category(id: '1', categoryName: 'Food', colorCode: Colors.red),
            ])),
            userProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
          child: const MyApp(),
        )
      );
      await tester.pumpAndSettle();

      // ASSERT: We are on the ExpenseListPage
      expect(find.byType(ExpenseListPage), findsOneWidget);

      // ACT: Tap the add expense button
      await tester.tap(find.byKey(const Key('addExpenseButton')));
      await tester.pumpAndSettle();

      // ASSERT: Verify the dialog is shown
      expect(find.byType(ExpenseFormDialog), findsOneWidget);

      // ACT: Fill out the form
      await tester.enterText(find.byKey(const Key('descriptionField')), 'New Test Expense');
      await tester.enterText(find.byKey(const Key('amountField')), '123.45');
      await tester.enterText(find.byKey(const Key('paymentMethodField')), 'Cash');
      await tester.tap(find.byWidgetPredicate((widget) => widget is DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();

      // ASSERT: Verify addExpense was called with correct data
      final capturedAdd = verify(mockGoogleSheetsService.addExpense(any, captureAny)).captured;
      final addedExpense = capturedAdd.first as ExpenseRecord;

      expect(addedExpense.description, 'New Test Expense');
      expect(addedExpense.amount, 123.45);
      expect(addedExpense.recordedBy, mockUser.email); // RecordedBy
      expect(addedExpense.createdAt, isNotNull); // CreatedAt
      expect(addedExpense.lastModified, isNotNull); // LastModified

      // ARRANGE: Mock getSheet for the update operation
      final sheetDataWithExpense = [
        ['RecordID', 'Date', 'Description', 'Amount', 'Category', 'PaymentMethod', 'RecordedBy', 'CreatedAt', 'LastModified', 'Notes'],
        addedExpense.toGoogleSheetRow(),
      ];
      when(mockGoogleSheetsService.getSheet(any)).thenAnswer((_) async => sheetDataWithExpense);

      // ACT: Invalidate the provider to force a re-fetch
      final container = ProviderScope.containerOf(tester.element(find.byType(MyApp)));
      final currentMonth = container.read(currentMonthProvider);
      container.invalidate(expenseListProvider(currentMonth));
      await tester.pumpAndSettle();

      // ACT: Tap to edit the expense (assuming long press)
      await tester.longPress(find.byType(ExpenseListItem));
      await tester.pumpAndSettle();

      // ACT: Update the form
      await tester.enterText(find.byKey(const Key('descriptionField')), 'Updated Test Expense');
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();

      // ASSERT: Verify updateExpense was called with correct data
      final capturedUpdate = verify(mockGoogleSheetsService.updateExpense(any, captureAny)).captured;
      final updatedExpense = capturedUpdate.first as ExpenseRecord;

      expect(updatedExpense.id, addedExpense.id); // RecordID should be the same
      expect(updatedExpense.description, 'Updated Test Expense');
      expect(updatedExpense.recordedBy, mockUser.email); // RecordedBy should be the same
      expect(updatedExpense.lastModified.isAfter(addedExpense.lastModified), isTrue); // LastModified updated
    });
  });
}
