import 'package:bom_pastor_app/models/student_model.dart';

Student fromSheet(int index, List<dynamic> sheetRow) {
  final name = sheetRow[0] as String? ?? "";

  final score =
      (sheetRow.length > 1 && sheetRow[1] != null)
          ? int.tryParse(sheetRow[1].toString()) ?? 0
          : 0;

  Student student = Student(rowId: index, name: name, score: score);
  return student;
}

listFromSheet(List<List<dynamic>> values) {
  List<Student> students = [];

  for (int i = 0; i < values.length; i++) {
    if (i > 0) {
      final sheetRow = values[i];
      if (sheetRow.length >= 2) {
        students.add(fromSheet(i, sheetRow));
      }
    }
  }

  return students;
}
