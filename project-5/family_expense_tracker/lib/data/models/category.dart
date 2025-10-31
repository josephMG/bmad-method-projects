// ignore_for_file: deprecated_member_use
// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';

class Category {
  final String id;
  final String categoryName;
  final Color colorCode;
  final bool isActive;

  Category({
    required this.id,
    required this.categoryName,
    required this.colorCode,
    this.isActive = true,
  });

  factory Category.fromGoogleSheet(String id, List<dynamic> row) {
    if (row.length < 2) { // Minimum required fields: categoryName, colorCode
      throw FormatException(
          'Missing data in Google Sheet row for category. Expected at least 2 columns.');
    }

    final String categoryName = row[0]?.toString() ?? '';
    final String hexColor = row[1]?.toString() ?? '';

    if (categoryName.isEmpty) {
      throw FormatException('CategoryName cannot be empty or null');
    }
    if (hexColor.isEmpty) {
      throw FormatException('ColorCode cannot be empty or null');
    }

    final Color color = _colorFromHex(hexColor);

    // Assuming isActive is the third column, default to true if not present or invalid
    final bool isActive = row.length > 2 ? (row[2]?.toString().toLowerCase() == 'true') : true;

    return Category(
      id: id,
      categoryName: categoryName,
      colorCode: color,
      isActive: isActive,
    );
  }

  bool isValid() {
    if (id.isEmpty || categoryName.isEmpty) {
      return false;
    }
    // Basic color validation (can be expanded if needed)
    try {
      _colorFromHex(colorCode.value.toRadixString(16));
    } catch (e) {
      return false;
    }
    return true;
  }
  Map<String, dynamic> toJson() {
    String hexColor;
    if (colorCode.alpha == 255) { // Fully opaque
      hexColor = colorCode.value.toRadixString(16).substring(2).toUpperCase(); // Remove FF
    } else {
      hexColor = colorCode.value.toRadixString(16).toUpperCase(); // Keep full ARGB
    }
    return {
      'id': id,
      'CategoryName': categoryName,
      'ColorCode': '#$hexColor',
      'IsActive': isActive.toString(),
    };
  }

  static Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (!RegExp(r'^[0-9A-F]{6}').hasMatch(hexColor) && !RegExp(r'^[0-9A-F]{8}').hasMatch(hexColor)) {
      throw FormatException('Invalid hex color format: $hexColor');
    }
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor; // Add FF for opacity if not present
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  List<String> toGoogleSheetRow() {
    return [
      categoryName,
      '#${colorCode.value.toRadixString(16).substring(2).toUpperCase()}',
      isActive.toString(),
    ];
  }
}