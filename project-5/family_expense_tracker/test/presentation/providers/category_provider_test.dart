import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/data/models/category.dart';
import 'package:family_expense_tracker/data/repositories/category_repository.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'dart:ui';

import '../../mock/category_repository_mocks.mocks.dart';

void main() {
  group('CategoryNotifier', () {
    late MockCategoryRepository mockCategoryRepository;
    late ProviderContainer container;

    setUp(() {
      mockCategoryRepository = MockCategoryRepository();
      container = ProviderContainer(
        overrides: [
          googleSheetsCategoryRepositoryProvider.overrideWithValue(mockCategoryRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should fetch categories on initialization', () async {
      // Arrange
      final categories = [Category(id: '1', categoryName: 'Food', colorCode: Color(0xFFFF0000))];
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => categories);

      // Act
      final notifier = container.read(categoryProvider.notifier);
      await container.pump(); // Wait for initialization to complete

      // Assert
      expect(notifier.state.value, categories);
      verify(mockCategoryRepository.getCategories()).called(1);
    });

    test('deleteCategory should delete category and refetch', () async {
      // Arrange
      final categories = [Category(id: '1', categoryName: 'Food', colorCode: Color(0xFFFF0000))];
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => categories); // Initial fetch
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => []); // After deletion
      when(mockCategoryRepository.deleteCategory('1')).thenAnswer((_) async => {});

      final notifier = container.read(categoryProvider.notifier);
      await container.pump(); // Initial fetch

      // Act
      await notifier.deleteCategory('1');

      // Assert
      expect(notifier.state.value, []);
      verify(mockCategoryRepository.deleteCategory('1')).called(1);
      verify(mockCategoryRepository.getCategories()).called(2); // Initial and after deletion
    });

    test('deleteCategory should rethrow CategoryInUseException', () async {
      // Arrange
      final initialCategories = [Category(id: '1', categoryName: 'Food', colorCode: Color(0xFFFF0000))];
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => initialCategories); // Initial fetch
      when(mockCategoryRepository.deleteCategory('1')).thenThrow(CategoryInUseException('In use'));

      final notifier = container.read(categoryProvider.notifier);
      await container.pump(); // Initial fetch completes

      // Act & Assert
      expect(() => notifier.deleteCategory('1'), throwsA(isA<CategoryInUseException>()));
      verify(mockCategoryRepository.deleteCategory('1')).called(1);
      verify(mockCategoryRepository.getCategories()).called(1); // Only the initial fetch
    });

    test('reassignAndDeleteCategory should reassign, delete, and refetch', () async {
      // Arrange
      final categories = [Category(id: '1', categoryName: 'Food', colorCode: Color(0xFFFF0000))];
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => categories); // Initial fetch
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => []); // After deletion
      when(mockCategoryRepository.updateExpensesCategory('1', '2')).thenAnswer((_) async => {});
      when(mockCategoryRepository.deleteCategory('1')).thenAnswer((_) async => {});

      final notifier = container.read(categoryProvider.notifier);
      await container.pump(); // Initial fetch

      // Act
      await notifier.reassignAndDeleteCategory('1', '2');

      // Assert
      expect(notifier.state.value, []);
      verify(mockCategoryRepository.updateExpensesCategory('1', '2')).called(1);
      verify(mockCategoryRepository.deleteCategory('1')).called(1);
      verify(mockCategoryRepository.getCategories()).called(2); // Initial and after deletion
    });

    test('checkIfCategoryIsUsed should return result from repository', () async {
      // Arrange
      when(mockCategoryRepository.getCategories()).thenAnswer((_) async => []);
      when(mockCategoryRepository.isCategoryUsed('1')).thenAnswer((_) async => true);

      final notifier = container.read(categoryProvider.notifier);
      await container.pump(); // Initial fetch

      // Act
      final isUsed = await notifier.checkIfCategoryIsUsed('1');

      // Assert
      expect(isUsed, true);
      verify(mockCategoryRepository.isCategoryUsed('1')).called(1);
    });
  });
}