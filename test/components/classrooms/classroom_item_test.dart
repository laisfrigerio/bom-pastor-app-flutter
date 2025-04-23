import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bom_pastor_app/components/classrooms/classroom_item.dart';
import 'package:bom_pastor_app/models/classroom_model.dart';

void main() {
  group('ClassRoomItem Widget', () {
    testWidgets('should display classroom name and icon', (
      WidgetTester tester,
    ) async {
      // Arrange
      final classroom = ClassRoom(
        rowId: 1,
        code: 'C001',
        name: 'Math Class',
        spreadSheetName: 'Sheet1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClassRoomItem(
              classroom: classroom,
              onListStudents: (_, __) {},
              onEditClassRoom: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Math Class'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
    });

    testWidgets('should call onListStudents when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onListStudentsCalled = false;

      final classroom = ClassRoom(
        rowId: 1,
        code: 'C001',
        name: 'Math Class',
        spreadSheetName: 'Sheet1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClassRoomItem(
              classroom: classroom,
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
      await tester.tap(find.byKey(const Key('classroom_item_tap')));
      await tester.pumpAndSettle();

      // Assert
      expect(onListStudentsCalled, isTrue);
    });

    testWidgets('should call onEditClassRoom when edit is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onEditClassRoomCalled = false;

      final classroom = ClassRoom(
        rowId: 1,
        code: 'C001',
        name: 'Math Class',
        spreadSheetName: 'Sheet1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClassRoomItem(
              classroom: classroom,
              onListStudents: (_, __) {},
              onEditClassRoom: (editedClassroom) {
                onEditClassRoomCalled = true;
                expect(editedClassroom, classroom);
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
  });
}
