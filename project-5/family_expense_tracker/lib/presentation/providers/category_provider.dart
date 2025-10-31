import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/data/models/category.dart';
import 'package:family_expense_tracker/data/repositories/category_repository.dart';
import 'package:family_expense_tracker/data/datasources/google_sheets_category_datasource.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:logging/logging.dart';
import 'package:family_expense_tracker/presentation/providers/sync_status_provider.dart';

final _logger = Logger('CategoryProvider');

/// Notifier for managing category-related state and operations.
class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _categoryRepository;
  final Ref ref;

    CategoryNotifier(this._categoryRepository, this.ref) : super(const AsyncValue.loading()) {
  }

    Future<void> _fetchCategories() async {
      try {

        state = const AsyncValue.loading();

        final categories = await _categoryRepository.getCategories();

        state = AsyncValue.data(categories);

      } catch (e, st) {

        _logger.severe('Error fetching categories: $e', e, st);

        state = AsyncValue.error(e, st);

      }

    }

  

    Future<void> updateCategory(Category category) async {
      try {
        await _categoryRepository.updateCategory(category);
        await _fetchCategories();
      } catch (e, st) {
        _logger.severe('Error updating category: $e', e, st);
        rethrow;
      }
    }

    Future<void> deleteCategory(String categoryId) async {

      try {

        await _categoryRepository.deleteCategory(categoryId);

        // If deletion is successful, refetch categories to update the UI

        await _fetchCategories();

      } catch (e, st) {

        _logger.severe('Error deleting category: $e', e, st);

        rethrow; // Rethrow to be caught by the UI for error display

      }

    }

  

    Future<void> reassignAndDeleteCategory(String oldCategoryId, String newCategoryId) async {

      try {

        await _categoryRepository.updateExpensesCategory(oldCategoryId, newCategoryId);

        await _categoryRepository.deleteCategory(oldCategoryId);

        await _fetchCategories();

      } catch (e, st) {

        _logger.severe('Error reassigning and deleting category: $e', e, st);

        rethrow;

      }

    }

  

    /// Checks if a category is currently used in any expense records.

    Future<bool> checkIfCategoryIsUsed(String categoryId) async {

      try {

        return await _categoryRepository.isCategoryUsed(categoryId);

      } catch (e, st) {

        _logger.severe('Error checking if category is used: $e', e, st);

        rethrow;

      }

    }
}

final googleSheetsCategoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final googleSheetsService = ref.watch(googleSheetsServiceProvider);
  return GoogleSheetsCategoryRepository(googleSheetsService);
});

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
  final categoryRepository = ref.watch(googleSheetsCategoryRepositoryProvider);
  final notifier = CategoryNotifier(categoryRepository, ref);
  notifier._fetchCategories();
  return notifier;
});


final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoriesState = ref.watch(categoryProvider);
  return categoriesState.value ?? [];
});
