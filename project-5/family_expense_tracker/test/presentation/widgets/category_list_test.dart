import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/data/models/category.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart';
import 'package:family_expense_tracker/presentation/widgets/category_list.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:family_expense_tracker/presentation/widgets/reassign_category_dialog.dart';
import 'dart:async';

import '../../mock/category_repository_mocks.mocks.dart';

void main() {
  group('CategoryList', () {
    late MockCategoryRepository mockCategoryRepository;
    List<Category> testCategories = [];

    setUp(() {
      mockCategoryRepository = MockCategoryRepository();
      testCategories = [
        Category(id: '1', categoryName: 'Food', colorCode: Color(0xFFFF0000)),
        Category(id: '2', categoryName: 'Transport', colorCode: Color(0xFF00FF00)),
      ];
    });

    Future<void> pumpCategoryList(WidgetTester tester, ProviderContainer container) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: CategoryList()))),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('should display categories when loaded', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          categoriesProvider.overrideWith((ref) => Future.value(testCategories)),
        ],
      );
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await pumpCategoryList(tester, container);

      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('should show loading indicator when categories are loading', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          categoriesProvider.overrideWith((ref) => Completer<List<Category>>().future),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: CategoryList()))),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when categories fail to load', (WidgetTester tester) async {
      final error = Exception('Failed to load');
      final container = ProviderContainer(
        overrides: [
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          categoriesProvider.overrideWith((ref) => Future.error(error)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MaterialApp(home: Scaffold(body: CategoryList()))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Error: Exception: Failed to load'), findsOneWidget);
    });

    testWidgets('should delete category successfully when not in use', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          categoriesProvider.overrideWith((ref) => Future.value(testCategories)),
        ],
      );
      when(mockCategoryRepository.deleteCategory('1')).thenAnswer((_) async => Future.value());
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => [testCategories[1]]);

      await pumpCategoryList(tester, container);

      await tester.drag(find.text('Food'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Deletion'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // We need to rebuild the widget with the updated provider
      final newContainer = ProviderContainer(
        overrides: [
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          categoriesProvider.overrideWith((ref) => Future.value([testCategories[1]])),
        ],
      );
      await pumpCategoryList(tester, newContainer);

      expect(find.text('Food'), findsNothing);
      expect(find.text('Category Food deleted'), findsOneWidget);
      verify(mockCategoryRepository.deleteCategory('1')).called(1);
    });

    testWidgets('should show ReassignCategoryDialog when category is in use', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          categoriesProvider.overrideWith((ref) => Future.value(testCategories)),
        ],
      );
      when(mockCategoryRepository.deleteCategory('1')).thenThrow(CategoryInUseException('Category is in use'));
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => testCategories);

      await pumpCategoryList(tester, container);

      await tester.drag(find.text('Food'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Deletion'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.byType(ReassignCategoryDialog), findsOneWidget);
      expect(find.text('Reassign Expenses'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Category deletion cancelled.'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      verify(mockCategoryRepository.deleteCategory('1')).called(1);
    });

    testWidgets('should reassign and delete category', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          categoriesProvider.overrideWith((ref) => Future.value(testCategories)),
        ],
      );
      when(mockCategoryRepository.deleteCategory('1')).thenThrow(CategoryInUseException('Category is in use'));
      when(mockCategoryRepository.updateExpensesCategory('1', '2')).thenAnswer((_) async => Future.value());
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => [testCategories[1]]);

      await pumpCategoryList(tester, container);

      await tester.drag(find.text('Food'), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Deletion'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Reassign Expenses'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<Category>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transport').last);
      await tester.pumpAndSettle();

      when(mockCategoryRepository.deleteCategory('1')).thenAnswer((_) async => Future.value());

      await tester.tap(find.text('Reassign & Delete'));
      await tester.pumpAndSettle();

      final newContainer = ProviderContainer(
        overrides: [
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
          categoriesProvider.overrideWith((ref) => Future.value([testCategories[1]])),
        ],
      );
      await pumpCategoryList(tester, newContainer);

      expect(find.text('Food'), findsNothing);
      expect(find.text('Category Food reassigned and deleted.'), findsOneWidget);
      verify(mockCategoryRepository.updateExpensesCategory('1', '2')).called(1);
      verify(mockCategoryRepository.deleteCategory('1')).called(2);
    });
  });
}