import 'package:flutter_test/flutter_test.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';

void main() {
  group('ExpenseRecord', () {
    final now = DateTime.now();
    final testExpense = ExpenseRecord(
      id: 'test-uuid-123',
      date: DateTime(2023, 10, 26),
      description: 'Groceries',
      categoryId: 'Food',
      amount: 50.0,
      paymentMethod: 'Cash',
      recordedBy: 'user@example.com',
      createdAt: now,
      lastModified: now,
      notes: 'Weekly shopping',
    );

    test('ExpenseRecord.createNew should generate a UUID and timestamps', () {
      final newExpense = ExpenseRecord.createNew(
        date: DateTime(2023, 10, 27),
        description: 'Dinner',
        categoryId: 'Food',
        amount: 30.0,
        paymentMethod: 'Credit Card',
        recordedBy: 'new_user@example.com',
      );

      expect(newExpense.id, isNotNull);
      expect(newExpense.id.length, greaterThan(0)); // UUIDs are typically 36 chars, but just check non-empty
      expect(newExpense.createdAt, isNotNull);
      expect(newExpense.lastModified, isNotNull);
      expect(newExpense.createdAt, newExpense.lastModified);
    });

    test('toGoogleSheetRow should return a list of objects in correct order', () {
      final row = testExpense.toGoogleSheetRow();

      expect(row[0], testExpense.id);
      expect(row[1], '2023-10-26'); // Formatted date
      expect(row[2], testExpense.description);
      expect(row[3], testExpense.amount);
      expect(row[4], testExpense.categoryId);
      expect(row[5], testExpense.paymentMethod);
      expect(row[6], testExpense.recordedBy);
      expect(row[7], testExpense.createdAt.toIso8601String());
      expect(row[8], testExpense.lastModified.toIso8601String());
      expect(row[9], testExpense.notes);
    });

    test('fromGoogleSheetRow should parse a list of dynamic to ExpenseRecord', () {
      final googleSheetRow = [
        'test-uuid-456',
        '2023-11-01',
        'Coffee',
        10.50,
        'Beverages',
        'Cash',
        'another_user@example.com',
        now.toIso8601String(),
        now.toIso8601String(),
        'Morning coffee',
      ];

      final parsedExpense = ExpenseRecord.fromGoogleSheetRow(googleSheetRow);

      expect(parsedExpense.id, 'test-uuid-456');
      expect(parsedExpense.date, DateTime(2023, 11, 01));
      expect(parsedExpense.description, 'Coffee');
      expect(parsedExpense.categoryId, 'Beverages');
      expect(parsedExpense.amount, 10.50);
      expect(parsedExpense.paymentMethod, 'Cash');
      expect(parsedExpense.recordedBy, 'another_user@example.com');
      expect(parsedExpense.createdAt.toIso8601String(), now.toIso8601String());
      expect(parsedExpense.lastModified.toIso8601String(), now.toIso8601String());
      expect(parsedExpense.notes, 'Morning coffee');
    });

    test('copyWith should create a new instance with updated values', () {
      final updatedExpense = testExpense.copyWith(
        description: 'New Groceries',
        amount: 60.0,
      );

      expect(updatedExpense.id, testExpense.id);
      expect(updatedExpense.description, 'New Groceries');
      expect(updatedExpense.amount, 60.0);
      expect(updatedExpense.lastModified, isNot(testExpense.lastModified)); // lastModified should be updated
    });

    test('fromGoogleSheetRow should throw InvalidExpenseRecordDataException for invalid date format', () {
      final invalidRow = [
        'test-uuid-789',
        'invalid-date',
        'Books',
        'Education',
        25.0,
        'Cash',
        'user@example.com',
        now.toIso8601String(),
        now.toIso8601String(),
        'New book',
      ];
      expect(() => ExpenseRecord.fromGoogleSheetRow(invalidRow),
          throwsA(isA<InvalidExpenseRecordDataException>()));
    });

    test('fromGoogleSheetRow should throw InvalidExpenseRecordDataException for invalid amount format', () {
      final invalidRow = [
        'test-uuid-101',
        '2023-12-01',
        'Movie',
        'Entertainment',
        'not-a-number',
        'Credit Card',
        'user@example.com',
        now.toIso8601String(),
        now.toIso8601String(),
        'Evening movie',
      ];
      expect(() => ExpenseRecord.fromGoogleSheetRow(invalidRow),
          throwsA(isA<InvalidExpenseRecordDataException>()));
    });

    test('fromGoogleSheetRow should throw InvalidExpenseRecordDataException for missing fields', () {
      final invalidRow = [
        'test-uuid-102',
        '2023-12-02',
        'Lunch',
        'Food',
        15.0,
        'Cash',
        'user@example.com',
        now.toIso8601String(),
        // Missing lastModified and notes
      ];
      expect(() => ExpenseRecord.fromGoogleSheetRow(invalidRow),
          throwsA(isA<InvalidExpenseRecordDataException>()));
    });

    test('fromGoogleSheetRow should throw InvalidExpenseRecordDataException for negative amount', () {
      final invalidRow = [
        'test-uuid-101',
        '2023-12-01',
        'Movie',
        'Entertainment',
        -10.0, // Negative amount
        'Credit Card',
        'user@example.com',
        now.toIso8601String(),
        now.toIso8601String(),
        'Evening movie',
      ];
      expect(() => ExpenseRecord.fromGoogleSheetRow(invalidRow),
          throwsA(isA<InvalidExpenseRecordDataException>()));
    });
  });
}
