import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/core/providers/rate_limit_provider.dart';
import 'package:family_expense_tracker/core/widgets/custom_snackbar.dart';
import 'package:family_expense_tracker/presentation/widgets/expense_form_dialog.dart';
import 'package:family_expense_tracker/providers/expense_provider.dart';
import 'package:family_expense_tracker/presentation/widgets/expense_list_item.dart';
import 'package:family_expense_tracker/presentation/widgets/month_navigator.dart';
import 'package:family_expense_tracker/presentation/widgets/sync_status_indicator.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';
import 'package:family_expense_tracker/presentation/pages/authentication_page.dart';
import 'package:intl/intl.dart';
import 'package:family_expense_tracker/presentation/pages/category_management_page.dart';

import '../providers/category_provider.dart' show categoryProvider;
import '../providers/connectivity_provider.dart';
import '../providers/month_provider.dart';
import '../providers/sync_status_provider.dart';

/// A page that displays the list of expenses for the current month.
///
/// This page demonstrates how to handle rate limiting by disabling UI elements
/// and showing a cooldown message to the user.
class ExpenseListPage extends ConsumerWidget {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(currentMonthProvider);
    final expensesAsyncValue = ref.watch(expenseListProvider(selectedMonth));
    final rateLimitState = ref.watch(rateLimitStateProvider);

    // ref.listen<AsyncValue<List<ExpenseRecord>>>(
    //   expenseListProvider(selectedMonth),
    //   (previous, next) {
    //     if (next.hasError && !next.isLoading) {
    //       final error = next.error;
    //       if (error is RateLimitException) {
    //         Duration cooldown = const Duration(seconds: 60); // Default
    //         if (error.details != null) {
    //           final match = RegExp(r'(\d+)').firstMatch(error.details!);
    //           if (match != null) {
    //             final seconds = int.tryParse(match.group(1) ?? '');
    //             if (seconds != null) {
    //               cooldown = Duration(seconds: seconds);
    //             }
    //           }
    //         }
    //         ref
    //             .read(rateLimitStateProvider.notifier)
    //             .setRateLimited(cooldown, error.message);
    //       }
    //     }
    //   },
    // );

    // Show snackbar if rate limited
    if (rateLimitState.isRateLimited && rateLimitState.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final remainingTime = rateLimitState.cooldownUntil != null
            ? ' (retry after ${rateLimitState.cooldownUntil!.toLocal().hour}:${rateLimitState.cooldownUntil!.toLocal().minute}:${rateLimitState.cooldownUntil!.toLocal().second})'
            : '';
                  CustomSnackBar.instance.show(
                    context,
                    '${rateLimitState.message!}$remainingTime',
                    type: MessageType.warning,
                  );      });
    }

    final bool isActionDisabled = rateLimitState.isRateLimited;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Expenses'),
        actions: [
          IconButton(
            key: const Key('categoryManagementButton'),
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementPage(),
                ),
              );
            },
          ),
          IconButton(
            key: const Key('logoutButton'),
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (!context.mounted) return;
              ref.invalidate(authRepositoryProvider);
              // Invalidate userProvider to trigger re-authentication
              // In a test environment, we might need to pump the tester here to ensure the UI rebuilds
              // before navigation, but this is not typically done in production code.
              // For now, we'll rely on the test's pumpAndSettle to catch the rebuild.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AuthenticationPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SyncStatusIndicator(), // Display sync status
          Consumer(
            builder: (context, ref, child) {
              final connectivityStatus = ref.watch(connectivityStatusProvider);
              ref.listen<AsyncValue<ConnectivityStatus>>(
                connectivityStatusProvider,
                (previous, next) {
                  next.whenOrNull(
                    data: (status) {
                      if (status == ConnectivityStatus.disconnected) {
                        ref.read(syncStatusProvider.notifier).setStatus(SyncStatus.offline);
                      } else if (ref.read(syncStatusProvider) == SyncStatus.offline) {
                        // Only set to idle if it was previously offline, otherwise maintain current sync status
                        ref.read(syncStatusProvider.notifier).setStatus(SyncStatus.idle);
                      }
                    },
                  );
                },
              );

              if (connectivityStatus.value == ConnectivityStatus.disconnected) {
                return Container(
                  width: double.infinity,
                  color: Colors.red,
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Offline',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          const MonthNavigator(), // Always display MonthNavigator
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(expenseListProvider(selectedMonth));
                ref.invalidate(categoryProvider);
              },
              child: expensesAsyncValue.when(
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No expenses recorded for this month.'),
                          if (isActionDisabled) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: null, // Disabled during cooldown
                              child: Text(
                                'Retry in ${rateLimitState.cooldownRemaining?.inSeconds ?? 0}s',
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              key: const Key('refreshExpensesButton'),
                              onPressed: () {
                                ref.invalidate(
                                  expenseListProvider(selectedMonth),
                                ); // Retry fetching
                                ref.invalidate(categoryProvider);
                              },
                              child: const Text('Refresh Expenses'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return Dismissible(
                              key: ValueKey(expense.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                if (isActionDisabled) return false;

                                final bool confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Expense'),
                                    content: const Text(
                                      'Are you sure you want to delete this expense?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ) ?? false;

                                if (confirm) {
                                  try {
                                    await ref
                                        .read(
                                          expenseListProvider(
                                            selectedMonth,
                                          ).notifier,
                                        )
                                        .deleteExpense(expense.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Expense ${expense.description} deleted'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    return true; // Allow dismissal
                                  } catch (e) {
                                    CustomSnackBar.instance.show(
                                      context,
                                      'Error: ${e.toString()}',
                                      type: MessageType.error,
                                    );
                                    return false; // Prevent dismissal
                                  }
                                } else {
                                  return false; // Prevent dismissal if not confirmed
                                }
                              },
                              onDismissed: (direction) async {
                                // No action needed here, as deletion is handled in confirmDismiss
                              },
                              child: GestureDetector(
                                onLongPress: isActionDisabled
                                    ? null
                                    : () async {
                                        await showDialog(
                                          context: context,
                                          builder: (context) {
                                            final user = ref.watch(userProvider);
                                            return user.when(
                                              data: (currentUser) => ExpenseFormDialog(
                                                expenseToEdit: expense,
                                                currentUser: currentUser!,
                                                onSave: (editedExpense) async {
                                                  await ref
                                                      .read(
                                                        expenseListProvider(
                                                          selectedMonth,
                                                        ).notifier,
                                                      )
                                                      .updateExpense(editedExpense);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Expense ${editedExpense.description} updated'),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                },
                                              ),
                                              loading: () => const Center(child: CircularProgressIndicator()),
                                              error: (error, stack) => const Center(child: Text('Error getting user')),
                                            );
                                          },
                                        );
                                      },
                                child: ExpenseListItem(expense: expense),
                              ),
                            );
                          },
                        ),
                      ),
                      _buildMonthlyTotal(ref, selectedMonth), // New widget to display total
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    CustomSnackBar.instance.show(
                      context,
                      'Error: ${error.toString()}',
                      type: MessageType.error,
                    );
                  });
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No expenses recorded for this month.'),
                        if (isActionDisabled) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: null, // Disabled during cooldown
                            child: Text(
                              'Retry in ${rateLimitState.cooldownRemaining?.inSeconds ?? 0}s',
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            key: const Key('refreshExpensesButton'),
                            onPressed: () {
                              ref.invalidate(
                                expenseListProvider(selectedMonth),
                              ); // Retry fetching
                              ref.invalidate(categoryProvider);
                            },
                            child: const Text('Refresh Expenses'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('addExpenseButton'),
        onPressed: isActionDisabled
            ? null
            : () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    final user = ref.watch(userProvider);
                    return user.when(
                      data: (currentUser) => ExpenseFormDialog(
                        currentUser: currentUser!,
                        onSave: (expense) async {
                          await ref
                              .read(expenseListProvider(selectedMonth).notifier)
                              .addExpense(expense);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Expense ${expense.description} added'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => const Center(child: Text('Error getting user')),
                    );
                  },
                );
              },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthlyTotal(WidgetRef ref, DateTime selectedMonth) {
    final monthlyTotalAsyncValue = ref.watch(monthlyTotalProvider(selectedMonth));
    final formattedTotal = monthlyTotalAsyncValue.when(
      data: (total) => NumberFormat.currency(symbol: '\$').format(total),
      loading: () => 'Calculating...', 
      error: (error, stack) => 'Error: ${error.toString()}',
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.centerRight,
      child: Text(
        'Monthly Total: $formattedTotal',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}