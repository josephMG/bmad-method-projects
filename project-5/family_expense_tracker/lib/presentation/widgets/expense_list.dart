import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/presentation/providers/expense_provider.dart';

class ExpenseList extends ConsumerWidget {
  const ExpenseList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsyncValue = ref.watch(expensesProvider);

    return expensesAsyncValue.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return const Center(child: Text('No expenses found for this month.'));
        }
        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text(expense.description),
                subtitle: Text('${expense.date.toLocal().toString().split(' ')[0]} - ${expense.paymentMethod}'),
                trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading expenses: $error')),
    );
  }
}