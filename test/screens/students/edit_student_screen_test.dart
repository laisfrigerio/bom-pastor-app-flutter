import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bom_pastor_app/models/student_model.dart';
import 'package:bom_pastor_app/screens/students/edit_student_screen.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';

class MockGoogleSheetApi extends Mock implements IGoogleSheetApi {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  final mockObserver = MockNavigatorObserver();
  late MockGoogleSheetApi mockGoogleSheetApi;
  late Student mockStudent;
  String spreadSheetName = "sheetNameA";

  setUp(() {
    mockGoogleSheetApi = MockGoogleSheetApi();
    mockStudent = Student(rowId: 1, name: 'Maria', score: 3);
  });

  setUpAll(() {
    registerFallbackValue(Student(rowId: 1, name: '', score: 0));
    registerFallbackValue([]); // Registra fallback para List<dynamic>
    registerFallbackValue(1); // Registra fallback para int
    registerFallbackValue(''); // Registra fallback para String
    registerFallbackValue(FakeRoute());
  });

  group('EditStudentScreen', () {
    testWidgets('should display the current student name in the text field', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: EditStudentScreen(
            studentName: mockStudent.name,
            studentScore: mockStudent.score,
            rowNumber: mockStudent.rowId,
            spreadSheetName: spreadSheetName,
          ),
        ),
      );

      // Assert
      expect(find.text('Maria'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
      expect(find.text('3'), findsNothing);
    });

    testWidgets(
      'should call updateGoogleSheetRow when Save button is clicked',
      (WidgetTester tester) async {
        when(
          () => mockGoogleSheetApi.updateGoogleSheetRow(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(
          MaterialApp(
            home: EditStudentScreen(
              studentName: mockStudent.name,
              studentScore: mockStudent.score,
              rowNumber: mockStudent.rowId,
              spreadSheetName: spreadSheetName,
              googleSheetApi: mockGoogleSheetApi,
            ),
            navigatorObservers: [mockObserver],
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField), 'Mariana');
        await tester.tap(find.text("Salvar"));
        await tester.pump();

        // Assert
        expect(find.text('Mariana'), findsOneWidget);
        verify(() => mockObserver.didPop(any(), any())).called(1);
        verify(
          () => mockGoogleSheetApi.updateGoogleSheetRow(
            ["Mariana", mockStudent.score],
            mockStudent.rowId,
            any(),
            any(),
          ),
        ).called(1);
      },
    );

    testWidgets('should show an error message if the name is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: EditStudentScreen(
            studentName: mockStudent.name,
            studentScore: mockStudent.score,
            rowNumber: mockStudent.rowId,
            spreadSheetName: spreadSheetName,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text("Salvar"));
      await tester.pump();

      // Assert
      expect(find.text('Campo Nome é obrigatório'), findsOneWidget);
    });

    testWidgets('should navigate back when appBar back button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: EditStudentScreen(
            studentName: mockStudent.name,
            studentScore: mockStudent.score,
            rowNumber: mockStudent.rowId,
            spreadSheetName: spreadSheetName,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EditStudentScreen), findsNothing);
      verify(() => mockObserver.didPop(any(), any())).called(1);
    });
  });
}
