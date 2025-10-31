import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/presentation/providers/category_provider.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';

import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';

class ExpenseFormDialog extends ConsumerStatefulWidget {
  final ExpenseRecord? expenseToEdit;
  final Function(ExpenseRecord expense) onSave;
  final User currentUser;

  const ExpenseFormDialog({super.key, this.expenseToEdit, required this.onSave, required this.currentUser});

  @override
  ConsumerState<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends ConsumerState<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TextEditingController _nameController;
  String? _selectedCategory; // Placeholder for category selection
  late TextEditingController _amountController;
  late TextEditingController _paymentMethodController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.expenseToEdit?.date ?? DateTime.now();
    _nameController = TextEditingController(text: widget.expenseToEdit?.description);
    _selectedCategory = widget.expenseToEdit?.categoryId; // Pre-populate category
    _amountController = TextEditingController(text: widget.expenseToEdit?.amount.toString());
    _paymentMethodController = TextEditingController(text: widget.expenseToEdit?.paymentMethod);
    _notesController = TextEditingController(text: widget.expenseToEdit?.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _paymentMethodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final ExpenseRecord expense;
        if (widget.expenseToEdit == null) {
                expense = ExpenseRecord.createNew(
                  date: _selectedDate,
                          description: _nameController.text,
                          categoryId: _selectedCategory!,
                          amount: double.parse(_amountController.text),
                  paymentMethod: _paymentMethodController.text,
                  recordedBy: widget.currentUser.email!,
                  notes: _notesController.text.isEmpty ? null : _notesController.text,
                );        } else {
      expense = widget.expenseToEdit!.copyWith(
        date: _selectedDate,
        description: _nameController.text,
        categoryId: _selectedCategory!,
        amount: double.parse(_amountController.text),
        paymentMethod: _paymentMethodController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
        }
        await widget.onSave(expense);
        Navigator.of(context).pop();
      } on ValidationException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Validation Error: ${e.message}')),
        );
      } on NetworkException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network Error: ${e.message}. Please check your connection.')),
        );
      } on GoogleSheetsApiException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sheets API Error: ${e.message}')),
        );
      } on UnauthorizedException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication Error: ${e.message}. Please re-authenticate.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save expense: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expenseToEdit == null ? 'Add New Expense' : 'Edit Expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                key: const Key('descriptionField'),
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              // Category selection
              Consumer(
                builder: (context, ref, child) {
                  final categoriesAsyncValue = ref.watch(categoriesProvider);

                  return categoriesAsyncValue.when(
                    data: (categories) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category'),
                        items: categories.map((category) {
                          return DropdownMenuItem(value: category.categoryName, child: Text(category.categoryName));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => Text('Error loading categories: $err'),
                  );
                },
              ),
              TextFormField(
                key: const Key('amountField'),
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
              TextFormField(
                key: const Key('paymentMethodField'),
                controller: _paymentMethodController,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a payment method';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          key: const Key('saveButton'),
          onPressed: _submitForm,
          child: Text(widget.expenseToEdit == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }
}
