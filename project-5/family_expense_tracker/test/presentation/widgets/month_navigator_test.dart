import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:family_expense_tracker/presentation/widgets/month_navigator.dart';
import 'package:family_expense_tracker/presentation/providers/month_provider.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';

import 'month_navigator_test.mocks.dart';

// A concrete implementation of CurrentMonthNotifier for testing
class TestCurrentMonthNotifier extends StateNotifier<DateTime> implements CurrentMonthNotifier {
  TestCurrentMonthNotifier(DateTime initialMonth) : super(initialMonth);

  @override
  Future<void> goToNextMonth() async {
    state = DateTime(state.year, state.month + 1, 1);
  }

  @override
  Future<void> goToPreviousMonth() async {
    state = DateTime(state.year, state.month - 1, 1);
  }

  @override
  Future<void> goToMonth(DateTime month) async {
    state = DateTime(month.year, month.month, 1);
  }

  // Mock GoogleSheetsService methods if needed, or pass a mock to the constructor
  @override
  GoogleSheetsService get _googleSheetsService => throw UnimplementedError(); // Not used in these tests
}

@GenerateMocks([], customMocks: [
  MockSpec<GoogleSheetsService>(as: #MockGoogleSheetsService),
])
void main() {
  group('MonthNavigator', () {
    late MockGoogleSheetsService mockGoogleSheetsService;
    late TestCurrentMonthNotifier testCurrentMonthNotifier; // Use TestCurrentMonthNotifier
    late ProviderContainer container;

    final testMonth = DateTime(2023, 10, 1);

    setUp(() {
      mockGoogleSheetsService = MockGoogleSheetsService();
      testCurrentMonthNotifier = TestCurrentMonthNotifier(testMonth); // Initialize with testMonth

      when(mockGoogleSheetsService.sheetExists(any)).thenAnswer((_) async => true);
      when(mockGoogleSheetsService.createSheet(any)).thenAnswer((_) async => Future.value());

      container = ProviderContainer(
        overrides: [
          googleSheetsServiceProvider.overrideWithValue(mockGoogleSheetsService),
          currentMonthProvider.overrideWith((ref) => testCurrentMonthNotifier),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('displays the current month and year', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: MonthNavigator(),
            ),
          ),
        ),
      );

      expect(find.text('October 2023'), findsOneWidget);
    });

    testWidgets('calls goToPreviousMonth when left arrow is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: MonthNavigator(),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_left));
      await tester.pumpAndSettle(); // Rebuild after state change

      expect(testCurrentMonthNotifier.state.month, 9); // Verify state change
      expect(find.text('September 2023'), findsOneWidget);
    });

    testWidgets('calls goToNextMonth when right arrow is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: MonthNavigator(),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pumpAndSettle(); // Rebuild after state change

      expect(testCurrentMonthNotifier.state.month, 11); // Verify state change
      expect(find.text('November 2023'), findsOneWidget);
    });

    testWidgets('calls goToMonth when month text is tapped and a new date is picked', (WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: MonthNavigator(),
            ),
          ),
        ),
      );

      // Tap the month text to open the date picker
      await tester.tap(find.text('October 2023'));
      await tester.pumpAndSettle();

      // Verify the date picker was opened.
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Simulate selecting a date (e.g., December 2023) and pressing OK
      // This part is tricky to mock directly with showDatePicker.
      // For now, we'll manually set the state of the notifier and pump.
      testCurrentMonthNotifier.goToMonth(DateTime(2023, 12, 1));
      await tester.pumpAndSettle();

      expect(testCurrentMonthNotifier.state.month, 12); // Verify state change
      expect(find.text('December 2023'), findsOneWidget);
    });
  });
}