import 'dart:async';

import 'package:family_expense_tracker/data/models/category.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';
import 'package:family_expense_tracker/presentation/pages/authentication_page.dart';
import 'package:family_expense_tracker/presentation/pages/expense_list_page.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart';
import 'package:family_expense_tracker/presentation/providers/month_provider.dart';
import 'package:family_expense_tracker/providers/expense_provider.dart';
import 'package:family_expense_tracker/presentation/widgets/month_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';

import '../../data/repositories/google_sheets_expense_repository_test.mocks.dart';
import '../../mock/auth_mocks.mocks.dart';
import '../../mock/category_repository_mocks.mocks.dart';
import '../../mock/connectivity_mocks.dart';

void main() {
  group('ExpenseListPage', () {
    final testMonth = DateTime(2023, 10, 1);
    final testCategory =
        Category(id: '1', categoryName: 'Food', colorCode: const Color(0xFFFF0000));
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
    final testUser = User(id: 'test-id', email: 'test@test.com');

    late MockAuthRepository mockAuthRepository;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSheetsService mockGoogleSheetsService;
    late MockCategoryRepository mockCategoryRepository;
    late MockGoogleSignInAccount mockGoogleSignInAccount;

    setUp(() {
      MockConnectivityPlatform.setMockConnectivityPlatform();
      mockAuthRepository = MockAuthRepository();
      mockGoogleSignIn = MockGoogleSignIn();
      mockGoogleSheetsService = MockGoogleSheetsService();
      mockCategoryRepository = MockCategoryRepository();
      mockGoogleSignInAccount = MockGoogleSignInAccount();

      when(mockGoogleSignInAccount.email).thenReturn(testUser.email!);
      when(mockAuthRepository.getGoogleSignInInstance())
          .thenReturn(mockGoogleSignIn);
      when(mockAuthRepository.signOut()).thenAnswer((_) async {});
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);
      when(mockGoogleSignIn.onCurrentUserChanged).thenAnswer((_) => Stream.value(mockGoogleSignInAccount));

      // Mock GoogleSheetsService methods that CurrentMonthNotifier and ExpenseNotifier use
      when(mockGoogleSheetsService.sheetExists(any)).thenAnswer((_) async => true);
      when(mockGoogleSheetsService.createSheet(any)).thenAnswer((_) async => Future.value());
      when(mockGoogleSheetsService.getSheet(any)).thenAnswer((_) async => [
        ['id', 'date', 'description', 'categoryId', 'amount', 'paymentMethod', 'recordedBy', 'createdAt', 'lastModified', 'notes'], // Header row
        [
          testExpense.id,
          testExpense.date.toIso8601String(),
          testExpense.description,
          testExpense.amount.toString(),
          testExpense.categoryId,
          testExpense.paymentMethod,
          testExpense.recordedBy,
          testExpense.createdAt.toIso8601String(),
          testExpense.lastModified.toIso8601String(),
          testExpense.notes,
        ],
      ]);

      // Mock CategoryRepository methods that CategoryNotifier uses
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => [testCategory]);
      when(mockCategoryRepository.deleteCategory(any)).thenAnswer((_) async => Future.value());
      when(mockCategoryRepository.updateExpensesCategory(any, any)).thenAnswer((_) async => Future.value());
      when(mockCategoryRepository.isCategoryUsed(any)).thenAnswer((_) async => false);
      when(mockCategoryRepository.updateExpensesCategory(any, any)).thenAnswer((_) async => Future.value());
      when(mockCategoryRepository.isCategoryUsed(any)).thenAnswer((_) async => false);
    });

    ProviderContainer makeProviderContainer(
        {AsyncValue<List<ExpenseRecord>>? expenseState,
        AsyncValue<List<Category>>? categoryState,
        DateTime? initialMonth}) {
      return ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          userProvider.overrideWith((ref) => Stream.value(testUser)),
          currentMonthProvider.overrideWith(
            (ref) => CurrentMonthNotifier(mockGoogleSheetsService)..state = initialMonth ?? testMonth,
          ),
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          categoryProvider.overrideWith(
            (ref) => CategoryNotifier(mockCategoryRepository, ref)..state = categoryState ?? AsyncValue.data([testCategory]),
          ),
          expenseListProvider(testMonth).overrideWith(
            (ref) => ExpenseNotifier(mockGoogleSheetsService, testMonth, ref),
          ),
        ],
      );
    }

    testWidgets('should display expenses for the current month',
        (WidgetTester tester) async {
      final container = makeProviderContainer(
          expenseState: AsyncValue.data([testExpense]));
      await container.read(expenseListProvider(testMonth).notifier).fetchExpenses();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ExpenseListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('\$50.00'), findsOneWidget);
    });

    testWidgets('should show loading indicator when expenses are fetching',
        (WidgetTester tester) async {
      final container = makeProviderContainer(
          expenseState: const AsyncValue.loading(),
          categoryState: const AsyncValue.loading());

      // Do not call fetchExpenses() here, as we want to test the loading state

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ExpenseListPage(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display MonthNavigator', (WidgetTester tester) async {
      final container = makeProviderContainer();
      await container.read(expenseListProvider(testMonth).notifier).fetchExpenses();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ExpenseListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MonthNavigator), findsOneWidget);
    });

    testWidgets(
        'should navigate to previous month when previous button is tapped',
        (WidgetTester tester) async {
      final container = makeProviderContainer();
      await container.read(expenseListProvider(testMonth).notifier).fetchExpenses();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ExpenseListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('October 2023'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_left));
      await tester.pumpAndSettle();

      expect(container.read(currentMonthProvider), DateTime(2023, 9, 1));
    });

    testWidgets('should navigate to next month when next button is tapped',
        (WidgetTester tester) async {
      final container = makeProviderContainer();
      await container.read(expenseListProvider(testMonth).notifier).fetchExpenses();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ExpenseListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('October 2023'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pumpAndSettle();

      expect(container.read(currentMonthProvider), DateTime(2023, 11, 1));
    });

    testWidgets('should update month when month picker is used',
        (WidgetTester tester) async {
      final container = makeProviderContainer();
      await container.read(expenseListProvider(testMonth).notifier).fetchExpenses();
      final newDate = DateTime(2024, 9, 1);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ExpenseListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('October 2023'), findsOneWidget);

      await tester.tap(find.text('October 2023')); // Opens the date picker
      await tester.pumpAndSettle();


      // the date-year under CalendarPicker
      final textElem = find.descendant(of: find.byType(CalendarDatePicker), matching: find.text('October 2023'));
      await tester.tap(textElem); // Opens the date picker
      await tester.pumpAndSettle();

      // Tap on the year display to switch to year selection view
      await tester.tap(find.text('2024'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(container.read(currentMonthProvider), newDate);
    });
  });
}