
import 'package:mockito/annotations.dart';
import 'package:family_expense_tracker/services/google_sheets_service.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

@GenerateMocks([GoogleSheetsService, sheets.SheetsApi, sheets.SpreadsheetsResource, sheets.SpreadsheetsValuesResource])
void main() {}
