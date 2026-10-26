import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:probash_mart_app/main.dart';
import 'package:probash_mart_app/data/services/storage_service.dart';

void main() {
  testWidgets('Probash Mart smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().init();

    await tester.pumpWidget(const ProbashMartApp());
    expect(find.byType(ProbashMartApp), findsOneWidget);

    // Settle splash timer
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}
