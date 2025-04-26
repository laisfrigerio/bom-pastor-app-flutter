import 'package:bom_pastor_app/screens/students/edit_student_score_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bom_pastor_app/models/student_model.dart';
import 'package:bom_pastor_app/screens/students/edit_student_screen.dart';
import 'package:bom_pastor_app/screens/students/list_students_screen.dart';
import 'package:bom_pastor_app/screens/students/new_student_screen.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';

class MockGoogleSheetApi extends Mock implements IGoogleSheetApi {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockGoogleSheetApi mockGoogleSheetApi;
  final mockObserver = MockNavigatorObserver();
  final String spreadSheetName = 'sheetName1';

  setUp(() {
    mockGoogleSheetApi = MockGoogleSheetApi();
  });

  setUpAll(() {
    registerFallbackValue(FakeRoute());
    registerFallbackValue(Student(rowId: 1, name: '', score: 0));
    registerFallbackValue([]); // Registra fallback para List<dynamic>
    registerFallbackValue(1); // Registra fallback para int
    registerFallbackValue('sheetNameA'); // Registra fallback para String
  });

  group('ListStudentScreen', () {
    testWidgets('should show a loading indicator while fetching data', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: ListStudentsScreen(
            title: 'Lista de Alunos',
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show an empty message when no students are found', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListStudentsScreen(
            title: 'Lista de Alunos',
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nenhum aluno encontrado'), findsOneWidget);
    });

    testWidgets('should render a list of students when data is available', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer(
        (_) async => [
          ['Name', 'Score'],
          ['Maria', '0'],
          ['Ana', '10'],
          ['José', '3'],
          ['Pedro', '-17'],
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListStudentsScreen(
            title: 'Lista de Alunos',
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Maria'), findsOneWidget);
      expect(find.text('José'), findsOneWidget);
      expect(find.text('Pedro'), findsOneWidget);
      expect(find.text('Pontuação: -17'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(4));
    });

    testWidgets('should navigate to EditStudentScreen on edit button tap', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer(
        (_) async => [
          ['Name', 'Score'],
          ['Ana', '10'],
          ['Maria', '1'],
          ['Pedro', '-10'],
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListStudentsScreen(
            title: 'Lista de Alusnos',
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );
      await tester.pumpAndSettle();

      // encontra o botão "3" pontinhos na tela primeiro
      await tester.tap(find.byType(PopupMenuButton<String>).at(0));
      await tester.pumpAndSettle();

      //tap no botão edit
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EditStudentScreen), findsOneWidget);
    });

    testWidgets('should navigate to NewStudentScreen on plus button tap', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer(
        (_) async => [
          ['Name', 'Score'],
          ['Ana', '10'],
          ['Maria', '1'],
          ['Pedro', '-10'],
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListStudentsScreen(
            title: 'Lista de Alusnos',
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );
      await tester.pumpAndSettle();

      // encontra o botão "add (+)"
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NewStudentScreen), findsOneWidget);
    });

    testWidgets(
      'should navigate to EditStudentScoreScreen on tap student name',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
        ).thenAnswer(
          (_) async => [
            ['Name', 'Score'],
            ['Ana', '10'],
            ['Maria', '1'],
            ['Pedro', '-10'],
          ],
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: ListStudentsScreen(
              title: 'Lista de Alusnos',
              spreadSheetName: spreadSheetName,
              googleSheetApi: mockGoogleSheetApi,
            ),
            navigatorObservers: [mockObserver],
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('Ana'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(EditStudentScoreScreen), findsOneWidget);
      },
    );

    testWidgets(
      'should call deleteGoogleSheetRow when "Remove" button clicked',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
        ).thenAnswer(
          (_) async => [
            ['Name', 'Score'],
            ['Ana', '10'],
            ['Maria', '1'],
            ['Pedro', '-10'],
          ],
        );

        when(
          () => mockGoogleSheetApi.deleteGoogleSheetRow(1, any(), any()),
        ).thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: ListStudentsScreen(
              title: 'Lista de Alusnos',
              spreadSheetName: spreadSheetName,
              googleSheetApi: mockGoogleSheetApi,
            ),
            navigatorObservers: [mockObserver],
          ),
        );
        await tester.pumpAndSettle();

        // encontra o botão "3" pontinhos na tela primeiro
        await tester.tap(find.byType(PopupMenuButton<String>).at(0));
        await tester.pumpAndSettle();

        //tap no botão deletar
        await tester.tap(find.text('Deletar'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Ana'), findsOneWidget);
        verify(
          () => mockGoogleSheetApi.deleteGoogleSheetRow(1, any(), any()),
        ).called(1);
      },
    );

    testWidgets('should show a SnackBar on error', (WidgetTester tester) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenThrow(Exception('Failed to load data'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListStudentsScreen(
            title: 'Lista de Alusnos',
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should re-fetch data when the refresh button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer(
        (_) async => [
          ['Name', 'Score'],
          ['Ana', '7'],
          ['Maria', '15'],
          ['Pedro', '-23'],
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListStudentsScreen(
            title: 'Lista de Alusnos',
            spreadSheetName: spreadSheetName,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Maria'), findsOneWidget);
      expect(find.text('Pedro'), findsOneWidget);

      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer(
        (_) async => [
          ['Name', 'Score'],
          ['Ana', '7'],
          ['Maria', '15'],
          ['Pedro', '-23'],
          ['João', '0'],
        ],
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Maria'), findsOneWidget);
      expect(find.text('Pedro'), findsOneWidget);
      expect(find.text('João'), findsOneWidget);
    });
  });
}
