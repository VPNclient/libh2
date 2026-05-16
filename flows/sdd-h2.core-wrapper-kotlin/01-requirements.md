# Requirements: kotlin-h2

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-16

## Problem Statement

Android applications need to use h2.core HTTPS VPN. Since h2.core is written in Go, we need a gomobile wrapper that produces an Android-compatible AAR library (h2core.aar).

## User Stories

### Primary

**As an** Android developer
**I want** an h2core.aar library
**So that** I can integrate h2.core HTTPS VPN into my Android app

**As a** Flutter plugin developer
**I want** h2core.aar with a simple API
**So that** flutter_h2 can call it via platform channels

## Acceptance Criteria

### Must Have

1. **Given** gomobile installed
   **When** running `build/gomobile.sh android`
   **Then** h2core.aar is produced in `dist/`

2. **Given** the AAR library
   **When** imported in Kotlin
   **Then** `Mobile.newClient(serverAddr, cryptoProvider)` is available

3. **Given** a Client instance
   **When** calling `client.start()`
   **Then** returns local SOCKS5 port number

4. **Given** a running client
   **When** calling `client.stop()`
   **Then** cleanly shuts down the connection

## API Surface

```kotlin
import mobile.Mobile

// Create client
val client = Mobile.newClient("vpn.example.com:443", "us")

// Connect - returns SOCKS5 port
val port = client.start()

// Check status
val running = client.isRunning

// Get stats JSON
val stats = client.statsJSON

// Disconnect
client.stop()
```

## Constraints

- **Gomobile types only**: String, Long, Boolean, ByteArray, Exception
- **No complex types**: No maps, channels, or interfaces in public API
- **Thread-safe**: All methods must be safe to call from any thread
- **Min SDK**: Android API 21+ (Android 5.0)

## Dependencies

- h2.core: `github.com/vpnclient/https-vpn`
- gomobile: `golang.org/x/mobile/cmd/gomobile`
- Android NDK (for gomobile bind)

## References

- Source: `wrappers/gomobile/client.go`
- Build: `build/gomobile.sh`

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-05-16
