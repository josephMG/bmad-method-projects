import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:family_expense_tracker/main.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart' show AuthRepository, authRepositoryProvider, User;
import 'package:family_expense_tracker/presentation/pages/expense_list_page.dart';
import 'package:family_expense_tracker/presentation/pages/authentication_page.dart' show AuthenticationPage, userProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart' show googleSheetsCategoryRepositoryProvider, categoryProvider;
import 'package:family_expense_tracker/presentation/pages/category_management_page.dart';

// Import the generated mocks
import '../mock/auth_mocks.mocks.dart';
import '../mock/connectivity_mocks.dart';
import '../mock/category_repository_mocks.mocks.dart';
import '../mock/google_sheets_service_mocks.mocks.dart';

import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:family_expense_tracker/data/models/category.dart';

// Define a test spreadsheet ID. This should be a dedicated spreadsheet for testing.
// IMPORTANT: This spreadsheet should be empty or managed by the tests themselves.
const String testSpreadsheetId = 'YOUR_TEST_SPREADSHEET_ID'; // TODO: Replace with an actual test spreadsheet ID

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockCategoryRepository mockCategoryRepository;
  late MockGoogleSheetsService mockGoogleSheetsService;
  User? _currentUser; // To simulate the current user state

  setUpAll(() async {
    // Ensure the test spreadsheet is clean before running any tests
    // This might involve deleting all sheets except the default one, or clearing all data.
    // For now, we'll assume the test spreadsheet is managed externally or will be cleared by specific tests.
    // Example: await GoogleSheetsService.create(mockAuthRepository, customSpreadsheetId: testSpreadsheetId).deleteAllSheetsExceptDefault();
  });

  setUp(() {
    MockConnectivityPlatform.setMockConnectivityPlatform();
    mockAuthRepository = MockAuthRepository();
    mockGoogleSignIn = MockGoogleSignIn();
    mockCategoryRepository = MockCategoryRepository();
    mockGoogleSheetsService = MockGoogleSheetsService();
    _currentUser = null; // Reset current user for each test

    when(mockAuthRepository.getGoogleSignInInstance()).thenReturn(mockGoogleSignIn);
    when(mockGoogleSignIn.onCurrentUserChanged).thenAnswer((_) => Stream.value(null));
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

    // Mock getCurrentUser to return the current user state
    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => _currentUser);
  });

  group('Integration Tests with Mock Authentication', () {
    testWidgets('Application starts and user can be mocked as signed in', (WidgetTester tester) async {
      // ARRANGE: Mock successful sign-in
      final mockUser = User(
          id: '123', email: 'test@test.com', displayName: 'Test User');
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);
      when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async {
        // Simulate successful sign-in by changing the current user
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);
        return mockUser;
      });

      // Simulate a sign-in
      await mockAuthRepository.signInWithGoogle();
      await tester.pumpAndSettle(); // Allow navigation to complete
      // ACT: Build the app with the mocked repository
      await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(mockAuthRepository),
              googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
            ],
            child: const MyApp(),
          )
      );
      await tester.pumpAndSettle(); // Initial pump

      // ASSERT: Verify navigation to ExpenseListPage
      expect(find.byType(ExpenseListPage), findsOneWidget);
      expect(find.text('Monthly Expenses'), findsOneWidget);
      await tester.pumpAndSettle(); // Allow the ExpenseListPage to fully render
    });
  });

  group('Category Management Integration Tests', () {
    testWidgets('should fetch and display categories', (WidgetTester tester) async {
      // ARRANGE: Mock successful sign-in and categories
      final mockUser = User(
          id: '123', email: 'test@test.com', displayName: 'Test User');
      _currentUser = mockUser; // Set current user state before building the app

      // Mock categories
      final mockCategories = [
        Category(id: '1', categoryName: 'Food', colorCode: Colors.red),
        Category(id: '2', categoryName: 'Transport', colorCode: Colors.blue),
      ];
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => mockCategories);
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser); // Directly set current user

      // ACT: Build the app with the mocked repositories
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
            googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          ],
          child: const MyApp(),
        )
      );
      await tester.pumpAndSettle(); // Initial pump

      // Ensure ExpenseListPage is fully rendered before interacting with it
      expect(find.byType(ExpenseListPage), findsOneWidget);
      await tester.pumpAndSettle(); // Ensure ExpenseListPage is fully built and rendered

      // ACT: Navigate to the category management page
      await tester.tap(find.byKey(const Key('categoryManagementButton')));
      await tester.pumpAndSettle();

      // ASSERT: Verify navigation to CategoryManagementPage and display of categories
      expect(find.byType(CategoryManagementPage), findsOneWidget);
      expect(find.text('Category Management'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      verify(mockCategoryRepository.getCategories()).called(1);
    });

    testWidgets('should create a new category', (WidgetTester tester) async {
      // ARRANGE: Mock successful sign-in
      final mockUser = User(
          id: '123', email: 'test@test.com', displayName: 'Test User');
      when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async {
        _currentUser = mockUser; // Update current user state
        return mockUser;
      });

      // Mock createCategory (assuming a method exists or will be added to CategoryRepository)
      // For now, we'll mock the underlying GoogleSheetsService.updateSheet call

      // ACT: Build the app with the mocked repositories
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
            googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          ],
          child: const MyApp(),
        )
      );
      await tester.pumpAndSettle(); // Initial pump

      // Simulate a sign-in
      await mockAuthRepository.signInWithGoogle();
      await tester.pumpAndSettle();

      // TODO: Simulate UI interaction to create a new category
      // For now, just verify that createCategory was called
      // Example: await mockCategoryRepository.createCategory(Category(id: '3', name: 'New Category', budget: 100.0));
      // verify(mockCategoryRepository.createCategory(any)).called(1);
    });

    testWidgets('should update an existing category', (WidgetTester tester) async {
      // ARRANGE: Mock successful sign-in and initial categories
      final mockUser = User(
          id: '123', email: 'test@test.com', displayName: 'Test User');
      _currentUser = mockUser; // Set current user state before building the app

      final initialCategories = [
        Category(id: '1', categoryName: 'Food', colorCode: Colors.red),
        Category(id: '2', categoryName: 'Transport', colorCode: Colors.blue),
      ];
      final updatedCategory = Category(id: '1', categoryName: 'Groceries', colorCode: Colors.green);

      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => initialCategories);
      when(mockCategoryRepository.updateCategory(argThat(isA<Category>())))
          .thenAnswer((_) async {
        // Simulate the update by returning the updated category in subsequent fetches
        when(mockCategoryRepository.getCategories()).thenAnswer((_) async => [updatedCategory, initialCategories[1]]);
        return Future.value();
      });

      // ACT: Build the app with the mocked repositories
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
            googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          ],
          child: const MyApp(),
        )
      );
      await tester.pumpAndSettle(); // Initial pump

      // Ensure ExpenseListPage is fully rendered before interacting with it
      expect(find.byType(ExpenseListPage), findsOneWidget);
      await tester.pumpAndSettle();

      // Navigate to the category management page
      await tester.tap(find.byKey(const Key('categoryManagementButton')));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryManagementPage), findsOneWidget);
      expect(find.text('Category Management'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget); // Initial category should be present

      // Long press on the 'Food' category to open the edit dialog
      await tester.longPress(find.text('Food'));
      await tester.pumpAndSettle();

      // Verify the edit dialog is open
      expect(find.text('Edit Category'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      // Enter new category name
      await tester.enterText(find.byType(TextFormField), 'Groceries');
      await tester.pumpAndSettle();

      // Tap on the color picker (ListTile)
      await tester.tap(find.text('Select Color'));
      await tester.pumpAndSettle();

      // Select a new color (e.g., black)
      // This assumes BlockPicker is used and Colors black is visible
      // Finding a specific color in BlockPicker can be tricky without a key.
      // For simplicity, we'll tap on a general area that would correspond to black.
      final element = find.byWidgetPredicate((Widget widget) {
        if (widget is Container) {
          final decoration = widget.decoration;
          if (decoration is BoxDecoration) {
            final color = decoration.color;
            return color == Colors.black;
          }
        }
        return false;
      });

      await tester.tap(element);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Got it')); // Tap 'Got it' to close color picker
      await tester.pumpAndSettle();

      // Tap the save button
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // ASSERT: Verify updateCategory was called and UI reflects changes
      verify(mockCategoryRepository.updateCategory(argThat(
        isA<Category>()
            .having((c) => c.id, 'id', '1')
            .having((c) => c.categoryName, 'categoryName', 'Groceries')
            .having((c) => c.colorCode, 'colorCode', Colors.black),
      ))).called(1);

      // Verify the updated category is displayed
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Food'), findsNothing); // Original category should be gone
    });

    testWidgets('should delete a category', (WidgetTester tester) async {
      // ARRANGE: Mock successful sign-in and initial categories
      final mockUser = User(
          id: '123', email: 'test@test.com', displayName: 'Test User');
      _currentUser = mockUser; // Set current user state before building the app

      final initialCategories = [
        Category(id: '1', categoryName: 'Food', colorCode: Colors.red),
        Category(id: '2', categoryName: 'Transport', colorCode: Colors.blue),
      ];

      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => initialCategories);
      when(mockCategoryRepository.isCategoryUsed('1')).thenAnswer((_) async => false);
      when(mockCategoryRepository.deleteCategory('1')).thenAnswer((_) async {
        // Simulate the deletion by returning the updated category list in subsequent fetches
        when(mockCategoryRepository.getCategories()).thenAnswer((_) async => [initialCategories[1]]);
        return Future.value();
      });

      // ACT: Build the app with the mocked repositories
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
            googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          ],
          child: const MyApp(),
        )
      );
      await tester.pumpAndSettle(); // Initial pump

      // Ensure ExpenseListPage is fully rendered before interacting with it
      expect(find.byType(ExpenseListPage), findsOneWidget);
      await tester.pumpAndSettle();

      // Navigate to the category management page
      await tester.tap(find.byKey(const Key('categoryManagementButton')));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryManagementPage), findsOneWidget);
      expect(find.text('Food'), findsOneWidget); // Initial category should be present

      // Swipe the 'Food' category to reveal the delete button
      await tester.drag(find.text('Food'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // Confirm deletion in the dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // ASSERT: Verify deleteCategory was called and UI reflects changes
      verify(mockCategoryRepository.deleteCategory('1')).called(1);

      // Verify the category is no longer displayed
      expect(find.text('Food'), findsNothing);
      expect(find.text('Transport'), findsOneWidget); // The other category should still be there
    });
  });
}
