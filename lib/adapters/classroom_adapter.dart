import 'package:bom_pastor_app/models/classroom_model.dart';

ClassRoom fromSheet(int index, List<dynamic> sheetRow) {
  final code = sheetRow[0] as String? ?? "";
  final name = sheetRow[1] as String? ?? "";
  final spreadSheetName = sheetRow[2] as String? ?? "";

  ClassRoom classroom = ClassRoom(
    rowId: index,
    code: code,
    name: name,
    spreadSheetName: spreadSheetName,
  );
  return classroom;
}

listFromSheet(List<List<dynamic>> values) {
  List<ClassRoom> classrooms = [];

  for (int i = 0; i < values.length; i++) {
    if (i > 0) {
      final sheetRow = values[i];
      if (sheetRow.length >= 3) {
        classrooms.add(fromSheet(i, sheetRow));
      }
    }
  }

  return classrooms;
}
