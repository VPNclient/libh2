# Requirements: flutter-h2

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-15

## Problem Statement

Flutter applications need a high-level API to use h2.core HTTPS VPN. The plugin should wrap the gomobile-compiled H2Core.xcframework (iOS) and h2core.aar (Android), providing a Dart API compatible with existing vpnclient_engine_flutter.

## User Stories

### Primary

**As a** Flutter developer
**I want** a flutter_h2 plugin with same API as vpnclient_engine_flutter
**So that** I can switch to h2.core by changing one import

**As a** Flutter developer
**I want** access to the SOCKS5 proxy port
**So that** I can configure HTTP clients to route traffic through h2.core

## Acceptance Criteria

### Must Have

1. **Given** flutter_h2 imported
   **When** accessing `VpnClientEngine.instance`
   **Then** singleton instance is returned

2. **Given** initialized engine
   **When** calling `connect()`
   **Then** SOCKS5 proxy starts and `getSocksPort()` returns port

3. **Given** active connection
   **When** subscribing to `statusStream`
   **Then** connection status updates are emitted

4. **Given** active connection
   **When** subscribing to `statsStream`
   **Then** traffic statistics are emitted

## API Compatibility

```dart
// Same API as vpnclient_engine_flutter
import 'package:flutter_h2/flutter_h2.dart';

final engine = VpnClientEngine.instance;

await engine.initialize(config);
await engine.connect();

// H2-specific: get SOCKS5 port
final port = engine.getSocksPort();
// Configure HTTP: SOCKS5 127.0.0.1:$port

await engine.disconnect();
```

## Constraints

- **iOS/Android only**: Desktop not supported
- **SOCKS5 model**: Unlike TUN-based engines, provides local proxy
- **No TUN**: App must configure HTTP client to use SOCKS5 proxy

## Dependencies

- H2Core.xcframework (from sdd-swift-h2)
- h2core.aar (from sdd-kotlin-h2)

## References

- Implementation: `wrappers/flutter_h2/`
- Tests: `wrappers/flutter_h2/test/`

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-05-15
