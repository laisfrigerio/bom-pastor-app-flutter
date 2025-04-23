import 'package:bom_pastor_app/components/classrooms/classroom_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bom_pastor_app/components/classrooms/list_classrooms.dart';
import 'package:bom_pastor_app/models/classroom_model.dart';

void main() {
  group('ListClassRooms Widget', () {
    testWidgets('should display a list of classrooms', (
      WidgetTester tester,
    ) async {
      // Arrange
      final classrooms = [
        ClassRoom(
          rowId: 1,
          code: 'C001',
          name: 'Math Class',
          spreadSheetName: 'Sheet1',
        ),
        ClassRoom(
          rowId: 2,
          code: 'C002',
          name: 'Science Class',
          spreadSheetName: 'Sheet2',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListClassRooms(
              classrooms: classrooms,
              onListStudents: (_, __) {},
              onEditClassRoom: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Math Class'), findsOneWidget);
      expect(find.text('Science Class'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsNWidgets(2));
    });

    testWidgets('should call onListStudents when a classroom is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onListStudentsCalled = false;

      final classrooms = [
        ClassRoom(
          rowId: 1,
          code: 'C001',
          name: 'Math Class',
          spreadSheetName: 'Sheet1',
        ),
        ClassRoom(
          rowId: 2,
          code: 'C002',
          name: 'Science Class',
          spreadSheetName: 'Sheet2',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListClassRooms(
              classrooms: classrooms,
              onListStudents: (name, spreadSheetName) {
                onListStudentsCalled = true;
                expect(name, 'Math Class');
                expect(spreadSheetName, 'Sheet1');
              },
              onEditClassRoom: (_) {},
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Math Class'));
      await tester.pumpAndSettle();

      // Assert
      expect(onListStudentsCalled, isTrue);
    });

    testWidgets('should call onEditClassRoom when edit is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onEditClassRoomCalled = false;

      final classrooms = [
        ClassRoom(
          rowId: 1,
          code: 'C001',
          name: 'Math Class',
          spreadSheetName: 'Sheet1',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListClassRooms(
              classrooms: classrooms,
              onListStudents: (_, __) {},
              onEditClassRoom: (editedClassroom) {
                onEditClassRoomCalled = true;
                expect(editedClassroom, classrooms[0]);
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.more_vert)); // Open the popup menu
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar')); // Select the "Editar" option
      await tester.pumpAndSettle();

      // Assert
      expect(onEditClassRoomCalled, isTrue);
    });

    testWidgets('should handle an empty list of classrooms', (
      WidgetTester tester,
    ) async {
      // Arrange
      final classrooms = <ClassRoom>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListClassRooms(
              classrooms: classrooms,
              onListStudents: (_, __) {},
              onEditClassRoom: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ClassRoomItem), findsNothing);
    });
  });
}
