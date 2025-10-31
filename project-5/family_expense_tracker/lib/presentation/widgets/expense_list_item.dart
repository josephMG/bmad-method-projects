import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart';
import 'package:family_expense_tracker/data/models/category.dart';

class ExpenseListItem extends ConsumerWidget {
  final ExpenseRecord expense;

  const ExpenseListItem({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoryProvider);

    String categoryName = 'Unknown Category';
    Color categoryColor = Colors.grey; // Default color

    categoriesAsyncValue.whenOrNull(
      data: (categories) {
        final category = categories.firstWhere(
          (cat) => cat.id == expense.categoryId,
          orElse: () => Category(id: '', categoryName: 'Unknown Category', colorCode: Colors.grey), // Provide a default Category
        );
        categoryName = expense.categoryId;
        categoryColor = category.colorCode;
      },
    );

    final formattedDate = DateFormat('MMM dd, yyyy').format(expense.date);
    final formattedAmount = NumberFormat.currency(symbol: '\$').format(expense.amount);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: categoryColor,
          radius: 12,
        ),
        title: Text(expense.description),
        subtitle: Text('$formattedDate - $categoryName'),
        trailing: Text(formattedAmount),
      ),
    );
  }
}
