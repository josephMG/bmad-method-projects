import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:family_expense_tracker/presentation/widgets/reassign_category_dialog.dart';
import 'package:family_expense_tracker/presentation/widgets/category_form_dialog.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return categoriesAsyncValue.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(categoriesProvider.future),
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Dismissible(
                key: ValueKey(category.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  final bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Deletion"),
                        content: Text(
                            "Are you sure you want to delete the category '${category.categoryName}'?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm != true) {
                    return false;
                  }

                  try {
                    await ref.read(categoryProvider.notifier).deleteCategory(category.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Category ${category.categoryName} deleted')),
                    );
                    ref.refresh(categoriesProvider);
                    return true; // Successfully deleted
                  } catch (e) {
                    String errorMessage = 'Failed to delete category.';
                                                                if (e is CategoryInUseException) {
                                                                  final shouldReassign = await showDialog<String?>(
                                                                    context: context,                        builder: (BuildContext context) {
                          return ReassignCategoryDialog(
                            oldCategoryId: category.id,
                            oldCategoryName: category.categoryName,
                          );
                        },
                      );

                      if (shouldReassign != null) {
                        // User chose to reassign
                        await ref.read(categoryProvider.notifier).reassignAndDeleteCategory(
                              category.id,
                              shouldReassign,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Category ${category.categoryName} reassigned and deleted.')),
                        );
                        ref.refresh(categoriesProvider);
                        return true; // Reassigned and deleted
                      } else {
                        // User cancelled reassignment
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Category deletion cancelled.')),
                        );
                        ref.refresh(categoriesProvider); // Refresh to show the category again
                        return false; // Do not dismiss
                      }
                    } else {
                      errorMessage = 'Failed to delete category: ${e.toString()}';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                      ref.refresh(categoriesProvider); // Refresh to show the category again
                      return false; // Do not dismiss
                    }
                  }
                },
                onDismissed: (direction) {
                  // The actual deletion/reassignment is handled in confirmDismiss.
                  // This callback is now primarily for visual confirmation if needed,
                  // but the item is already logically removed from the list if confirmDismiss returned true.
                },
                child: GestureDetector(
                  onLongPress: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return CategoryFormDialog(
                          categoryToEdit: category,
                          onSave: (editedCategory) async {
                            await ref.read(categoryProvider.notifier).updateCategory(editedCategory);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Category ${editedCategory.categoryName} updated')),
                            );
                            ref.refresh(categoriesProvider);
                          },
                        );
                      },
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.colorCode,
                        radius: 12,
                      ),
                      title: Text(category.categoryName),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
