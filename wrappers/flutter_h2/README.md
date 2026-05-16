# flutter_h2

H2 VPN Engine for Flutter — drop-in replacement for `vpnclient_engine_flutter` using h2.core backend.

## Features

- **API Compatible** — Same interface as `vpnclient_engine_flutter`
- **HTTPS/H2 Tunnel** — DPI-resistant VPN over standard HTTPS
- **SOCKS5 Proxy** — Local proxy for app traffic routing
- **Cross-Platform** — iOS and Android support via gomobile

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_h2:
    path: ../engines/flutter_h2
```

### Build Requirements

Before using, you need to build the native frameworks:

```bash
# 1. Build gomobile frameworks (requires Go 1.22)
cd vendors/h2.core
./build/mobile.sh ios      # Creates H2Core.xcframework
./build/mobile.sh android  # Creates h2core.aar

# 2. Copy to plugin
cd engines/flutter_h2
./build/copy_frameworks.sh
```

## Usage

### Basic Example

```dart
import 'package:flutter_h2/flutter_h2.dart';

// Get singleton instance
final engine = VpnClientEngine.instance;

// Configure
final config = VpnEngineConfig(
  core: CoreConfig(
    type: CoreType.h2,
    configJson: '{}',
    serverAddress: 'vpn.example.com',
    serverPort: 443,
    protocol: 'us',  // crypto provider: us, ua, cn, th, fr, uk
  ),
);

// Initialize and connect
await engine.initialize(config);
await engine.connect();

// Get SOCKS5 proxy port
final port = engine.getSocksPort();
print('SOCKS5 proxy at 127.0.0.1:$port');

// Disconnect when done
await engine.disconnect();
```

### Using SOCKS5 Proxy

H2 engine provides a local SOCKS5 proxy. Configure your HTTP client to use it:

```dart
import 'dart:io';

final engine = VpnClientEngine.instance;
await engine.connect();

final port = engine.getSocksPort();

// Configure HttpClient
final httpClient = HttpClient();
httpClient.findProxy = (uri) => 'SOCKS5 127.0.0.1:$port';
```

### Listening to Events

```dart
// Status changes
engine.statusStream.listen((status) {
  print('Status: ${status.toNativeString()}');
});

// Traffic statistics
engine.statsStream.listen((stats) {
  print('Up: ${stats.formattedBytesSent}');
  print('Down: ${stats.formattedBytesReceived}');
});

// Logs
engine.logStream.listen((log) {
  print('[${log['level']}] ${log['message']}');
});
```

### Using Callbacks

```dart
engine.setStatusCallback((status) {
  print('Status: $status');
});

engine.setStatsCallback((stats) {
  print('Traffic: ${stats.formattedTotalBytes}');
});

engine.setLogCallback((level, message) {
  print('[$level] $message');
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

  String get formattedBytesSent;
  String get formattedBytesReceived;
  String get formattedTotalBytes;
}
```

### VpnEngineConfig

```dart
VpnEngineConfig(
  core: CoreConfig(
    type: CoreType.h2,
    configJson: '{}',
    serverAddress: 'vpn.example.com',
    serverPort: 443,
    protocol: 'us',  // crypto provider
  ),
  // driver config is ignored (h2 uses SOCKS5)
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
   // After connect(), configure your HTTP client
   final port = engine.getSocksPort();
   httpClient.findProxy = (uri) => 'SOCKS5 127.0.0.1:$port';
   ```

### Key Differences

| Feature | vpnclient_engine_flutter | flutter_h2 |
|---------|-------------------------|------------|
| Tunnel | TUN device | SOCKS5 proxy |
| Traffic routing | System-wide | Per-app (proxy) |
| New method | — | `getSocksPort()` |
| Core type | xray, v2ray, sing | h2 |

## Platform Support

| Platform | Status |
|----------|--------|
| iOS | Supported (13.0+) |
| Android | Supported (API 24+) |
| macOS | Not supported |
| Windows | Not supported |
| Linux | Not supported |
| Web | Not supported |

## Project Structure

```
flutter_h2/
├── lib/
│   ├── flutter_h2.dart              # Library exports
│   └── src/
│       ├── vpnclient_engine.dart    # Main engine class
│       └── models/
│           ├── connection_status.dart
│           ├── connection_stats.dart
│           ├── config.dart
│           ├── core_type.dart
│           └── driver_type.dart
├── ios/
│   ├── Classes/FlutterH2Plugin.swift
│   ├── Frameworks/                  # H2Core.xcframework (built)
│   └── flutter_h2.podspec
├── android/
│   ├── src/.../FlutterH2Plugin.kt
│   ├── libs/                        # h2core.aar (built)
│   └── build.gradle.kts
├── build/
│   └── copy_frameworks.sh           # Build helper
├── test/
│   └── flutter_h2_test.dart
└── example/
    └── lib/main.dart
```

## Building Native Frameworks

### Prerequisites

- Go 1.22 (gomobile has issues with Go 1.25)
- Xcode (for iOS)
- Android SDK/NDK (for Android)
- gomobile: `go install golang.org/x/mobile/cmd/gomobile@latest`

### Build Commands

```bash
cd vendors/h2.core

# Build iOS framework
./build/mobile.sh ios
# Output: dist/mobile/H2Core.xcframework

# Build Android AAR
./build/mobile.sh android
# Output: dist/mobile/h2core.aar

# Copy to plugin
cd ../../engines/flutter_h2
./build/copy_frameworks.sh
```

## License

See LICENSE file.
