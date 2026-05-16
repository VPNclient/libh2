# flutter_h2

Flutter plugin for h2.core HTTPS VPN. Drop-in replacement for `vpnclient_engine_flutter`.

## Features

- **API Compatible** - Same interface as `vpnclient_engine_flutter`
- **HTTPS/H2 Tunnel** - DPI-resistant VPN over standard HTTPS
- **SOCKS5 Proxy** - Local proxy for app traffic routing (no VPN permissions)
- **Cross-Platform** - iOS and Android support via gomobile

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_h2:
    path: path/to/flutter_h2
```

## Quick Start

```dart
import 'package:flutter_h2/flutter_h2.dart';

final engine = VpnClientEngine.instance;

// Initialize
await engine.initialize(VpnEngineConfig(
  core: CoreConfig(
    type: CoreType.h2,
    configJson: '{}',
    serverAddress: 'vpn.example.com',
    serverPort: 443,
    protocol: 'us', // crypto provider
  ),
));

// Connect - starts local SOCKS5 proxy
await engine.connect();

// Get proxy port
final port = engine.getSocksPort();
print('SOCKS5 proxy at 127.0.0.1:$port');

// Disconnect
await engine.disconnect();
```

## Using the SOCKS5 Proxy

H2 provides a local SOCKS5 proxy. Configure your HTTP client:

```dart
import 'dart:io';

final port = engine.getSocksPort();

// With HttpClient
final httpClient = HttpClient()
  ..findProxy = (uri) => 'SOCKS5 127.0.0.1:$port';

// With Dio
(dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
  final client = HttpClient();
  client.findProxy = (uri) => 'SOCKS5 127.0.0.1:$port';
  return client;
};
```

## Listening to Events

```dart
// Status changes
engine.statusStream.listen((status) {
  print('Status: $status');
});

// Traffic statistics
engine.statsStream.listen((stats) {
  print('Up: ${stats.bytesSent}, Down: ${stats.bytesReceived}');
});

// Logs
engine.logStream.listen((log) {
  print('[${log['level']}] ${log['message']}');
});
```

## API Reference

### VpnClientEngine

| Method | Description |
|--------|-------------|
| `instance` | Singleton instance |
| `initialize(config)` | Initialize with VpnEngineConfig |
| `connect()` | Connect to VPN, returns success |
| `disconnect()` | Disconnect from VPN |
| `dispose()` | Release resources |
| `status` | Current ConnectionStatus |
| `stats` | Current ConnectionStats |
| `getSocksPort()` | Local SOCKS5 proxy port (0 if not connected) |
| `statusStream` | Stream of status changes |
| `statsStream` | Stream of statistics updates |
| `logStream` | Stream of log messages |
| `getCoreName()` | Returns "h2.core" |
| `getCoreVersion()` | Returns version string |

### ConnectionStatus

```dart
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}
```

### ConnectionStats

```dart
class ConnectionStats {
  final int bytesSent;
  final int bytesReceived;
  final int packetsSent;
  final int packetsReceived;
  final int latencyMs;
}
```

### Configuration

```dart
VpnEngineConfig(
  core: CoreConfig(
    type: CoreType.h2,
    configJson: '{}',
    serverAddress: 'vpn.example.com',
    serverPort: 443,
    protocol: 'us',  // crypto provider: us, ua, cn, th, fr, uk
  ),
)
```

## Migration from vpnclient_engine_flutter

1. Change import:
   ```dart
   // Before
   import 'package:vpnclient_engine_flutter/vpnclient_engine.dart';

   // After
   import 'package:flutter_h2/flutter_h2.dart';
   ```

2. Add SOCKS5 proxy configuration:
   ```dart
   final port = engine.getSocksPort();
   httpClient.findProxy = (uri) => 'SOCKS5 127.0.0.1:$port';
   ```

### Key Differences

| Feature | vpnclient_engine_flutter | flutter_h2 |
|---------|-------------------------|------------|
| Tunnel | TUN device | SOCKS5 proxy |
| Traffic routing | System-wide | Per-app (proxy) |
| VPN permissions | Required | Not required |
| New method | - | `getSocksPort()` |

## Platform Support

| Platform | Status | Min Version |
|----------|--------|-------------|
| iOS | Supported | 13.0 |
| Android | Supported | API 24 |
| macOS | Not supported | - |
| Windows | Not supported | - |
| Linux | Not supported | - |

## Project Structure

```
flutter_h2/
├── lib/
│   ├── flutter_h2.dart              # Library exports
│   └── src/
│       ├── vpnclient_engine.dart    # Main engine class
│       └── models/                  # Data models
├── ios/
│   ├── Classes/FlutterH2Plugin.swift
│   ├── Frameworks/H2Core.xcframework
│   └── flutter_h2.podspec
├── android/
│   ├── src/.../FlutterH2Plugin.kt
│   ├── libs/h2core.aar
│   └── build.gradle.kts
└── test/
    └── flutter_h2_test.dart
```

## Building Native Frameworks

The plugin includes pre-built native libraries. To rebuild:

```bash
# Go to libh2 root
cd ../..

# Build iOS framework
./build/gomobile.sh ios

# Build Android AAR
./build/gomobile.sh android

# Copy to plugin
./build/copy_to_flutter.sh
```

### Prerequisites

- Go 1.21+
- gomobile: `go install golang.org/x/mobile/cmd/gomobile@latest`
- Xcode (for iOS)
- Android NDK (for Android)

## Tests

```bash
flutter test
```

## License

Proprietary - NativeMind
