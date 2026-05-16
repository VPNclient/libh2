import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_h2/flutter_h2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VpnClientEngine', () {
    test('singleton returns same instance', () {
      final engine1 = VpnClientEngine.instance;
      final engine2 = VpnClientEngine.instance;
      expect(identical(engine1, engine2), true);
    });

    test('initial status is disconnected', () {
      final engine = VpnClientEngine.instance;
      expect(engine.status, ConnectionStatus.disconnected);
    });

    test('initial stats are empty', () {
      final engine = VpnClientEngine.instance;
      expect(engine.stats.bytesSent, 0);
      expect(engine.stats.bytesReceived, 0);
    });

    test('getSocksPort returns 0 when not connected', () {
      final engine = VpnClientEngine.instance;
      expect(engine.getSocksPort(), 0);
    });

    test('getCoreName returns h2.core', () async {
      final engine = VpnClientEngine.instance;
      final name = await engine.getCoreName();
      expect(name, 'h2.core');
    });
  });

  group('ConnectionStatus', () {
    test('fromString parses all values', () {
      expect(
        ConnectionStatus.fromString('DISCONNECTED'),
        ConnectionStatus.disconnected,
      );
      expect(
        ConnectionStatus.fromString('CONNECTING'),
        ConnectionStatus.connecting,
      );
      expect(
        ConnectionStatus.fromString('CONNECTED'),
        ConnectionStatus.connected,
      );
      expect(
        ConnectionStatus.fromString('DISCONNECTING'),
        ConnectionStatus.disconnecting,
      );
      expect(ConnectionStatus.fromString('ERROR'), ConnectionStatus.error);
    });

    test('toNativeString returns correct values', () {
      expect(ConnectionStatus.disconnected.toNativeString(), 'DISCONNECTED');
      expect(ConnectionStatus.connecting.toNativeString(), 'CONNECTING');
      expect(ConnectionStatus.connected.toNativeString(), 'CONNECTED');
      expect(ConnectionStatus.disconnecting.toNativeString(), 'DISCONNECTING');
      expect(ConnectionStatus.error.toNativeString(), 'ERROR');
    });
  });

  group('ConnectionStats', () {
    test('fromMap parses correctly', () {
      final stats = ConnectionStats.fromMap({
        'bytesSent': 1024,
        'bytesReceived': 2048,
        'packetsSent': 10,
        'packetsReceived': 20,
        'latencyMs': 50,
      });

      expect(stats.bytesSent, 1024);
      expect(stats.bytesReceived, 2048);
      expect(stats.packetsSent, 10);
      expect(stats.packetsReceived, 20);
      expect(stats.latencyMs, 50);
    });

    test('fromMap handles h2 format (bytesIn/bytesOut)', () {
      final stats = ConnectionStats.fromMap({
        'bytesIn': 2048,
        'bytesOut': 1024,
      });

      expect(stats.bytesReceived, 2048);
      expect(stats.bytesSent, 1024);
    });

    test('formatted bytes', () {
      expect(
        const ConnectionStats(bytesSent: 512).formattedBytesSent,
        '512 B',
      );
      expect(
        const ConnectionStats(bytesSent: 1024).formattedBytesSent,
        '1.00 KB',
      );
      expect(
        const ConnectionStats(bytesSent: 1048576).formattedBytesSent,
        '1.00 MB',
      );
    });
  });

  group('CoreType', () {
    test('fromString parses h2 variants', () {
      expect(CoreType.fromString('h2'), CoreType.h2);
      expect(CoreType.fromString('h2core'), CoreType.h2);
      expect(CoreType.fromString('h2.core'), CoreType.h2);
    });

    test('toNativeString returns h2', () {
      expect(CoreType.h2.toNativeString(), 'h2');
    });
  });
}
