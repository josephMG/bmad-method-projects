import 'package:family_expense_tracker/data/models/category.dart';

/// Abstract repository for managing categories.
abstract class CategoryRepository {
  /// Fetches all categories.
  Future<List<Category>> getCategories();

  /// Updates a category.
  Future<void> updateCategory(Category category);

  /// Deletes a category by its ID.
  /// Throws an exception if the category is in use.
  Future<void> deleteCategory(String categoryId);

  /// Updates the category of all expense records from oldCategoryId to newCategoryId.
  Future<void> updateExpensesCategory(String oldCategoryId, String newCategoryId);

  /// Checks if a category is currently used in any expense records.
  Future<bool> isCategoryUsed(String categoryId);
}
