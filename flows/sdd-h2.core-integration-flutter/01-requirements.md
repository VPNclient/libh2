# Requirements: flutter_h2 - Drop-in Replacement for vpnclient_engine_flutter

## Overview

Create `engines/flutter_h2` Flutter plugin that provides the exact same API as `vpnclient_engine_flutter` but internally uses gomobile-compiled h2.core for VPN connectivity via HTTPS/H2 tunnel.

## Goals

1. **API Compatibility**: Same class names, methods, callbacks, streams as vpnclient_engine_flutter
2. **Seamless Substitution**: Apps can switch by changing only the package import
3. **H2 Core Backend**: Use gomobile-compiled h2.core for actual VPN tunnel
4. **Cross-Platform**: iOS and Android support via gomobile bindings

## Non-Goals

- Desktop support (macOS/Windows/Linux) - deferred
- Full feature parity with v2ray/xray cores - h2.core is simpler
- TUN driver integration - h2.core uses SOCKS5 proxy model

## User Stories

### US-1: Drop-in Replacement

**As a** Flutter developer using vpnclient_engine_flutter
**I want to** switch to flutter_h2 by changing only the import
**So that** I can use h2.core without rewriting my app

**Acceptance Criteria:**
- Same package exports: `VpnClientEngine`, `ConnectionStatus`, `ConnectionStats`, etc.
- Same singleton pattern: `VpnClientEngine.instance`
- Same lifecycle: `initialize()`, `connect()`, `disconnect()`, `dispose()`
- Same streams: `statusStream`, `statsStream`, `logStream`
- Same callbacks: `LogCallback`, `StatusCallback`, `StatsCallback`

### US-2: H2 Core Configuration

**As a** developer
**I want to** configure h2.core via VpnEngineConfig
**So that** I can use the familiar configuration model

**Acceptance Criteria:**
- Accept `VpnEngineConfig` in `initialize()`
- Extract server address from `core.serverAddress` or `core.configJson`
- Map crypto provider from config (default: "us")
- Ignore TUN/driver config (h2.core uses SOCKS5)

### US-3: Connection Lifecycle

**As a** developer
**I want to** connect/disconnect using familiar methods
**So that** my existing code works unchanged

**Acceptance Criteria:**
- `connect()` starts h2.core client and SOCKS5 proxy
- `disconnect()` stops h2.core client
- Status transitions: disconnected -> connecting -> connected (or error)
- Status available via `status` getter and `statusStream`

### US-4: Connection Statistics

**As a** developer
**I want to** get connection stats via `stats` and `statsStream`
**So that** I can display traffic info to users

**Acceptance Criteria:**
- `stats` returns `ConnectionStats` with bytesIn/bytesOut
- `statsStream` emits updates periodically (every 1 second)
- Stats include: bytesSent, bytesReceived (from h2.core)
- Latency and packet counts may be 0 (h2.core doesn't track these)

### US-5: SOCKS5 Proxy Info

**As a** developer
**I want to** get the local SOCKS5 proxy port
**So that** I can configure my app to use it

**Acceptance Criteria:**
- New method: `getSocksPort()` returns local proxy port
- Returns 0 if not connected
- SOCKS5 proxy is at `127.0.0.1:port`

### US-6: Logging

**As a** developer
**I want to** receive logs via callback and stream
**So that** I can debug connection issues

**Acceptance Criteria:**
- `setLogCallback(callback)` registers log handler
- `logStream` emits log entries as `Map<String, String>`
- Log levels: INFO, WARN, ERROR
- Logs include connection events, errors

## Technical Constraints

### TC-1: Gomobile Integration
- iOS: Use H2Core.xcframework via CocoaPods
- Android: Use h2core.aar via Gradle
- Flutter: Use platform channels to communicate with native code

### TC-2: API Mapping

| vpnclient_engine_flutter | flutter_h2 (h2.core) |
|-------------------------|----------------------|
| VpnEngineConfig.core.serverAddress | mobile.NewClient(serverAddr, ...) |
| VpnEngineConfig.core.configJson | Parse for server address |
| VpnEngineConfig.driver | Ignored (SOCKS5 model) |
| connect() | client.Start() -> returns SOCKS5 port |
| disconnect() | client.Stop() |
| stats.bytesSent | client.GetStats().BytesOut |
| stats.bytesReceived | client.GetStats().BytesIn |

### TC-3: Architecture Difference

**vpnclient_engine_flutter**:
```
App -> TUN device -> VPN Core -> Server
```

**flutter_h2**:
```
App -> SOCKS5 Proxy (127.0.0.1:port) -> H2 Client -> Server
```

Apps need to configure their HTTP clients to use the SOCKS5 proxy.

## Simplified API Surface

Required exports (matching vpnclient_engine_flutter):

```dart
// Main class
class VpnClientEngine {
  static VpnClientEngine get instance;

  Future<bool> initialize(VpnEngineConfig config);
  Future<bool> connect();
  Future<void> disconnect();
  Future<void> dispose();

  ConnectionStatus get status;
  ConnectionStats get stats;

  Stream<ConnectionStatus> get statusStream;
  Stream<ConnectionStats> get statsStream;
  Stream<Map<String, String>> get logStream;

  void setLogCallback(LogCallback callback);
  void setStatusCallback(StatusCallback callback);
  void setStatsCallback(StatsCallback callback);

  Future<String> getCoreName();
  Future<String> getCoreVersion();

  // H2-specific
  int getSocksPort();
}

// Reuse from vpnclient_engine_flutter
enum ConnectionStatus { disconnected, connecting, connected, disconnecting, error }
class ConnectionStats { bytesSent, bytesReceived, ... }
class VpnEngineConfig { core, driver, ... }
```

## Out of Scope

- Subscription management (can be added later)
- V2Ray URL parsing (not needed for h2.core)
- Server ping functionality
- Legacy API compatibility layer

## Dependencies

- `h2.core/mobile/` package compiled via gomobile
- iOS: H2Core.xcframework
- Android: h2core.aar
