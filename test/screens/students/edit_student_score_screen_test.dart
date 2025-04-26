import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bom_pastor_app/models/student_model.dart';
import 'package:bom_pastor_app/screens/students/edit_student_score_screen.dart';
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
    mockStudent = Student(rowId: 1, name: 'Ana', score: 10);
  });

  setUpAll(() {
    registerFallbackValue(Student(rowId: 1, name: '', score: 0));
    registerFallbackValue([]); // Registra fallback para List<dynamic>
    registerFallbackValue(1); // Registra fallback para int
    registerFallbackValue('sheetNameA'); // Registra fallback para String
    registerFallbackValue(FakeRoute());
  });

  group('EditStudentScoreScreen', () {
    testWidgets('should display the current student name in the text field', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: EditStudentScoreScreen(
            student: mockStudent,
            spreadSheetName: spreadSheetName,
          ),
        ),
      );

      // Assert
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Pontuação atual'), findsOneWidget);
      expect(find.text('Pontuação'), findsOneWidget);
      expect(find.text("10"), findsOneWidget);
    });

    testWidgets(
      "should name and current score input be disabled and new score input enable",
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: EditStudentScoreScreen(
              student: mockStudent,
              spreadSheetName: spreadSheetName,
            ),
          ),
        );

        // Assert Name field
        final nameTextField = find.byType(TextField).at(0).evaluate().first;
        final nameTextFieldWidget = nameTextField.widget as TextField;
        expect(nameTextFieldWidget.enabled, false);

        // Assert Current Score field
        final currentScoreTextField =
            find.byType(TextField).at(1).evaluate().first;
        final currentScoreTextFieldWidget =
            currentScoreTextField.widget as TextField;
        expect(currentScoreTextFieldWidget.enabled, false);

        // Assert New Score field
        final newScoreTextField = find.byType(TextField).at(2).evaluate().first;
        final newScoreTextFieldWidget = newScoreTextField.widget as TextField;
        expect(newScoreTextFieldWidget.enabled, true);
      },
    );

    testWidgets('should call updateGoogleSheetRow when Add button is clicked', (
      WidgetTester tester,
    ) async {
      when(
        () =>
            mockGoogleSheetApi.updateGoogleSheetRow(any(), any(), any(), any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: EditStudentScoreScreen(
            student: mockStudent,
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField).at(2), '7');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Assert
      expect(find.text('7'), findsOneWidget);
      verify(() => mockObserver.didPop(any(), any())).called(1);
      verify(
        () => mockGoogleSheetApi.updateGoogleSheetRow(
          ["Ana", 17],
          mockStudent.rowId + 1,
          any(),
          any(),
        ),
      ).called(1);
    });

    testWidgets(
      'should call updateGoogleSheetRow when Remove button is clicked',
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
            home: EditStudentScoreScreen(
              student: mockStudent,
              spreadSheetName: spreadSheetName,
              googleSheetApi: mockGoogleSheetApi,
            ),
            navigatorObservers: [mockObserver],
          ),
        );

        // Act
        await tester.enterText(find.byType(TextField).at(2), '6');
        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        // Assert
        expect(find.text('6'), findsOneWidget);
        verify(() => mockObserver.didPop(any(), any())).called(1);
        verify(
          () => mockGoogleSheetApi.updateGoogleSheetRow(
            ["Ana", 4],
            mockStudent.rowId + 1,
            any(),
            any(),
          ),
        ).called(1);
      },
    );

    testWidgets('should show an error message if the score is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: EditStudentScoreScreen(
            student: mockStudent,
            spreadSheetName: spreadSheetName,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField).at(2), '');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Assert
      expect(find.text('Número da pontuação obrigatório'), findsOneWidget);
    });

    testWidgets('should navigate back when appBar back button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: EditStudentScoreScreen(
            student: mockStudent,
            spreadSheetName: spreadSheetName,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EditStudentScoreScreen), findsNothing);
      verify(() => mockObserver.didPop(any(), any())).called(1);
    });
  });
}
