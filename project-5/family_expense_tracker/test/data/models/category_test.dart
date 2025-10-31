import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:family_expense_tracker/data/models/category.dart';

void main() {
  group('Category', () {
    test('fromGoogleSheet creates a Category object correctly', () {
      final row = ['Food', '#FF0000', 'true'];
      final category = Category.fromGoogleSheet('1', row);

      expect(category.id, '1');
      expect(category.categoryName, 'Food');
      expect(category.colorCode, const Color(0xFFFF0000));
      expect(category.isActive, true);
    });

    test('fromGoogleSheet handles 8-digit hex color codes correctly', () {
      final row = ['Travel', '#88FF0000', 'false'];
      final category = Category.fromGoogleSheet('2', row);

      expect(category.id, '2');
      expect(category.categoryName, 'Travel');
      expect(category.colorCode, const Color(0x88FF0000));
      expect(category.isActive, false);
    });

    test('fromGoogleSheet defaults isActive to true if not provided', () {
      final row = ['Shopping', '#0000FF'];
      final category = Category.fromGoogleSheet('3', row);

      expect(category.id, '3');
      expect(category.categoryName, 'Shopping');
      expect(category.colorCode, const Color(0xFF0000FF));
      expect(category.isActive, true);
    });

    test('fromGoogleSheet throws FormatException for empty CategoryName', () {
      final row = ['', '#FF0000', 'true'];
      expect(() => Category.fromGoogleSheet('4', row), throwsA(isA<FormatException>()));
    });

    test('fromGoogleSheet throws FormatException for invalid hex ColorCode', () {
      final row = ['Food', '#INVALID', 'true'];
      expect(() => Category.fromGoogleSheet('5', row), throwsA(isA<FormatException>()));
    });

    test('toJson converts a Category object to JSON correctly', () {
      final category = Category(
        id: '1',
        categoryName: 'Food',
        colorCode: const Color(0xFFFF0000),
        isActive: true,
      );
      final json = category.toJson();

      expect(json['id'], '1');
      expect(json['CategoryName'], 'Food');
      expect(json['ColorCode'], '#FF0000');
      expect(json['IsActive'], 'true');
    });

    test('toJson converts a Category object with 8-digit hex to JSON correctly', () {
      final category = Category(
        id: '2',
        categoryName: 'Travel',
        colorCode: const Color(0x88FF0000),
        isActive: false,
      );
      final json = category.toJson();

      expect(json['id'], '2');
      expect(json['CategoryName'], 'Travel');
      expect(json['ColorCode'], '#88FF0000');
      expect(json['IsActive'], 'false');
    });

    test('isValid returns true for a valid category', () {
      final category = Category(
        id: '1',
        categoryName: 'Food',
        colorCode: const Color(0xFFFF0000),
        isActive: true,
      );
      expect(category.isValid(), isTrue);
    });

    test('isValid returns false for an empty id', () {
      final category = Category(
        id: '',
        categoryName: 'Food',
        colorCode: const Color(0xFFFF0000),
        isActive: true,
      );
      expect(category.isValid(), isFalse);
    });

    test('isValid returns false for an empty categoryName', () {
      final category = Category(
        id: '1',
        categoryName: '',
        colorCode: const Color(0xFFFF0000),
        isActive: true,
      );
      expect(category.isValid(), isFalse);
    });
  });
}