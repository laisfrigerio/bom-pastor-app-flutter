import 'package:myapp/models/student_model.dart';

Student fromSheet(int index, List<dynamic> sheetRow) {
  final name = sheetRow[0] as String? ?? "";
  final score = int.tryParse(sheetRow[1]) ?? 0;

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
