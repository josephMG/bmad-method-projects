class AppException implements Exception {
  final String message;
  final String? details;

  AppException(this.message, {this.details});

  @override
  String toString() {
    return '${this.runtimeType.toString()}: $message${details != null ? ' ($details)' : ''}';
  }
}

class RateLimitException extends AppException {
  RateLimitException(super.message, {super.details});
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, {super.details});
}

class InvalidExpenseRecordDataException extends AppException {
  InvalidExpenseRecordDataException(super.message, {super.details});
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.details});
}

class GoogleSheetsApiException extends AppException {
  GoogleSheetsApiException(super.message, {super.details});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.details});
}

class CategoryInUseException extends AppException {
  CategoryInUseException(super.message, {super.details});
}
