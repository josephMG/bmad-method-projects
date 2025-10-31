import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/data/models/category.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart';

class ReassignCategoryDialog extends ConsumerStatefulWidget {
  final String oldCategoryId;
  final String oldCategoryName;

  const ReassignCategoryDialog({
    super.key,
    required this.oldCategoryId,
    required this.oldCategoryName,
  });

  @override
  ConsumerState<ReassignCategoryDialog> createState() => _ReassignCategoryDialogState();
}

class _ReassignCategoryDialogState extends ConsumerState<ReassignCategoryDialog> {
  Category? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return AlertDialog(
      title: const Text('Reassign Expenses'),
      content: categoriesAsyncValue.when(
        data: (categories) {
          final availableCategories = categories
              .where((cat) => cat.id != widget.oldCategoryId)
              .toList();

          if (availableCategories.isEmpty) {
            return const Text(
                'No other categories available to reassign expenses to.');
          }

          return DropdownButtonFormField<Category>(
            value: _selectedCategory,
            hint: const Text('Select a new category'),
            onChanged: (Category? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            items: availableCategories.map<DropdownMenuItem<Category>>((Category category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Text(category.categoryName),
              );
            }).toList(),
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('Error loading categories: $error'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selectedCategory == null
              ? null
              : () {
                  Navigator.of(context).pop(_selectedCategory!.id);
                },
          child: const Text('Reassign & Delete'),
        ),
      ],
    );
  }
}
