import 'package:flutter_test/flutter_test.dart';
import 'package:bom_pastor_app/adapters/classroom_adapter.dart';

void main() {
  group('fromSheet', () {
    test('should correctly map a sheet row to a ClassRoom object', () {
      final sheetRow = ['C001', 'Math Class', 'Sheet1'];
      final classroom = fromSheet(1, sheetRow);

      expect(classroom.rowId, 1);
      expect(classroom.code, 'C001');
      expect(classroom.name, 'Math Class');
      expect(classroom.spreadSheetName, 'Sheet1');
    });

    test('should handle null or missing values in the sheet row', () {
      final sheetRow = [null, null, null];
      final classroom = fromSheet(2, sheetRow);

      expect(classroom.rowId, 2);
      expect(classroom.code, '');
      expect(classroom.name, '');
      expect(classroom.spreadSheetName, '');
    });
  });

  group('listFromSheet', () {
    test(
      'should correctly map a list of sheet rows to a list of ClassRoom objects',
      () {
        final sheetData = [
          ['Code', 'Name', 'SpreadSheetName'], // Header row
          ['C001', 'Math Class', 'Sheet1'],
          ['C002', 'Science Class', 'Sheet2'],
        ];

        final classrooms = listFromSheet(sheetData);

        expect(classrooms.length, 2);

        expect(classrooms[0].rowId, 1);
        expect(classrooms[0].code, 'C001');
        expect(classrooms[0].name, 'Math Class');
        expect(classrooms[0].spreadSheetName, 'Sheet1');

        expect(classrooms[1].rowId, 2);
        expect(classrooms[1].code, 'C002');
        expect(classrooms[1].name, 'Science Class');
        expect(classrooms[1].spreadSheetName, 'Sheet2');
      },
    );

    test('should skip rows with insufficient columns', () {
      final sheetData = [
        ['Code', 'Name', 'SpreadSheetName'], // Header row
        ['C001', 'Math Class'], // Missing SpreadSheetName
        ['C002', 'Science Class', 'Sheet2'],
      ];

      final classrooms = listFromSheet(sheetData);

      expect(classrooms.length, 1);

      expect(classrooms[0].rowId, 2);
      expect(classrooms[0].code, 'C002');
      expect(classrooms[0].name, 'Science Class');
      expect(classrooms[0].spreadSheetName, 'Sheet2');
    });

    test('should return an empty list if no valid rows are provided', () {
      final sheetData = [
        ['Code', 'Name'], // Insufficient columns
      ];

      final classrooms = listFromSheet(sheetData);

      expect(classrooms, isEmpty);
    });
  });
}
