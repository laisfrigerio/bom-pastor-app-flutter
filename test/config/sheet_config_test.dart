import 'package:bom_pastor_app/config/sheet_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Check sheet config placeholder', (WidgetTester tester) async {
    expect(SheetConfig.spreadSheetId, "GOOGLE_SHEET_PLACEHOLDER");
  });
}
