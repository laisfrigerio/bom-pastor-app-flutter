import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bom_pastor_app/screens/classrooms/edit_classroom_screen.dart';
import 'package:bom_pastor_app/screens/classrooms/list_classroom_screen.dart';
import 'package:bom_pastor_app/screens/students/list_students_screen.dart';
import 'package:bom_pastor_app/third_party/google_sheet.dart';

class MockGoogleSheetApi extends Mock implements IGoogleSheetApi {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  late MockGoogleSheetApi mockGoogleSheetApi;
  final mockObserver = MockNavigatorObserver();

  setUp(() {
    mockGoogleSheetApi = MockGoogleSheetApi();
  });

  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  group('ListClassRoomScreen', () {
    testWidgets('should show a loading indicator while fetching data', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: ListClassRoomScreen(
            title: 'Classrooms',
            googleSheetApi: mockGoogleSheetApi,
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show an empty message when no classrooms are found', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer((_) async => []);
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListClassRoomScreen(
            title: 'Classrooms',
            googleSheetApi: mockGoogleSheetApi,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nenhuma turma encontrada'), findsOneWidget);
    });

    testWidgets('should render a list of classrooms when data is available', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer(
        (_) async => [
          ['Code', 'Name', 'Spread Sheet Name'],
          ['C001', 'Math Class', 'Sheet1'],
          ['C002', 'Science Class', 'Sheet2'],
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListClassRoomScreen(
            title: 'Classrooms',
            googleSheetApi: mockGoogleSheetApi,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Math Class'), findsOneWidget);
      expect(find.text('Science Class'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('should navigate to ListStudentsScreen on classroom tap', (
      WidgetTester tester,
    ) async {
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer(
        (_) async => [
          ['Code', 'Name', 'Spread Sheet Name'],
          ['C001', 'Math Class', 'Sheet1'],
          ['C002', 'Science Class', 'Sheet2'],
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListClassRoomScreen(
            title: 'Classrooms',
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Math Class'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListStudentsScreen), findsOneWidget);
    });

    testWidgets('should navigate to EditClassRoomScreen on edit button tap', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer(
        (_) async => [
          ['Code', 'Name', 'Spread Sheet Name'],
          ['C001', 'Math Class', 'Sheet1'],
          ['C002', 'Science Class', 'Sheet2'],
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListClassRoomScreen(
            title: 'Classrooms',
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
      expect(find.byType(EditClassRoomScreen), findsOneWidget);
    });

    testWidgets('should show a SnackBar on error', (WidgetTester tester) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenThrow(Exception('Failed to load data'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListClassRoomScreen(
            title: 'Classrooms',
            googleSheetApi: mockGoogleSheetApi,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      // expect(find.text('Exception: Failed to load data'), findsOneWidget);
    });

    testWidgets('should re-fetch data when the refresh button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer(
        (_) async => [
          ['Code', 'Name', 'Spread Sheet Name'],
          ['C001', 'Math Class', 'Sheet1'],
          ['C002', 'Science Class', 'Sheet2'],
        ],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ListClassRoomScreen(
            title: 'Classrooms',
            googleSheetApi: mockGoogleSheetApi,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Math Class'), findsOneWidget);
      expect(find.text('Science Class'), findsOneWidget);

      when(
        () => mockGoogleSheetApi.readGoogleSheetData(any(), any()),
      ).thenAnswer(
        (_) async => [
          ['Code', 'Name', 'Spread Sheet Name'],
          ['C001', 'English Class', 'Sheet1'],
        ],
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('English Class'), findsOneWidget);
      expect(find.text('Math Class'), findsNothing);
      expect(find.text('Science Class'), findsNothing);
    });
  });
}
