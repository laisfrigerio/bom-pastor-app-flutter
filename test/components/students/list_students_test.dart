import 'package:bom_pastor_app/components/students/student_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bom_pastor_app/components/students/list_students.dart';
import 'package:bom_pastor_app/models/student_model.dart';

void main() {
  group('ListStudents Widget', () {
    testWidgets('should display a list of students', (
      WidgetTester tester,
    ) async {
      // Arrange
      final students = [
        Student(rowId: 1, name: 'John Doe', score: 100),
        Student(rowId: 2, name: 'Jane Doe', score: 200),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListStudents(
              students: students,
              onEditStudent: (_) {},
              onEditStudentScore: (_) {},
              onDeleteStudent: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Pontuação: 100'), findsOneWidget);
      expect(find.text('Pontuação: 200'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsNWidgets(2));
    });

    testWidgets('should call onEditStudentScore when a student is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onEditStudentScoreCalled = false;

      final students = [Student(rowId: 21, name: 'John D. Doe', score: 117)];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListStudents(
              students: students,
              onEditStudent: (_) {},
              onEditStudentScore: (student) {
                onEditStudentScoreCalled = true;
                expect(student.name, 'John D. Doe');
                expect(student.score, 117);
              },
              onDeleteStudent: (_) {},
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('John D. Doe'));
      await tester.pumpAndSettle();

      // Assert
      expect(onEditStudentScoreCalled, isTrue);
    });

    testWidgets('should call onEditStudent when edit is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onEditStudentCalled = false;

      final students = [Student(rowId: 2, name: 'Mary Doe', score: 32)];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListStudents(
              students: students,
              onEditStudent: (student) {
                onEditStudentCalled = true;
                expect(student.name, 'Mary Doe');
                expect(student.score, 32);
              },
              onEditStudentScore: (_) {},
              onDeleteStudent: (_) {},
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

    testWidgets('should call onDeleteStudent when delete is selected', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onDeleteStudentCalled = false;

      final students = [Student(rowId: 1, name: 'Alejandro Franz', score: 2)];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListStudents(
              students: students,
              onEditStudent: (_) {},
              onEditStudentScore: (_) {},
              onDeleteStudent: (student) {
                onDeleteStudentCalled = true;
                expect(student.name, 'Alejandro Franz');
                expect(student.score, 2);
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
      expect(onDeleteStudentCalled, isTrue);
    });

    testWidgets('should handle an empty list of students', (
      WidgetTester tester,
    ) async {
      // Arrange
      final students = <Student>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListStudents(
              students: students,
              onEditStudent: (_) {},
              onEditStudentScore: (_) {},
              onDeleteStudent: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(StudentItem), findsNothing);
    });
  });
}
