// Integration test for flutter_h2 plugin.
//
// Tests require the H2Core framework to be present.
// Run: flutter test integration_test/

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_h2/flutter_h2.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('VpnClientEngine singleton test', (WidgetTester tester) async {
    final engine = VpnClientEngine.instance;
    expect(engine, isNotNull);
    expect(engine.status, ConnectionStatus.disconnected);
  });

  testWidgets('getCoreName returns h2.core', (WidgetTester tester) async {
    final engine = VpnClientEngine.instance;
    final name = await engine.getCoreName();
    expect(name, 'h2.core');
  });
}
