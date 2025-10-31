import 'package:family_expense_tracker/core/utils/error_handler.dart';
import 'package:family_expense_tracker/data/models/category.dart';
import 'package:family_expense_tracker/data/repositories/category_repository.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';

/// An implementation of the [CategoryRepository] that uses Google Sheets as the data source.
class GoogleSheetsCategoryRepository implements CategoryRepository {
  final GoogleSheetsService _sheetsService;
  static const String _sheetName = 'Categories'; // Name of the category tab in the sheet

  GoogleSheetsCategoryRepository(this._sheetsService);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final values = await _sheetsService.getSheet(_sheetName);
      if (values == null || values.isEmpty) {
        return [];
      }

      final categories = <Category>[];
      // Skip header row, start from index 1
      for (int i = 1; i < values.length; i++) {
        if (values[i].length < 2) continue;
        final row = values[i];
        // The ID is the row index + 1 (since sheets are 1-indexed)
        final category = Category.fromGoogleSheet((i + 1).toString(), row);
        categories.add(category);
      }

      return categories;
    } catch (e) {
      ErrorHandler.handleApiError(e);
      rethrow;
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      final rowIndex = await _getCategoryRowIndex(category.id);
      if (rowIndex == null) {
        throw AppException('Category with ID ${category.id} not found.');
      }

      // Assuming category.toGoogleSheetRow() returns a list of values to update
      await _sheetsService.updateRow(
        _sheetName,
        rowIndex,
        category.toGoogleSheetRow(),
      );
    } catch (e) {
      ErrorHandler.handleApiError(e);
      rethrow;
    }
  }

  /// Finds the 0-based row index of a category by its ID.
  /// Returns null if not found.
  Future<int?> _getCategoryRowIndex(String categoryId) async {
    final values = await _sheetsService.getSheet(_sheetName);
    if (values == null || values.isEmpty) {
      return null;
    }

    // Start from row 1 (index 1) assuming row 0 is header
    for (int i = 1; i < values.length; i++) {
      // The ID is the row index + 1 (since sheets are 1-indexed)
      if ((i + 1).toString() == categoryId) {
        return i; // Return 0-based index
      }
    }
    return null;
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      final allSheetNames = await _sheetsService.getAllSheetNames();

      final isUsed = await _sheetsService.isCategoryUsed(categoryId, allSheetNames);
      if (isUsed) {
        throw CategoryInUseException('Category is currently in use and cannot be deleted.');
      }

      final sheetId = await _sheetsService.getSheetId(_sheetName);
      if (sheetId == null) {
        throw AppException('Categories sheet not found.');
      }

      final rowIndex = await _getCategoryRowIndex(categoryId);
      if (rowIndex == null) {
        throw AppException('Category with ID $categoryId not found.');
      }

      await _sheetsService.deleteRow(sheetId, rowIndex);
    } catch (e) {
      ErrorHandler.handleApiError(e);
      rethrow;
    }
  }

  @override
  Future<void> updateExpensesCategory(String oldCategoryId, String newCategoryId) async {
    try {
      final allSheetNames = await _sheetsService.getAllSheetNames();
      await _sheetsService.updateExpensesCategory(oldCategoryId, newCategoryId, allSheetNames);
    } catch (e) {
      ErrorHandler.handleApiError(e);
      rethrow;
    }
  }

  @override
  Future<bool> isCategoryUsed(String categoryId) async {
    try {
      final allSheetNames = await _sheetsService.getAllSheetNames();
      return await _sheetsService.isCategoryUsed(categoryId, allSheetNames);
    } catch (e) {
      ErrorHandler.handleApiError(e);
      rethrow;
    }
  }
}
