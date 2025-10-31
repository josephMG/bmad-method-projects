import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:logging/logging.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';

final _logger = Logger('ErrorHandler');

class ErrorHandler {
  static void handleApiError(dynamic error) {
    if (error is AppException) {
      // If it's already an AppException, re-throw it directly to preserve its specific type and message.
      throw error;
    } else if (error is sheets.DetailedApiRequestError && error.status == 429) {
      _logger.warning('Rate Limit Exceeded: ${error.message}');
      throw RateLimitException('Rate limit exceeded. Please try again in a moment.');
    } else {
      _logger.severe('An unexpected error occurred: $error');
      throw AppException('An unexpected error occurred.', details: error.toString());
    }
  }
}
