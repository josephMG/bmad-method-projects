import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/presentation/widgets/expense_form_dialog.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart';
import 'package:family_expense_tracker/data/models/category.dart';
import 'dart:ui'; // Import for Color
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart' show User;

class MockOnSaveFunction {
  int count = 0;
  late ExpenseRecord lastExpense;
  dynamic error;

  Future<void> call(ExpenseRecord expense) {
    count++;
    lastExpense = expense;
    if (error != null) {
      return Future.error(error);
    }
    return Future.value();
  }

  void thenThrow(dynamic error) {
    this.error = error;
  }
}

void main() {
  group('ExpenseFormDialog', () {
    late MockOnSaveFunction mockOnSave;
    late ProviderContainer container;

    final testCategories = [
      Category(id: '1', categoryName: 'Food', colorCode: Color(0xFFFF0000)),
      Category(id: '2', categoryName: 'Transport', colorCode: Color(0xFF00FF00)),
    ];
    final mockUser = User(id: '123', email: 'test@test.com', displayName: 'Test User');

    setUp(() {
      mockOnSave = MockOnSaveFunction();
      

      container = ProviderContainer(
        overrides: [
          categoriesProvider.overrideWith((ref) => Future.value(testCategories)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> pumpExpenseFormDialog(WidgetTester tester, {ExpenseRecord? expenseToEdit}) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ExpenseFormDialog(
                        expenseToEdit: expenseToEdit,
                        onSave: mockOnSave.call,
                        currentUser: mockUser,
                      ),
                    );
                  },
                  child: const Text('Show Form'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Form'));
      await tester.pump();
      await tester.pumpAndSettle();
    }

    testWidgets('renders correctly for adding new expense', (tester) async {
      await pumpExpenseFormDialog(tester);

      expect(find.text('Add New Expense'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
      expect(find.byWidgetPredicate((widget) => widget is DropdownButtonFormField && widget.decoration?.labelText == 'Category'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Amount'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Notes (Optional)'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders correctly for editing existing expense', (tester) async {
      final existingExpense = ExpenseRecord(
        id: 'uuid-1',
        date: DateTime(2023, 1, 1),
        description: 'Old Name',
        categoryId: 'Food',
        amount: 100.0,
        paymentMethod: 'Cash',
        recordedBy: 'test@example.com',
        createdAt: DateTime(2023, 1, 1),
        lastModified: DateTime(2023, 1, 1),
        notes: 'Old Notes',
      );
      await pumpExpenseFormDialog(tester, expenseToEdit: existingExpense);

      expect(find.text('Edit Expense'), findsOneWidget);

      expect(find.text('Food'), findsOneWidget); // Category pre-populated


      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('validates form fields', (tester) async {
      await pumpExpenseFormDialog(tester);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a name'), findsOneWidget);
      expect(find.text('Please select a category'), findsOneWidget);
      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('calls onSave with new expense when form is valid', (tester) async {
      await pumpExpenseFormDialog(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'New Item');
      await tester.tap(find.byWidgetPredicate((widget) => widget is DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food').last); // Tap on the 'Food' item in the dropdown
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '25.50');
      await tester.enterText(find.widgetWithText(TextFormField, 'Notes (Optional)'), 'Some notes');
      await tester.enterText(find.widgetWithText(TextFormField, 'Payment Method'), 'Credit Card');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(mockOnSave.count, 1);
      expect(find.byType(AlertDialog), findsNothing); // Dialog should be dismissed
    });

    testWidgets('shows SnackBar on save error', (tester) async {
      mockOnSave.thenThrow(Exception('Save failed'));
      await pumpExpenseFormDialog(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'New Item');
      await tester.tap(find.byWidgetPredicate((widget) => widget is DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food').last); // Tap on the 'Food' item in the dropdown
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '25.50');
      await tester.enterText(find.widgetWithText(TextFormField, 'Payment Method'), 'Credit Card');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to save expense: Exception: Save failed'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget); // Dialog should remain open
    });

    testWidgets('shows SnackBar with Validation Error on ValidationException', (tester) async {
      mockOnSave.thenThrow(ValidationException('Amount cannot be negative.'));
      await pumpExpenseFormDialog(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'New Item');
      await tester.tap(find.byWidgetPredicate((widget) => widget is DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food').last); // Tap on the 'Food' item in the dropdown
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '25.50');
      await tester.enterText(find.widgetWithText(TextFormField, 'Payment Method'), 'Credit Card');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Validation Error: Amount cannot be negative.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget); // Dialog should remain open
    });

    testWidgets('shows SnackBar with Network Error on NetworkException', (tester) async {
      mockOnSave.thenThrow(NetworkException('No internet connection'));
      await pumpExpenseFormDialog(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'New Item');
      await tester.tap(find.byWidgetPredicate((widget) => widget is DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food').last); // Tap on the 'Food' item in the dropdown
      await tester.pumpAndSettle();
      await tester.enterText(find.ancestor(of: find.text('Amount'), matching: find.byType(TextFormField)), '25.50');
      await tester.enterText(find.widgetWithText(TextFormField, 'Payment Method'), 'Credit Card');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Network Error: No internet connection. Please check your connection.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget); // Dialog should remain open
    });

    testWidgets('shows SnackBar with Google Sheets API Error on GoogleSheetsApiException', (tester) async {
      mockOnSave.thenThrow(GoogleSheetsApiException('Sheet not found'));
      await pumpExpenseFormDialog(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'New Item');
      await tester.tap(find.byWidgetPredicate((widget) => widget is DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food').last); // Tap on the 'Food' item in the dropdown
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '25.50');
      await tester.enterText(find.widgetWithText(TextFormField, 'Payment Method'), 'Credit Card');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Google Sheets API Error: Sheet not found'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget); // Dialog should remain open
    });

    testWidgets('shows SnackBar with Authentication Error on UnauthorizedException', (tester) async {
      mockOnSave.thenThrow(UnauthorizedException('User not signed in'));
      await pumpExpenseFormDialog(tester);

      await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'New Item');
      await tester.tap(find.byWidgetPredicate((widget) => widget is DropdownButtonFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food').last); // Tap on the 'Food' item in the dropdown
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '25.50');
      await tester.enterText(find.widgetWithText(TextFormField, 'Payment Method'), 'Credit Card');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Authentication Error: User not signed in. Please re-authenticate.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget); // Dialog should remain open
    });
  });
}
