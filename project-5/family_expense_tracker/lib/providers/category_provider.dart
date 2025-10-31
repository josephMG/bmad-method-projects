import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:family_expense_tracker/data/models/category.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:collection/collection.dart';

final _logger = Logger('CategoryProvider');

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final GoogleSheetsService _googleSheetsService;

  CategoryNotifier(this._googleSheetsService) : super(const AsyncValue.loading()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    state = const AsyncValue.loading();
    try {
      final sheetData = await _googleSheetsService.getSheet('Category');
      if (sheetData == null || sheetData.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      // Assuming the first row is headers, skip it.
      final List<Category> categories = [];
      for (int i = 1; i < sheetData.length; i++) {
        try {
          // Google Sheet row for Category: [CategoryName, ColorCode, IsActive]
          // We need to generate an ID for the category as it's not explicitly in the sheet
          // For now, we'll use the category name as the ID, but this should be improved
          // to use a stable unique ID from the sheet if available.
          final String categoryName = sheetData[i][0].toString();
          final Category category = Category.fromGoogleSheet(categoryName, sheetData[i]);
          categories.add(category);
        } catch (e) {
          _logger.warning('Skipping malformed category record: ${sheetData[i]} - $e');
        }
      }
      state = AsyncValue.data(categories);
    } on GoogleSheetsApiException catch (e) {
      _logger.severe('Google Sheets API exception while fetching categories: ${e.message}', e);
      state = AsyncValue.error(e, StackTrace.current);
    } on NetworkException catch (e) {
      _logger.severe('Network exception while fetching categories: ${e.message}', e);
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      _logger.severe('An unexpected error occurred while fetching categories: $e', e, st);
      state = AsyncValue.error(e, st);
    }
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
  final googleSheetsService = ref.watch(googleSheetsServiceProvider);
  return CategoryNotifier(googleSheetsService);
});

final categoriesStreamProvider = StreamProvider.autoDispose<List<Category>>((ref) {
  final categoryNotifier = ref.watch(categoryProvider.notifier);
  return categoryNotifier.stream.map((asyncValue) {
    return asyncValue.when(
      data: (categories) => categories,
      loading: () => [], // Return empty list while loading
      error: (error, stackTrace) {
        _logger.severe('Error in categoriesStreamProvider: $error', error, stackTrace);
        return []; // Return empty list on error
      },
    );
  });
});

final activeCategoriesProvider = Provider.autoDispose<AsyncValue<List<Category>>>((ref) {
  return ref.watch(categoryProvider).when(
    data: (categories) => AsyncValue.data(categories.where((cat) => cat.isActive).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

final categoryByIdProvider = Provider.autoDispose.family<AsyncValue<Category?>, String>((ref, categoryId) {
  return ref.watch(categoryProvider).when(
    data: (categories) => AsyncValue.data(categories.firstWhereOrNull((category) => category.id == categoryId)),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});
