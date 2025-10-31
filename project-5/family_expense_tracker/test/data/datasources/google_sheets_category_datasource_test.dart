import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:family_expense_tracker/data/datasources/google_sheets_category_datasource.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:family_expense_tracker/data/models/category.dart';

import '../../mock/category_repository_mocks.mocks.dart';
import '../../mock/google_sheets_service_mocks.mocks.dart';

void main() {
  group('GoogleSheetsCategoryRepository', () {
    late GoogleSheetsCategoryRepository repository;
    late MockGoogleSheetsService mockGoogleSheetsService;

    setUp(() {
      mockGoogleSheetsService = MockGoogleSheetsService();
      repository = GoogleSheetsCategoryRepository(mockGoogleSheetsService);
    });

    group('deleteCategory', () {
      test('should delete category successfully when not in use', () async {
        // Arrange
        const categoryId = '2';
        when(
          mockGoogleSheetsService.getAllSheetNames(),
        ).thenAnswer((_) async => ['Categories', 'January', 'February']);
        when(
          mockGoogleSheetsService.isCategoryUsed(any, any),
        ).thenAnswer((_) async => false);
        when(mockGoogleSheetsService.getSheet('Categories')).thenAnswer(
          (_) async => [
            ['ID', 'Name', 'Color'],
            ['1', 'Food', '#FF0000'],
            ['2', 'Transport', '#00FF00'],
          ],
        );
        when(
          mockGoogleSheetsService.getSheetId('Categories'),
        ).thenAnswer((_) async => 123);
        when(
          mockGoogleSheetsService.deleteRow(123, 1),
        ).thenAnswer((_) async => {}); // Row index 1 for categoryId '2'

        // Act
        await repository.deleteCategory(categoryId);

        // Assert
        verify(mockGoogleSheetsService.getAllSheetNames()).called(1);
        verify(
          mockGoogleSheetsService.isCategoryUsed(
            categoryId,
            argThat(isA<List<String>>()),
          ),
        ).called(1);
        verify(mockGoogleSheetsService.getSheet('Categories')).called(1);
        verify(mockGoogleSheetsService.getSheetId('Categories')).called(1);
        verify(mockGoogleSheetsService.deleteRow(123, 1)).called(1);
      });

      test(
        'should throw CategoryInUseException when category is in use',
        () async {
          // Arrange
          const categoryId = '2';
          when(
            mockGoogleSheetsService.getAllSheetNames(),
          ).thenAnswer((_) async => ['Categories', 'January', 'February']);
          when(
            mockGoogleSheetsService.isCategoryUsed(
              categoryId,
              argThat(isA<List<String>>()),
            ),
          ).thenAnswer((_) async => true);

          // Act
          await expectLater(
            () => repository.deleteCategory(categoryId),
            throwsA(predicate((e) => e is CategoryInUseException && e.message == 'Category is currently in use and cannot be deleted.')),
          );

          // Assert
          verify(mockGoogleSheetsService.getAllSheetNames()).called(1);
          verify(mockGoogleSheetsService.isCategoryUsed(any, any)).called(1);
          verifyNever(mockGoogleSheetsService.getSheet('Categories'));
          verifyNever(mockGoogleSheetsService.getSheetId('Categories'));
          verifyNever(mockGoogleSheetsService.deleteRow(any, any));
        },
      );

      test('should throw AppException if category not found', () async {
        // Arrange
        const categoryId = '99'; // Non-existent ID
        when(
          mockGoogleSheetsService.getAllSheetNames(),
        ).thenAnswer((_) async => ['Categories', 'January', 'February']);
        when(
          mockGoogleSheetsService.isCategoryUsed(
            categoryId,
            argThat(isA<List<String>>()),
          ),
        ).thenAnswer((_) async => false);
        when(mockGoogleSheetsService.getSheet('Categories')).thenAnswer(
          (_) async => [
            ['ID', 'Name', 'Color'],
            ['1', 'Food', '#FF0000'],
            ['2', 'Transport', '#00FF00'],
          ],
        );
        when(
          mockGoogleSheetsService.getSheetId('Categories'),
        ).thenAnswer((_) async => 123);


        // Act
        await expectLater(
              () => repository.deleteCategory(categoryId),
          throwsA(isA<AppException>()),
        );

        // Act & Assert
        verify(mockGoogleSheetsService.getAllSheetNames()).called(1);
        verify(
          mockGoogleSheetsService.isCategoryUsed(
            categoryId,
            argThat(isA<List<String>>()),
          ),
        ).called(1);
        verify(mockGoogleSheetsService.getSheet('Categories')).called(1);
        verify(mockGoogleSheetsService.getSheetId('Categories')).called(1);
        verifyNever(mockGoogleSheetsService.deleteRow(any, any));
      });
    });

    group('updateExpensesCategory', () {
      test(
        'should call GoogleSheetsService to update expenses category',
        () async {
          // Arrange
          const oldCategoryId = '1';
          const newCategoryId = '2';
          when(
            mockGoogleSheetsService.getAllSheetNames(),
          ).thenAnswer((_) async => ['Categories', 'January', 'February']);
          when(
            mockGoogleSheetsService.updateExpensesCategory(
              oldCategoryId,
              newCategoryId,
              any,
            ),
          ).thenAnswer((_) async => {});

          // Act
          await repository.updateExpensesCategory(oldCategoryId, newCategoryId);

          // Assert
          verify(mockGoogleSheetsService.getAllSheetNames()).called(1);
          verify(
            mockGoogleSheetsService.updateExpensesCategory(
              oldCategoryId,
              newCategoryId,
              any,
            ),
          ).called(1);
        },
      );
    });

    group('isCategoryUsed', () {
      test(
        'should return true if GoogleSheetsService indicates category is used',
        () async {
          // Arrange
          const categoryId = '1';
          when(
            mockGoogleSheetsService.getAllSheetNames(),
          ).thenAnswer((_) async => ['Categories', 'January', 'February']);
          when(
            mockGoogleSheetsService.isCategoryUsed(
              categoryId,
              argThat(isA<List<String>>()),
            ),
          ).thenAnswer((_) async => true);

          // Act
          final result = await repository.isCategoryUsed(categoryId);

          // Assert
          expect(result, true);
          verify(mockGoogleSheetsService.getAllSheetNames()).called(1);
          verify(
            mockGoogleSheetsService.isCategoryUsed(
              categoryId,
              argThat(isA<List<String>>()),
            ),
          ).called(1);
        },
      );

      test(
        'should return false if GoogleSheetsService indicates category is not used',
        () async {
          // Arrange
          const categoryId = '1';
          when(
            mockGoogleSheetsService.getAllSheetNames(),
          ).thenAnswer((_) async => ['Categories', 'January', 'February']);
          when(
            mockGoogleSheetsService.isCategoryUsed(
              categoryId,
              argThat(isA<List<String>>()),
            ),
          ).thenAnswer((_) async => false);

          // Act
          final result = await repository.isCategoryUsed(categoryId);

          // Assert
          expect(result, false);
          verify(mockGoogleSheetsService.getAllSheetNames()).called(1);
          verify(
            mockGoogleSheetsService.isCategoryUsed(
              categoryId,
              argThat(isA<List<String>>()),
            ),
          ).called(1);
        },
      );
    });

    group('getCategories', () {
      test('should return a list of categories when data is available', () async {
        // Arrange
        when(mockGoogleSheetsService.getSheet('Categories')).thenAnswer((_) async => [
          ['ID', 'Name', 'Color'],
          ['Food', '#FF0000', 'true'],
          ['Transport', '#0000FF', 'false'],
        ]);

        // Act
        final categories = await repository.getCategories();

        // Assert
        expect(categories, isA<List<Category>>());
        expect(categories.length, 2);
        expect(categories[0].categoryName, 'Food');
        expect(categories[1].categoryName, 'Transport');
        verify(mockGoogleSheetsService.getSheet('Categories')).called(1);
      });

      test('should return an empty list when no data is available', () async {
        // Arrange
        when(mockGoogleSheetsService.getSheet('Categories')).thenAnswer((_) async => null);

        // Act
        final categories = await repository.getCategories();

        // Assert
        expect(categories, isEmpty);
        verify(mockGoogleSheetsService.getSheet('Categories')).called(1);
      });

      test('should return an empty list when sheet is empty', () async {
        // Arrange
        when(mockGoogleSheetsService.getSheet('Categories')).thenAnswer((_) async => []);

        // Act
        final categories = await repository.getCategories();

        // Assert
        expect(categories, isEmpty);
        verify(mockGoogleSheetsService.getSheet('Categories')).called(1);
      });

      test('should handle malformed rows gracefully', () async {
        // Arrange
        when(mockGoogleSheetsService.getSheet('Categories')).thenAnswer((_) async => [
          ['ID', 'Name', 'Color'],
          ['Food', '#FF0000', 'true'],
          ['malformed-row'], // This row will be skipped
          ['Transport', '#0000FF', 'false'],
        ]);

        // Act
        final categories = await repository.getCategories();

        // Assert
        expect(categories.length, 2);
        expect(categories[0].categoryName, 'Food');
        expect(categories[1].categoryName, 'Transport');
      });
    });
  });
}
