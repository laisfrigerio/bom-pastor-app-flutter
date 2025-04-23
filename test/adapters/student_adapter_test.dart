import 'package:flutter_test/flutter_test.dart';
import 'package:bom_pastor_app/adapters/student_adapter.dart';
import 'package:bom_pastor_app/models/student_model.dart';

void main() {
  group('fromSheet', () {
    test('should correctly map a sheet row to a Student object', () {
      final sheetRow = ['John Doe', '100'];
      final student = fromSheet(1, sheetRow);

      expect(student.rowId, 1);
      expect(student.name, 'John Doe');
      expect(student.score, 100);
    });

    test('should handle null or missing values in the sheet row', () {
      final sheetRow = [null, null];
      final student = fromSheet(2, sheetRow);

      expect(student.rowId, 2);
      expect(student.name, '');
      expect(student.score, 0);
    });

    test('should handle invalid score values gracefully', () {
      final sheetRow = ['Jane Doe', 'invalid'];
      final student = fromSheet(3, sheetRow);

      expect(student.rowId, 3);
      expect(student.name, 'Jane Doe');
      expect(student.score, 0);
    });
  });

  group('listFromSheet', () {
    test('should correctly map a list of sheet rows to a list of Student objects', () {
      final sheetData = [
        ['Name', 'Score'], // Header row
        ['John Doe', '100'],
        ['Jane Doe', '200'],
      ];

      final students = listFromSheet(sheetData);

      expect(students.length, 2);

      expect(students[0].rowId, 1);
      expect(students[0].name, 'John Doe');
      expect(students[0].score, 100);

      expect(students[1].rowId, 2);
      expect(students[1].name, 'Jane Doe');
      expect(students[1].score, 200);
    });

    test('should skip rows with insufficient columns', () {
      final sheetData = [
        ['Name', 'Score'], // Header row
        ['John Doe'], // Missing score
        ['Jane Doe', '200'],
      ];

      final students = listFromSheet(sheetData);

      expect(students.length, 1);

      expect(students[0].rowId, 2);
      expect(students[0].name, 'Jane Doe');
      expect(students[0].score, 200);
    });

    test('should return an empty list if no valid rows are provided', () {
      final sheetData = [
        ['Name'], // Insufficient columns
      ];

      final students = listFromSheet(sheetData);

      expect(students, isEmpty);
    });
  });
}
