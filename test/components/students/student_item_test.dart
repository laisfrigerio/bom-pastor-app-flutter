import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bom_pastor_app/components/students/student_item.dart';
import 'package:bom_pastor_app/models/student_model.dart';

void main() {
  group('StudentItem Widget', () {
    testWidgets('should display student name and score', (
      WidgetTester tester,
    ) async {
      // Arrange
      final student = Student(rowId: 1, name: 'John Doe', score: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentItem(
              student: student,
              onEditStudent: (_) {},
              onEditStudentScore: (_) {},
              onDeletetStudent: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Pontuação: 100'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should call onEditStudentScore when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onEditStudentScoreCalled = false;

      final student = Student(rowId: 1, name: 'John Doe', score: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentItem(
              student: student,
              onEditStudent: (_) {},
              onEditStudentScore: (editedStudent) {
                onEditStudentScoreCalled = true;
                expect(editedStudent, student);
              },
              onDeletetStudent: (_) {},
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('student_item_tap')));
      await tester.pumpAndSettle();

      // Assert
      expect(onEditStudentScoreCalled, isTrue);
    });

    testWidgets('should call onEditStudent when edit is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onEditStudentCalled = false;

      final student = Student(rowId: 1, name: 'John Doe', score: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentItem(
              student: student,
              onEditStudent: (editedStudent) {
                onEditStudentCalled = true;
                expect(editedStudent, student);
              },
              onEditStudentScore: (_) {},
              onDeletetStudent: (_) {},
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
      expect(onEditStudentCalled, isTrue);
    });

    testWidgets('should call onDeletetStudent when delete is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onDeletetStudentCalled = false;

      final student = Student(rowId: 1, name: 'John Doe', score: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentItem(
              student: student,
              onEditStudent: (_) {},
              onEditStudentScore: (_) {},
              onDeletetStudent: (deletedStudent) {
                onDeletetStudentCalled = true;
                expect(deletedStudent, student);
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.more_vert)); // Open the popup menu
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deletar')); // Select the "Deletar" option
      await tester.pumpAndSettle();

      // Assert
      expect(onDeletetStudentCalled, isTrue);
    });
  });
}
