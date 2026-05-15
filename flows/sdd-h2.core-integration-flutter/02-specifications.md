# Specifications: flutter_h2

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter App                               │
├─────────────────────────────────────────────────────────────────┤
│                     flutter_h2 (Dart)                           │
│  ┌─────────────────┐  ┌──────────────┐  ┌─────────────────┐    │
│  │ VpnClientEngine │  │ ConnectionX  │  │  VpnEngineConfig │    │
│  │   (singleton)   │  │ Status/Stats │  │  CoreConfig etc  │    │
│  └────────┬────────┘  └──────────────┘  └─────────────────┘    │
│           │ MethodChannel                                       │
├───────────┼─────────────────────────────────────────────────────┤
│           ▼                                                      │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              Platform Plugin (Swift/Kotlin)                 ││
│  │  ┌───────────────┐    ┌─────────────────────────────────┐  ││
│  │  │ FlutterH2Plugin│───▶│   H2Core (gomobile framework)   │  ││
│  │  │               │    │  - mobile.NewClient()           │  ││
│  │  │ - initialize  │    │  - client.Start() -> SOCKS port │  ││
│  │  │ - connect     │    │  - client.Stop()                │  ││
│  │  │ - disconnect  │    │  - client.GetStats()            │  ││
│  │  │ - getStats    │    └─────────────────────────────────┘  ││
│  │  └───────────────┘                                          ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Dart Layer

### File Structure

```
engines/flutter_h2/lib/
├── flutter_h2.dart                    # Library exports (API-compatible)
├── src/
│   ├── vpnclient_engine.dart          # Main VpnClientEngine class
│   ├── models/
│   │   ├── connection_status.dart     # ConnectionStatus enum
│   │   ├── connection_stats.dart      # ConnectionStats class
│   │   ├── config.dart                # VpnEngineConfig, CoreConfig, DriverConfig
│   │   ├── core_type.dart             # CoreType enum (add h2 type)
│   │   └── driver_type.dart           # DriverType enum
│   └── platform/
│       ├── flutter_h2_platform.dart   # Platform interface
│       └── flutter_h2_method_channel.dart # MethodChannel impl
```

### Library Export (flutter_h2.dart)

```dart
library flutter_h2;

// Main API - compatible with vpnclient_engine_flutter
export 'src/vpnclient_engine.dart';

// Models
export 'src/models/connection_status.dart';
export 'src/models/connection_stats.dart';
export 'src/models/config.dart';
export 'src/models/core_type.dart';
export 'src/models/driver_type.dart';
```

### VpnClientEngine Class

```dart
class VpnClientEngine {
  static const MethodChannel _channel = MethodChannel('flutter_h2');

  static VpnClientEngine? _instance;

  // State
  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionStats _stats = const ConnectionStats();
  int _socksPort = 0;

  // Callbacks
  LogCallback? _logCallback;
  StatusCallback? _statusCallback;
  StatsCallback? _statsCallback;

  // Streams
  StreamController<ConnectionStatus>? _statusStreamController;
  StreamController<ConnectionStats>? _statsStreamController;
  StreamController<Map<String, String>>? _logStreamController;

  // Config
  VpnEngineConfig? _config;
  Timer? _statsTimer;

  VpnClientEngine._() {
    _setupMethodCallHandler();
  }

  /// Singleton instance
  static VpnClientEngine get instance {
    _instance ??= VpnClientEngine._();
    return _instance!;
  }

  /// Initialize with configuration
  Future<bool> initialize(VpnEngineConfig config) async {
    _config = config;

    // Extract server address from config
    String serverAddr = _extractServerAddress(config);
    String cryptoProvider = config.core.protocol ?? 'us';

    try {
      final result = await _channel.invokeMethod<bool>('initialize', {
        'serverAddr': serverAddr,
        'cryptoProvider': cryptoProvider,
      });

      if (result == true) {
        _log('INFO', 'H2 Engine initialized');
        _log('INFO', 'Server: $serverAddr');
      }
      return result ?? false;
    } catch (e) {
      _log('ERROR', 'Failed to initialize: $e');
      return false;
    }
  }

  /// Connect to VPN (starts SOCKS5 proxy)
  Future<bool> connect() async {
    if (_config == null) {
      _log('ERROR', 'Engine not initialized');
      return false;
    }

    try {
      _updateStatus(ConnectionStatus.connecting);
      _log('INFO', 'Connecting...');

      final port = await _channel.invokeMethod<int>('connect');

      if (port != null && port > 0) {
        _socksPort = port;
        _updateStatus(ConnectionStatus.connected);
        _log('INFO', 'Connected. SOCKS5 proxy at 127.0.0.1:$port');
        _startStatsPolling();
        return true;
      } else {
        _updateStatus(ConnectionStatus.error);
        _log('ERROR', 'Failed to connect');
        return false;
      }
    } catch (e) {
      _log('ERROR', 'Connection error: $e');
      _updateStatus(ConnectionStatus.error);
      return false;
    }
  }

  /// Disconnect from VPN
  Future<void> disconnect() async {
    try {
      _updateStatus(ConnectionStatus.disconnecting);
      _log('INFO', 'Disconnecting...');

      await _channel.invokeMethod('disconnect');

      _socksPort = 0;
      _updateStatus(ConnectionStatus.disconnected);
      _log('INFO', 'Disconnected');
      _stopStatsPolling();
    } catch (e) {
      _log('ERROR', 'Disconnect error: $e');
      _updateStatus(ConnectionStatus.disconnected);
    }
  }

  /// Get SOCKS5 proxy port (h2-specific)
  int getSocksPort() => _socksPort;

  /// Current status
  ConnectionStatus get status => _status;

  /// Current stats
  ConnectionStats get stats => _stats;

  /// Status stream
  Stream<ConnectionStatus> get statusStream {
    _statusStreamController ??= StreamController<ConnectionStatus>.broadcast();
    return _statusStreamController!.stream;
  }

  /// Stats stream
  Stream<ConnectionStats> get statsStream {
    _statsStreamController ??= StreamController<ConnectionStats>.broadcast();
    return _statsStreamController!.stream;
  }

  /// Log stream
  Stream<Map<String, String>> get logStream {
    _logStreamController ??= StreamController<Map<String, String>>.broadcast();
    return _logStreamController!.stream;
  }

  // Callbacks
  void setLogCallback(LogCallback callback) => _logCallback = callback;
  void setStatusCallback(StatusCallback callback) => _statusCallback = callback;
  void setStatsCallback(StatsCallback callback) => _statsCallback = callback;

  /// Get core name
  Future<String> getCoreName() async => 'h2.core';

  /// Get core version
  Future<String> getCoreVersion() async {
    try {
      return await _channel.invokeMethod<String>('getVersion') ?? '0.1.0';
    } catch (_) {
      return '0.1.0';
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    _stopStatsPolling();
    await _statusStreamController?.close();
    await _statsStreamController?.close();
    await _logStreamController?.close();
  }

  // Private methods

  String _extractServerAddress(VpnEngineConfig config) {
    // Try serverAddress first
    if (config.core.serverAddress != null) {
      final port = config.core.serverPort ?? 443;
      return '${config.core.serverAddress}:$port';
    }
    // Try parsing configJson
    // ... parse JSON for address
    return '';
  }

  void _startStatsPolling() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(Duration(seconds: 1), (_) => _updateStats());
  }

  void _stopStatsPolling() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  Future<void> _updateStats() async {
    try {
      final data = await _channel.invokeMethod<Map>('getStats');
      if (data != null) {
        _stats = ConnectionStats(
          bytesSent: data['bytesOut'] as int? ?? 0,
          bytesReceived: data['bytesIn'] as int? ?? 0,
        );
        _statsCallback?.call(_stats);
        _statsStreamController?.add(_stats);
      }
    } catch (_) {}
  }

  void _updateStatus(ConnectionStatus status) {
    _status = status;
    _statusCallback?.call(status);
    _statusStreamController?.add(status);
  }

  void _log(String level, String message) {
    _logCallback?.call(level, message);
    _logStreamController?.add({'level': level, 'message': message});
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStatusChanged':
          _updateStatus(ConnectionStatus.fromString(call.arguments as String));
          break;
        case 'onLog':
          final data = Map<String, dynamic>.from(call.arguments as Map);
          _log(data['level'] as String, data['message'] as String);
          break;
      }
    });
  }
}
```

### Models

Models are copied from vpnclient_engine_flutter with minimal changes:

**ConnectionStatus** - identical
**ConnectionStats** - identical
**VpnEngineConfig/CoreConfig/DriverConfig** - identical (driver config ignored by h2)
**CoreType** - add `h2` value:

```dart
enum CoreType {
  xray,
  v2ray,
  sing,
  h2,  // Added for h2.core
  custom;
  // ...
}
```

## iOS Platform Layer

### FlutterH2Plugin.swift

```swift
import Flutter
import H2Core  // gomobile framework

public class FlutterH2Plugin: NSObject, FlutterPlugin {
    private var client: MobileClient?
    private var channel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_h2",
            binaryMessenger: registrar.messenger()
        )
        let instance = FlutterH2Plugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "connect":
            handleConnect(result: result)
        case "disconnect":
            handleDisconnect(result: result)
        case "getStats":
            handleGetStats(result: result)
        case "getVersion":
            result(MobileVersion())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let serverAddr = args["serverAddr"] as? String else {
            result(false)
            return
        }

        let cryptoProvider = args["cryptoProvider"] as? String ?? "us"
        client = MobileNewClient(serverAddr, cryptoProvider)
        result(client != nil)
    }

    private func handleConnect(result: @escaping FlutterResult) {
        guard let client = client else {
            result(-1)
            return
        }

        do {
            var port: Int = 0
            try client.start(&port)
            result(port)
        } catch {
            result(-1)
        }
    }

    private func handleDisconnect(result: @escaping FlutterResult) {
        do {
            try client?.stop()
            result(nil)
        } catch {
            result(FlutterError(code: "DISCONNECT_ERROR", message: error.localizedDescription, details: nil))
        }
    }

    private func handleGetStats(result: @escaping FlutterResult) {
        guard let client = client else {
            result(nil)
            return
        }

        let stats = client.getStats()
        result([
            "bytesIn": stats?.bytesIn ?? 0,
            "bytesOut": stats?.bytesOut ?? 0,
            "connCount": stats?.connCount ?? 0,
            "running": stats?.running ?? false,
            "socksPort": stats?.socksPort ?? 0
        ])
    }
}
```

### Podspec Update

```ruby
Pod::Spec.new do |s|
  s.name             = 'flutter_h2'
  s.version          = '0.0.1'
  s.summary          = 'H2 VPN Engine for Flutter'
  s.description      = 'Flutter plugin for h2.core HTTPS VPN'
  s.homepage         = 'https://github.com/vpnclient/flutter_h2'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'NativeMind' => 'dev@nativemind.net' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '13.0'

  # H2Core framework
  s.vendored_frameworks = 'Frameworks/H2Core.xcframework'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
```

## Android Platform Layer

### FlutterH2Plugin.kt

```kotlin
package net.nativemind.h2.core.flutter_h2

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import mobile.Mobile
import mobile.Client

class FlutterH2Plugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var client: Client? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_h2")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "connect" -> handleConnect(result)
            "disconnect" -> handleDisconnect(result)
            "getStats" -> handleGetStats(result)
            "getVersion" -> result.success(Mobile.version())
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val serverAddr = call.argument<String>("serverAddr") ?: ""
        val cryptoProvider = call.argument<String>("cryptoProvider") ?: "us"

        client = Mobile.newClient(serverAddr, cryptoProvider)
        result.success(client != null)
    }

    private fun handleConnect(result: Result) {
        try {
            val port = client?.start() ?: -1
            result.success(port.toInt())
        } catch (e: Exception) {
            result.success(-1)
        }
    }

    private fun handleDisconnect(result: Result) {
        try {
            client?.stop()
            result.success(null)
        } catch (e: Exception) {
            result.error("DISCONNECT_ERROR", e.message, null)
        }
    }

    private fun handleGetStats(result: Result) {
        val stats = client?.stats
        if (stats != null) {
            result.success(mapOf(
                "bytesIn" to stats.bytesIn,
                "bytesOut" to stats.bytesOut,
                "connCount" to stats.connCount,
                "running" to stats.running,
                "socksPort" to stats.socksPort
            ))
        } else {
            result.success(null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        try { client?.stop() } catch (_: Exception) {}
        client = null
    }
}
```

### build.gradle Update

```gradle
dependencies {
    implementation files('libs/h2core.aar')
}
```

## Method Channel Protocol

| Method | Arguments | Return | Description |
|--------|-----------|--------|-------------|
| `initialize` | `{serverAddr: String, cryptoProvider: String}` | `bool` | Create h2 client |
| `connect` | - | `int` | Start client, return SOCKS port |
| `disconnect` | - | `void` | Stop client |
| `getStats` | - | `Map` | Get stats (bytesIn, bytesOut, etc) |
| `getVersion` | - | `String` | Get h2.core version |

### Native -> Dart Callbacks

| Method | Arguments | Description |
|--------|-----------|-------------|
| `onStatusChanged` | `String` | Status change notification |
| `onLog` | `{level: String, message: String}` | Log message |

## Build Integration

### iOS

1. Build H2Core.xcframework:
   ```bash
   cd vendors/h2.core
   ./build/mobile.sh ios
   ```

2. Copy to plugin:
   ```bash
   cp -r dist/mobile/H2Core.xcframework engines/flutter_h2/ios/Frameworks/
   ```

### Android

1. Build h2core.aar:
   ```bash
   cd vendors/h2.core
   ./build/mobile.sh android
   ```

2. Copy to plugin:
   ```bash
   cp dist/mobile/h2core.aar engines/flutter_h2/android/libs/
   ```

## Migration Guide

### From vpnclient_engine_flutter to flutter_h2

1. **Change import:**
   ```dart
   // Before
   import 'package:vpnclient_engine_flutter/vpnclient_engine.dart';

   // After
   import 'package:flutter_h2/flutter_h2.dart';
   ```

2. **Configure SOCKS5 proxy (new requirement):**
   ```dart
   final engine = VpnClientEngine.instance;
   await engine.initialize(config);
   await engine.connect();

   // Get SOCKS5 proxy port
   final port = engine.getSocksPort();

   // Configure HTTP client to use proxy
   final httpClient = HttpClient();
   httpClient.findProxy = (uri) => 'SOCKS5 127.0.0.1:$port';
   ```

3. **Note:** h2.core uses SOCKS5 proxy model, not TUN. Apps must configure their HTTP clients to use the local proxy.

## Test Plan

1. **Unit Tests (Dart)**
   - VpnClientEngine singleton behavior
   - Status transitions
   - Stats formatting
   - Config parsing

2. **Integration Tests**
   - Initialize with valid config
   - Connect returns valid port
   - Stats update after connect
   - Disconnect cleans up

3. **Platform Tests**
   - iOS: H2Core framework loads
   - Android: h2core.aar loads
   - Method channel communication works
