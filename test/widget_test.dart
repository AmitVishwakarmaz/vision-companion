import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vision_companion/core/di/injection_container.dart';
import 'package:vision_companion/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await initDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('VisionCompanionApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VisionCompanionApp());
    await tester.pumpAndSettle();

    expect(find.byType(VisionCompanionApp), findsOneWidget);
  });
}
