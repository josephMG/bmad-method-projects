import 'package:flutter/material.dart';

enum MessageType {
  info,
  success,
  error,
  warning,
}

class CustomSnackBar {
  // Private constructor to prevent direct instantiation
  CustomSnackBar._();

  // Static instance for singleton pattern
  static CustomSnackBar _instance = CustomSnackBar._();

  // Getter to access the singleton instance
  static CustomSnackBar get instance => _instance;

  // Method to set a custom instance for testing
  @visibleForTesting
  static void setInstance(CustomSnackBar customInstance) {
    _instance = customInstance;
  }

  void show(BuildContext context, String message, {MessageType type = MessageType.info}) {
    Color backgroundColor;
    switch (type) {
      case MessageType.success:
        backgroundColor = Colors.green;
        break;
      case MessageType.error:
        backgroundColor = Colors.red;
        break;
      case MessageType.warning:
        backgroundColor = Colors.orange;
        break;
      case MessageType.info:
      default:
        backgroundColor = Colors.blueGrey;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
