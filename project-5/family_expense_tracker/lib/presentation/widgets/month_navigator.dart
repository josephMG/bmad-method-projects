import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:family_expense_tracker/presentation/providers/month_provider.dart';

class MonthNavigator extends ConsumerWidget {
  const MonthNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(currentMonthProvider);
    final currentMonthNotifier = ref.read(currentMonthProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () => currentMonthNotifier.goToPreviousMonth(),
        ),
        TextButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedMonth,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              initialDatePickerMode: DatePickerMode.day,
            );
            if (picked != null && (picked.year != selectedMonth.year || picked.month != selectedMonth.month)) {
              currentMonthNotifier.goToMonth(picked); // Need to implement goToMonth
            }
          },
          child: Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () => currentMonthNotifier.goToNextMonth(),
        ),
      ],
    );
  }
}
