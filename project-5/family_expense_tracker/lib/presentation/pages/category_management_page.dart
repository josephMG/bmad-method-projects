import 'package:flutter/material.dart';
import 'package:family_expense_tracker/presentation/widgets/category_list.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
      ),
      body: const CategoryList(),
    );
  }
}
