# Requirements: swift-h2

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-16

## Problem Statement

iOS applications need to use h2.core HTTPS VPN. Since h2.core is written in Go, we need a gomobile wrapper that produces an iOS-compatible framework (H2Core.xcframework).

## User Stories

### Primary

**As an** iOS developer
**I want** an H2Core.xcframework
**So that** I can integrate h2.core HTTPS VPN into my iOS app

**As a** Flutter plugin developer
**I want** H2Core.xcframework with a simple API
**So that** flutter_h2 can call it via platform channels

## Acceptance Criteria

### Must Have

1. **Given** gomobile installed
   **When** running `build/gomobile.sh ios`
   **Then** H2Core.xcframework is produced in `dist/`

2. **Given** the framework
   **When** imported in Swift
   **Then** `MobileNewClient(serverAddr, cryptoProvider)` is available

3. **Given** a Client instance
   **When** calling `client.start()`
   **Then** returns local SOCKS5 port number

4. **Given** a running client
   **When** calling `client.stop()`
   **Then** cleanly shuts down the connection

## API Surface

```swift
import H2Core

// Create client
let client = MobileNewClient("vpn.example.com:443", "us")

// Connect - returns SOCKS5 port
let port = try client?.start()

// Check status
let running = client?.isRunning() ?? false

// Get stats JSON
let stats = client?.getStatsJSON()

// Disconnect
try client?.stop()
```

## Constraints

- **Gomobile types only**: string, int, int64, bool, []byte, error
- **No complex types**: No maps, channels, or interfaces in public API
- **Thread-safe**: All methods must be safe to call from any thread

## Dependencies

- h2.core: `github.com/vpnclient/https-vpn`
- gomobile: `golang.org/x/mobile/cmd/gomobile`

## References

- Source: `wrappers/gomobile/client.go`
- Build: `build/gomobile.sh`

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-05-16
