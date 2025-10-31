import 'dart:async';
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:family_expense_tracker/data/models/expense_record.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';

final _logger = Logger('GoogleSheetsService');

/// A service to handle low-level interactions with the Google Sheets API.
///
/// Security Considerations:
/// - Authentication: Uses Google OAuth via `AuthRepository` to ensure secure access.
///   Access tokens are handled by the `GoogleAuthClient` and are not directly exposed or stored.
/// - Authorization: Access to specific spreadsheets and operations (read/write) is governed
///   by the scopes requested during OAuth and the permissions granted to the authenticated user's Google account.
/// - Data in Transit: Communication with Google Sheets API is over HTTPS, ensuring encryption of data in transit.
/// - Data at Rest: Data security at rest is managed by Google's infrastructure.
/// - Input Validation: While this service handles low-level API calls, higher-level
///   repositories and models are responsible for validating data before it's sent to Google Sheets
///   to prevent injection or malformed data issues.
/// - Error Handling: API errors are caught and re-thrown as `GoogleSheetsApiException` or `NetworkException`,
///   preventing sensitive information leakage and providing controlled error messages.
///
/// Performance Considerations:
/// - Large Datasets: Operations like `getSheet`, `isCategoryUsed`, and `updateExpensesCategory` involve
///   iterating through potentially large datasets. Performance testing with significant amounts of data
///   is crucial to identify bottlenecks and optimize these operations.
/// - Batching: Where possible, batching requests (e.g., `batchUpdate`) is used to minimize API call overhead.
/// - Caching: Client-side caching of frequently accessed data (e.g., sheet names, categories) can reduce
///   API calls and improve responsiveness.
class GoogleSheetsService {
  final AuthRepository _authRepository;
  final String spreadsheetId;
  sheets.SheetsApi? _sheetsApi;

  // Private constructor for dependency injection
  GoogleSheetsService(this._authRepository, this.spreadsheetId, {sheets.SheetsApi? sheetsApi})
      : _sheetsApi = sheetsApi;

  // Factory constructor for production use, loading spreadsheetId from environment or config
  factory GoogleSheetsService.create(AuthRepository authRepository, {String? customSpreadsheetId}) {
    // In a real app, you'd load this from an environment variable or config file
    // For now, we'll keep a default for convenience, but allow override
    const defaultSpreadsheetId = '1GjmoTHeiGntl2smfdqeiMzBA7X1lU8FfV_oHvxs5UWI';
    final spreadsheetId = customSpreadsheetId ?? defaultSpreadsheetId;
    return GoogleSheetsService(authRepository, spreadsheetId);
  }

  void clearCachedApi() {
    _sheetsApi = null;
  }

  Future<T> _handleApiCall<T>(Future<T> Function() apiCall, {int maxRetries = 3, int currentRetry = 0}) async {
    try {
      return await apiCall();
    } on sheets.DetailedApiRequestError catch (e) {
      _logger.severe('Google Sheets API error: ${e.message}', e);
      // Implement retry logic for transient API errors
      if (e.status == 429 || (e.status != null && e.status! >= 500 && e.status! < 600)) {
        if (currentRetry < maxRetries) {
          final delay = Duration(seconds: 1 << currentRetry); // Exponential backoff
          _logger.info('Retrying API call in ${delay.inSeconds} seconds (retry ${currentRetry + 1}/$maxRetries) for error: ${e.message}');
          await Future.delayed(delay);
          return _handleApiCall(apiCall, maxRetries: maxRetries, currentRetry: currentRetry + 1);
        }
      }
      throw GoogleSheetsApiException(e.message ?? 'An unknown Google Sheets API error occurred', details: e.toString());
    } on Exception catch (e) {
      _logger.severe('Network or unexpected error during API call: ${e.toString()}', e);
      // Implement retry logic for network errors
      if (currentRetry < maxRetries) {
        final delay = Duration(seconds: 1 << currentRetry); // Exponential backoff
        _logger.info('Retrying API call in ${delay.inSeconds} seconds (retry ${currentRetry + 1}/$maxRetries) for network error: ${e.toString()}');
        await Future.delayed(delay);
        return _handleApiCall(apiCall, maxRetries: maxRetries, currentRetry: currentRetry + 1);
      }
      throw NetworkException('A network error occurred or an unexpected error during API call', details: e.toString());
    }
  }

  Future<sheets.SheetsApi> _getSheetsApi() async {
    if (_sheetsApi != null) {
      return _sheetsApi!;
    }

    final googleSignIn = _authRepository.getGoogleSignInInstance();
    final GoogleSignInAccount? user = googleSignIn.currentUser;

    if (user == null) {
      throw UnauthorizedException('No Google user signed in.');
    }

    final GoogleSignInAuthentication googleAuth = await user.authentication;
    final client = GoogleAuthClient(googleAuth.accessToken!, googleAuth.idToken!);

    _sheetsApi = sheets.SheetsApi(client);
    return _sheetsApi!;
  }

  /// Fetches all rows from a given sheet.
  Future<List<List<dynamic>>?> getSheet(String sheetName) async {
    final sheetsApi = await _getSheetsApi();

    final stopwatch = Stopwatch()..start();
    final result = await _handleApiCall(() => sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      sheetName,
    ));
    stopwatch.stop();
    _logger.info(
        'getSheet for $sheetName took ${stopwatch.elapsedMilliseconds} ms');

    return result.values;
  }

  /// Finds the 0-based row index of an expense record by its RecordID.
  /// Returns null if not found.
  Future<int?> findExpenseRowIndex(String sheetName, String recordID) async {
    final sheetsApi = await _getSheetsApi();
    final values = await getSheet(sheetName);

    if (values == null || values.isEmpty) {
      return null;
    }

    // Start from row 1 (index 1) assuming row 0 is header
    for (int i = 1; i < values.length; i++) {
      if (values[i].isNotEmpty && values[i][0].toString() == recordID) {
        return i; // Return 0-based index
      }
    }
    return null;
  }

  /// Updates an existing expense record in the specified monthly sheet.
  Future<void> updateExpense(String sheetName, ExpenseRecord expense) async {
    final sheetsApi = await _getSheetsApi();
    final rowIndex = await findExpenseRowIndex(sheetName, expense.id);

    if (rowIndex == null) {
      _logger.warning('Expense with RecordID ${expense.id} not found in $sheetName for update.');
      throw GoogleSheetsApiException('Expense not found for update');
    }

    // Google Sheets API uses 1-based indexing for rows in A1 notation
    // and the range should be for the specific row to update.
    final range = '${sheetName}!A${rowIndex + 1}';

    final stopwatch = Stopwatch()..start();
    await _handleApiCall(() => sheetsApi.spreadsheets.values.update(
      sheets.ValueRange(values: [expense.toGoogleSheetRow()]),
      spreadsheetId,
      range,
      valueInputOption: 'USER_ENTERED',
    ));
    stopwatch.stop();
    _logger.info(
        'updateExpense in $sheetName took ${stopwatch.elapsedMilliseconds} ms');
  }

  /// Deletes an expense record from the specified monthly sheet.
  Future<void> deleteExpense(String sheetName, String recordID) async {
    final sheetsApi = await _getSheetsApi();
    final rowIndex = await findExpenseRowIndex(sheetName, recordID);

    if (rowIndex == null) {
      _logger.warning('Expense with RecordID $recordID not found in $sheetName for deletion.');
      throw GoogleSheetsApiException('Expense not found for deletion');
    }

    // The deleteDimension request uses 0-based indexing for startIndex and endIndex.
    // To delete a single row, startIndex is the row index, and endIndex is rowIndex + 1.
    final request = sheets.BatchUpdateSpreadsheetRequest(
      requests: [
        sheets.Request(
          deleteDimension: sheets.DeleteDimensionRequest(
            range: sheets.DimensionRange(
              sheetId: await getSheetId(sheetName), // Get the sheetId dynamically
              dimension: 'ROWS',
              startIndex: rowIndex,
              endIndex: rowIndex + 1,
            ),
          ),
        ),
      ],
    );

    final stopwatch = Stopwatch()..start();
    await _handleApiCall(() => sheetsApi.spreadsheets.batchUpdate(request, spreadsheetId));
    stopwatch.stop();
    _logger.info(
        'deleteExpense with RecordID $recordID from $sheetName took ${stopwatch.elapsedMilliseconds} ms');
  }

  /// Checks if a sheet (tab) with the given name exists.
  Future<bool> sheetExists(String sheetName) async {
    final stopwatch = Stopwatch()..start();
    final sheetId = await getSheetId(sheetName);
    stopwatch.stop();
    _logger.info(
        'sheetExists for $sheetName took ${stopwatch.elapsedMilliseconds} ms');
    return sheetId != null;
  }

  /// Retrieves a list of all sheet names (tabs) in the spreadsheet.
  Future<List<String>> getAllSheetNames() async {
    final sheetsApi = await _getSheetsApi();

    final stopwatch = Stopwatch()..start();
    final spreadsheet = await _handleApiCall(() => sheetsApi.spreadsheets.get(spreadsheetId));
    stopwatch.stop();
    _logger.info(
        'getAllSheetNames took ${stopwatch.elapsedMilliseconds} ms');

    return spreadsheet.sheets
            ?.map((s) => s.properties?.title)
            .whereType<String>()
            .toList() ??
        [];
  }

  /// Checks if a given category ID is used in any expense record across all monthly sheets.
  Future<bool> isCategoryUsed(String categoryId, List<String> allSheetNames) async {
    final stopwatch = Stopwatch()..start();

    // Filter out non-monthly sheets (e.g., 'Category' sheet)
    final monthlySheets = allSheetNames.where((name) => RegExp(r'^\d{4}-\d{2}$').hasMatch(name));

    for (final sheetName in monthlySheets) {
      final sheetData = await getSheet(sheetName);
      if (sheetData != null && sheetData.length > 1) { // Skip header row
        for (int i = 1; i < sheetData.length; i++) {
          try {
            final expense = ExpenseRecord.fromGoogleSheetRow(sheetData[i]);
            _logger.info('Checking expense ${expense.id}: categoryId=${expense.categoryId}, targetCategoryId=$categoryId');
            if (expense.categoryId == categoryId) {
              _logger.info('Category $categoryId found in use in sheet $sheetName.');
              stopwatch.stop();
              return true;
            }
          } catch (e) {
            _logger.warning('Skipping malformed expense record in $sheetName: ${sheetData[i]} - $e');
            // Continue to next row if a record is malformed
          }
        }
      }
    }

    stopwatch.stop();
    _logger.info('Category $categoryId not found in use. Took ${stopwatch.elapsedMilliseconds} ms');
    return false;
  }

  /// Updates the category of all expense records from oldCategoryId to newCategoryId.
  Future<void> updateExpensesCategory(String oldCategoryId, String newCategoryId, List<String> allSheetNames) async {
    final sheetsApi = await _getSheetsApi();
    final monthlySheets = allSheetNames.where((name) =>
        RegExp(r'^\d{4}-\d{2}$').hasMatch(name));

    final List<sheets.Request> requests = [];

    for (final sheetName in monthlySheets) {
      final sheetData = await getSheet(sheetName);
      if (sheetData != null && sheetData.length > 1) {
        for (int i = 1; i < sheetData.length; i++) {
          try {
            final expense = ExpenseRecord.fromGoogleSheetRow(sheetData[i]);
            if (expense.categoryId == oldCategoryId) {
              // Create a new ExpenseRecord with the updated categoryId
              final updatedExpense = expense.copyWith(
                  categoryId: newCategoryId);

              // Get the 0-based row index for the update
              final rowIndex = i;

              // Google Sheets API uses 1-based indexing for rows in A1 notation
              // and the range should be for the specific cell to update.
              // Assuming categoryId is at a specific column, e.g., column C (index 2)
              // This needs to be dynamic based on ExpenseRecord.toGoogleSheetRow() structure
              // For now, let's assume categoryId is at column 3 (index 2) in the sheet
              // This is a simplification and might need adjustment based on actual sheet structure.
              final range = '${sheetName}!C${rowIndex +
                  1}'; // Assuming category is in column C

              requests.add(
                sheets.Request(
                  updateCells: sheets.UpdateCellsRequest(
                    rows: [
                      sheets.RowData(
                        values: [
                          sheets.CellData(
                              userEnteredValue: sheets.ExtendedValue(
                                  stringValue: newCategoryId)),
                        ],
                      ),
                    ],
                    fields: 'userEnteredValue',
                    range: sheets.GridRange(
                      sheetId: await getSheetId(sheetName),
                      startRowIndex: rowIndex,
                      endRowIndex: rowIndex + 1,
                      startColumnIndex: 4,
                      // CategoryId is at column index 4 (E)
                      endColumnIndex: 5,
                    ),
                  ),
                ),
              );
            }
          } catch (e) {
            _logger.warning(
                'Skipping malformed expense record in $sheetName: ${sheetData[i]} - $e');
          }
        }
      }
    }

    if (requests.isNotEmpty) {
      print('Calling batchUpdate with ${requests.length} requests.');
      await batchUpdate(requests);
      _logger.info('Updated category for ${requests.length} expenses from $oldCategoryId to $newCategoryId.');
    }
  }

  Future<int?> getSheetId(String sheetName) async {
    final sheetsApi = await _getSheetsApi();
    final spreadsheet =
    await _handleApiCall(() => sheetsApi.spreadsheets.get(spreadsheetId));
    final sheet = spreadsheet.sheets
        ?.firstWhere((s) => s.properties?.title == sheetName);
    return sheet?.properties?.sheetId;
  }

  Future<void> batchUpdate(List<sheets.Request> requests) async {
    final sheetsApi = await _getSheetsApi();
    final request = sheets.BatchUpdateSpreadsheetRequest(requests: requests);
    await _handleApiCall(
            () => sheetsApi.spreadsheets.batchUpdate(request, spreadsheetId));
  }

  Future<void> addExpense(String sheetName, ExpenseRecord testExpense) async {
    final sheetsApi = await _getSheetsApi();
    await _handleApiCall(() => sheetsApi.spreadsheets.values.append(
      sheets.ValueRange(values: [testExpense.toGoogleSheetRow()]),
      spreadsheetId,
      sheetName,
      valueInputOption: 'USER_ENTERED',
    ));
  }

  Future<void> createSheet(String sheetName) async {
    final sheetsApi = await _getSheetsApi();
    final request = sheets.BatchUpdateSpreadsheetRequest(
      requests: [
        sheets.Request(
          addSheet: sheets.AddSheetRequest(
            properties: sheets.SheetProperties(title: sheetName),
          ),
        ),
      ],
    );
    await _handleApiCall(
        () => sheetsApi.spreadsheets.batchUpdate(request, spreadsheetId));
  }

  Future<void> deleteRow(int sheetId, int rowIndex) async {
    final sheetsApi = await _getSheetsApi();
    final request = sheets.BatchUpdateSpreadsheetRequest(
      requests: [
        sheets.Request(
          deleteDimension: sheets.DeleteDimensionRequest(
            range: sheets.DimensionRange(
              sheetId: sheetId,
              dimension: 'ROWS',
              startIndex: rowIndex,
              endIndex: rowIndex + 1,
            ),
          ),
        ),
      ],
    );
    await _handleApiCall(
        () => sheetsApi.spreadsheets.batchUpdate(request, spreadsheetId));
  }

  Future<void> updateRow(String sheetName, int rowIndex, List<dynamic> values) async {
    final sheetsApi = await _getSheetsApi();
    final range = '${sheetName}!A${rowIndex + 1}'; // rowIndex is 0-based

    await _handleApiCall(() => sheetsApi.spreadsheets.values.update(
      sheets.ValueRange(values: [values]),
      spreadsheetId,
      range,
      valueInputOption: 'USER_ENTERED',
    ));
  }

  Future<void> appendSheet(String sheetName, List<List<dynamic>> values) async {
    final sheetsApi = await _getSheetsApi();
    await _handleApiCall(() => sheetsApi.spreadsheets.values.append(
      sheets.ValueRange(values: values),
      spreadsheetId,
      sheetName,
      valueInputOption: 'USER_ENTERED',
    ));
  }

  Future<void> updateSheet(String range, List<List<dynamic>> values) async {
    final sheetsApi = await _getSheetsApi();
    await _handleApiCall(() => sheetsApi.spreadsheets.values.update(
      sheets.ValueRange(values: values),
      spreadsheetId,
      range,
      valueInputOption: 'USER_ENTERED',
    ));
  }
}

class GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final String _idToken;
  final http.Client _inner;

  GoogleAuthClient(this._accessToken, this._idToken, {http.Client? inner})
      : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    // Optionally add ID token if needed by the API
    // request.headers['X-Identity-Token'] = _idToken;
    return _inner.send(request);
  }
}

final googleSheetsServiceProvider = Provider<GoogleSheetsService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GoogleSheetsService.create(authRepository);
});