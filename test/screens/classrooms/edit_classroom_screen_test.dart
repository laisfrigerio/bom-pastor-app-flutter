import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bom_pastor_app/third_party/google_sheet.dart';
import 'package:bom_pastor_app/screens/classrooms/edit_classroom_screen.dart';
import 'package:bom_pastor_app/models/classroom_model.dart';

class MockGoogleSheetApi extends Mock implements IGoogleSheetApi {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  final mockObserver = MockNavigatorObserver();
  late MockGoogleSheetApi mockGoogleSheetApi;
  late ClassRoom mockClassRoom;

  setUp(() {
    mockGoogleSheetApi = MockGoogleSheetApi();
    mockClassRoom = ClassRoom(
      rowId: 1,
      code: 'C001',
      name: 'Math Class',
      spreadSheetName: 'Sheet1',
    );
  });

  setUpAll(() {
    registerFallbackValue(
      ClassRoom(rowId: 1, code: '', name: '', spreadSheetName: ''),
    );
    registerFallbackValue([]); // Registra fallback para List<dynamic>
    registerFallbackValue(1); // Registra fallback para int
    registerFallbackValue(''); // Registra fallback para String
    registerFallbackValue(FakeRoute());
  });

  group('EditClassRoomScreen', () {
    testWidgets('should display the current classroom name in the text field', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: EditClassRoomScreen(classRoom: mockClassRoom)),
      );

      // Assert
      expect(find.text('Math Class'), findsOneWidget);
      expect(find.text('Nome da Turma'), findsOneWidget);
    });

    testWidgets('should call updateGoogleSheetRow when saving', (
      WidgetTester tester,
    ) async {
      when(
        () =>
            mockGoogleSheetApi.updateGoogleSheetRow(any(), any(), any(), any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: EditClassRoomScreen(
            classRoom: mockClassRoom,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), 'Updated Class Name');
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      // Assert
      expect(find.text('Updated Class Name'), findsOneWidget);
      verify(() => mockObserver.didPop(any(), any())).called(1);
      verify(
        () => mockGoogleSheetApi.updateGoogleSheetRow(
          any(),
          mockClassRoom.rowId + 1,
          any(),
          any(),
        ),
      ).called(1);
    });

    testWidgets('should show an error message if the name is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: EditClassRoomScreen(
            classRoom: mockClassRoom,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Salvar'));
      await tester.pump();

      // Assert
      expect(find.text('Nome da turma não pode estar vazio.'), findsOneWidget);
    });

    testWidgets('should navigate back when cancel is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: EditClassRoomScreen(
            classRoom: mockClassRoom,
            googleSheetApi: mockGoogleSheetApi,
          ),
          navigatorObservers: [mockObserver],
        ),
      );

      // Act
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(EditClassRoomScreen), findsNothing);
      verify(() => mockObserver.didPop(any(), any())).called(1);
    });
  });
}
