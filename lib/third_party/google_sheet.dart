import 'package:bom_pastor_app/config/sheet_config.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;

import 'package:bom_pastor_app/io/get_assets_file_content.dart';

Future<sheets.SheetsApi> _getGoogleSheetClient() async {
  final credentials = await getAssetsFileContent("credentials.json");

  final authHeaders = await clientViaServiceAccount(
    ServiceAccountCredentials.fromJson(credentials),
    [sheets.SheetsApi.spreadsheetsScope],
  );

  final client = authHeaders;
  final sheetsApi = sheets.SheetsApi(client);

  return sheetsApi;
}

Future<List<List<String>>> readGoogleSheetData(
  String sheetId,
  String sheetName,
) async {
  try {
    final sheetsApi = await _getGoogleSheetClient();

    final spreadsheet = await sheetsApi.spreadsheets.values.get(
      sheetId,
      sheetName,
    );

    final values = spreadsheet.values;

    if (values == null) {
      return [];
    }

    return values
        .map((row) => row.map((cell) => cell.toString()).toList())
        .toList();
  } catch (e) {
    print("Falha ao carregar dados da planilha $e");
    rethrow;
  }
}

Future<void> addGoogleSheetData(
  List<dynamic> payload,
  String sheetId,
  String sheetName,
) async {
  try {
    final sheetsApi = await _getGoogleSheetClient();

    final rowData = [payload];
    final valueRange = sheets.ValueRange(values: rowData);

    final result = await sheetsApi.spreadsheets.values.append(
      valueRange,
      sheetId,
      sheetName,
      valueInputOption: "USER_ENTERED",
    );

    if (result.updates?.updatedColumns != payload.length) {
      print("Error: Could not add data to sheet. ${result.updates?.toJson()}");
      throw Exception("Failed to add data to sheet.");
    }
  } catch (e) {
    print("Failed to add data to sheet: $e");
    rethrow;
  }
}

Future<void> updateGoogleSheetRow(
  List<dynamic> rowData,
  int rowNumber,
  String sheetId,
  String sheetName,
) async {
  try {
    final sheetsApi = await _getGoogleSheetClient();

    // Calculate the range for the specified row.
    // Assuming you want to update the entire row, we use a range like "Sheet1!A2:Z2" for row 2.
    final range = '$sheetName!A$rowNumber'; // Update from the first column

    final valueRange = sheets.ValueRange(values: [rowData]);

    final result = await sheetsApi.spreadsheets.values.update(
      valueRange,
      sheetId,
      range,
      valueInputOption: "USER_ENTERED",
    );

    // Verify the update was successful (at least one cell in the row was updated)
    if (result.updatedCells == 0) {
      throw Exception("Failed to update row $rowNumber in sheet.");
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> deleteGoogleSheetRow(
  int rowNumber,
  String sheetId,
  String sheetName,
) async {
  try {
    final sheetsApi = await _getGoogleSheetClient();

    // Get the spreadsheet metadata to find the sheet ID.
    final spreadsheet = await sheetsApi.spreadsheets.get(
      SheetConfig.spreadSheetId,
    );

    print("sheets ${spreadsheet.sheets}");
    print("rowNumber ${rowNumber}");

    final sheet = spreadsheet.sheets?.firstWhere(
      (s) => s.properties?.title == sheetName,
    );
    final sheetId = sheet?.properties?.sheetId;

    if (sheetId == null) {
      throw Exception("Sheet '$sheetName' not found in spreadsheet.");
    }

    final deleteRange = sheets.DimensionRange(
      dimension: "ROWS",
      sheetId: sheetId,
      startIndex: rowNumber,
      endIndex: rowNumber + 1,
    );

    // Create a DeleteDimensionRequest to delete rows.
    final request = sheets.DeleteDimensionRequest(range: deleteRange);

    // Build the request body with the DeleteDimensionRequest.
    final batchUpdateSpreadsheetRequest = sheets.BatchUpdateSpreadsheetRequest(
      requests: [sheets.Request(deleteDimension: request)],
    );

    // Execute the request.
    await sheetsApi.spreadsheets.batchUpdate(
      batchUpdateSpreadsheetRequest,
      SheetConfig.spreadSheetId,
    );
  } catch (e) {
    print("Failed to delete row $rowNumber from sheet: $e");
    rethrow;
  }
}
