import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';

class ExpenseRecord {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String categoryId; // Reference to Category ID
  final String paymentMethod;
  final String recordedBy;
  final DateTime createdAt;
  final DateTime lastModified;
  final String? notes;

  ExpenseRecord({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.paymentMethod,
    required this.recordedBy,
    required this.createdAt,
    required this.lastModified,
    this.notes,
  });

  // Factory constructor for creating an ExpenseRecord from a Google Sheet row
  factory ExpenseRecord.fromGoogleSheetRow(List<dynamic> row) {
    // Assuming the order of columns in Google Sheet is fixed:
    // ID, Date, Description, Amount, CategoryId, PaymentMethod, RecordedBy, CreatedAt, LastModified, Notes
    if (row.length < 9) { // Minimum required fields
      throw InvalidExpenseRecordDataException(
          'Missing data in Google Sheet row for expense record. Expected at least 9 columns.',
          details: row.toString());
    }

    try {
      final String id = row[0]?.toString() ?? '';
      final String dateString = row[1]?.toString() ?? '';
      final String description = row[2]?.toString() ?? '';
      final num? numValue = num.tryParse(row[3]?.toString() ?? '');
      final String categoryId = row[4]?.toString() ?? '';
      final String paymentMethod = row[5]?.toString() ?? '';
      final String recordedBy = row[6]?.toString() ?? '';
      final String createdAtString = row[7]?.toString() ?? '';
      final String lastModifiedString = row[8]?.toString() ?? '';

      if (id.isEmpty || dateString.isEmpty || description.isEmpty ||
          numValue == null ||
          categoryId.isEmpty || paymentMethod.isEmpty || recordedBy.isEmpty ||
          createdAtString.isEmpty || lastModifiedString.isEmpty) {
        throw InvalidExpenseRecordDataException(
            'One or more required fields are empty or malformed in Google Sheet row.',
            details: row.toString());
      }

      final double amount = numValue.toDouble();
      if (amount < 0) {
        throw InvalidExpenseRecordDataException(
            'Amount cannot be negative.',
            details: row.toString());
      }

      final DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);
      final DateTime createdAt = DateTime.parse(createdAtString);
      final DateTime lastModified = DateTime.parse(lastModifiedString);

      return ExpenseRecord(
        id: id,
        date: date,
        description: description,
        amount: amount,
        categoryId: categoryId.trim(),
        paymentMethod: paymentMethod,
        recordedBy: recordedBy,
        createdAt: createdAt,
        lastModified: lastModified,
        notes: row.length > 9 ? row[9]?.toString() : null,
      );
    } on FormatException catch (e) {
      throw InvalidExpenseRecordDataException(
          'Failed to parse expense record from Google Sheet row: ${e.message}',
          details: row.toString());
    } on TypeError catch (e) {
      throw InvalidExpenseRecordDataException(
          'Type error during parsing expense record from Google Sheet row: ${e
              .toString()}',
          details: row.toString());
    }
  }

  bool isValid() {
    if (id.isEmpty || description.isEmpty || categoryId.isEmpty ||
        paymentMethod.isEmpty || recordedBy.isEmpty) {
      return false;
    }
    if (amount < 0) {
      return false;
    }
    // Basic date validation (can be expanded if needed)
    if (date.isAfter(DateTime.now().add(
        const Duration(days: 1)))) { // Date cannot be in the future
      return false;
    }
    if (createdAt.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return false;
    }
    if (lastModified.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return false;
    }
    return true;
  }

  // Factory constructor for creating an ExpenseRecord from a Google Sheet row (simplified for Expense compatibility)
  factory ExpenseRecord.fromGoogleSheet(String id, List<dynamic> row) {
    // Assuming the order of columns in Google Sheet is:
    // Date, Description, Amount, CategoryId, PaymentMethod
    if (row.length < 5) {
      throw InvalidExpenseRecordDataException(
          'Missing data in Google Sheet row for simplified expense. Expected at least 5 columns.',
          details: row.toString());
    }
    final String dateString = row[0]?.toString() ?? '';
    final String description = row[1]?.toString() ?? '';
    final double? amount = double.tryParse(row[2]?.toString() ?? '');
    final String categoryId = row[3]?.toString() ?? '';
    final String paymentMethod = row[4]?.toString() ?? '';

    if (dateString.isEmpty || description.isEmpty || amount == null ||
        categoryId.isEmpty || paymentMethod.isEmpty) {
      throw InvalidExpenseRecordDataException(
          'One or more required fields are empty or malformed in simplified Google Sheet row.',
          details: row.toString());
    }

    final DateTime date = DateFormat('yyyy-MM-dd').parse(dateString);
    final now = DateTime.now();
    return ExpenseRecord(
      id: id,
      date: date,
      description: description,
      amount: amount,
      categoryId: categoryId,
      paymentMethod: paymentMethod,
      recordedBy: 'Unknown',
      // Default value
      createdAt: now,
      // Default value
      lastModified: now, // Default value
    );
  }

  // Method to convert an ExpenseRecord to a Google Sheet row format
  List<Object> toGoogleSheetRow() {
    return [
      id,
      DateFormat('yyyy-MM-dd').format(date),
      description,
      amount,
      categoryId,
      paymentMethod,
      recordedBy,
      createdAt.toIso8601String(),
      lastModified.toIso8601String(),
      notes ?? '',
    ];
  }

  // Method to convert an ExpenseRecord to a JSON format (compatible with old Expense.toJson)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Date': DateFormat('yyyy-MM-dd').format(date),
      'Description': description,
      'Amount': amount.toStringAsFixed(2),
      'CategoryId': categoryId,
      'PaymentMethod': paymentMethod,
      'RecordedBy': recordedBy,
      'CreatedAt': createdAt.toIso8601String(),
      'LastModified': lastModified.toIso8601String(),
      'Notes': notes,
    };
  }

  // Method to create a new ExpenseRecord with a generated UUID and timestamps
  static ExpenseRecord createNew({
    required DateTime date,
    required String description,
    required String categoryId,
    required double amount,
    required String paymentMethod,
    required String recordedBy,
    String? notes,
  }) {
    final now = DateTime.now();
    final uuid = Uuid();
    return ExpenseRecord(
      id: uuid.v4(),
      date: date,
      description: description,
      amount: amount,
      categoryId: categoryId,
      paymentMethod: paymentMethod,
      recordedBy: recordedBy,
      createdAt: now,
      lastModified: now,
      notes: notes,
    );
  }

  // Method to create a copy of ExpenseRecord with updated fields
  ExpenseRecord copyWith({
    String? id,
    DateTime? date,
    String? description,
    String? categoryId,
    double? amount,
    String? paymentMethod,
    String? recordedBy,
    DateTime? createdAt,
    DateTime? lastModified,
    String? notes,
  }) {
    return ExpenseRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recordedBy: recordedBy ?? this.recordedBy,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? DateTime.now(),
      // Update lastModified on copy
      notes: notes ?? this.notes,
    );
  }
}
