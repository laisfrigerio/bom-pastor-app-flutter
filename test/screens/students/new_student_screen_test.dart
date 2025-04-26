import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bom_pastor_app/models/student_model.dart';
import 'package:bom_pastor_app/screens/students/new_student_screen.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';

class MockGoogleSheetApi extends Mock implements IGoogleSheetApi {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockNavigatorObserver mockObserver;
  late MockGoogleSheetApi mockGoogleSheetApi;
  String spreadSheetName = "TestSheet";

  setUp(() {
    mockGoogleSheetApi = MockGoogleSheetApi();
    mockObserver = MockNavigatorObserver();
  });

  setUpAll(() {
    registerFallbackValue(Student(rowId: 1, name: '', score: 0));
    registerFallbackValue([]); // Registra fallback para List<dynamic>
    registerFallbackValue(1); // Registra fallback para int
    registerFallbackValue(''); // Registra fallback para String
    registerFallbackValue(FakeRoute());
  });

  group('NewStudentScreen', () {
    testWidgets('should display the text field and buttons', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: NewStudentScreen(
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Assert
      expect(find.text('Nome do Aluno'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Salvar'), findsOneWidget);
      expect(find.text('Adicionar Novo Aluno'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('should show an error message if the name is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: NewStudentScreen(
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Campo nome é obrigatório'), findsOneWidget);
    });

    testWidgets('should call addGoogleSheetData when saving', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.addGoogleSheetData(any(), any(), any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: NewStudentScreen(
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'John Doe');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Assert
      verify(
        () => mockGoogleSheetApi.addGoogleSheetData(
          ['John Doe', 0],
          any(),
          'TestSheet',
        ),
      ).called(1);
    });

    testWidgets('should show an error message if adding a student fails', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.addGoogleSheetData(any(), any(), any()),
      ).thenThrow(Exception('Failed to add student'));

      await tester.pumpWidget(
        MaterialApp(
          home: NewStudentScreen(
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'John Doe');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('Erro ao adicionar aluno: Exception: Failed to add student'),
        findsOneWidget,
      );
    });

    testWidgets('should navigate back when cancel is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: NewStudentScreen(
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NewStudentScreen), findsNothing);
    });

    testWidgets('should navigate back when appBar back button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: NewStudentScreen(
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NewStudentScreen), findsNothing);
      verify(() => mockObserver.didPop(any(), any())).called(1);
    });
  });
}
