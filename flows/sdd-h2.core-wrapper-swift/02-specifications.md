# Specifications: swift-h2

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-16

## Overview

iOS gomobile wrapper for h2.core, producing H2Core.xcframework.

## Architecture

```
wrappers/gomobile/
├── doc.go          # Package documentation
├── client.go       # Client struct + methods
├── socks.go        # SOCKS5 implementation
└── go.mod          # Module with h2.core dependency
        │
        ▼
  gomobile bind -target=ios
        │
        ▼
dist/H2Core.xcframework/
├── ios-arm64/
│   └── H2Core.framework/
├── ios-arm64_x86_64-simulator/
│   └── H2Core.framework/
└── Info.plist
```

## Go Source API

**Package**: `mobile`

```go
// Version returns h2.core version
func Version() string

// Client represents VPN client
type Client struct { ... }

// NewClient creates client instance
func NewClient(serverAddr, cryptoProvider string) *Client

// Start connects and returns SOCKS5 port
func (c *Client) Start() (int, error)

// Stop disconnects
func (c *Client) Stop() error

// IsRunning returns connection state
func (c *Client) IsRunning() bool

// GetSocksPort returns local proxy port
func (c *Client) GetSocksPort() int

// GetStatsJSON returns stats as JSON string
func (c *Client) GetStatsJSON() string

// Stats struct for statistics
type Stats struct {
    Running    bool
    SocksPort  int
    BytesIn    int64
    BytesOut   int64
    ConnCount  int64
    ServerAddr string
}
```

## Swift API (Generated)

```swift
import H2Core

// Module: Mobile
public class MobileClient : NSObject {
    public func start() throws -> Int
    public func stop() throws
    public var isRunning: Bool { get }
    public var socksPort: Int { get }
    public var statsJSON: String { get }
}

public func MobileNewClient(_ serverAddr: String?, _ cryptoProvider: String?) -> MobileClient?
public func MobileVersion() -> String
```

## Build Process

### Prerequisites

```bash
# Install gomobile
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

# Xcode Command Line Tools
xcode-select --install
```

### Build Command

```bash
cd wrappers/gomobile
gomobile bind \
    -target=ios \
    -o ../../dist/H2Core.xcframework \
    .
```

### Build Script

**File**: `build/gomobile.sh ios`

```bash
#!/bin/bash
cd wrappers/gomobile
gomobile bind -target=ios -o ../../dist/H2Core.xcframework .
```

## Integration

### Podspec (for flutter_h2)

```ruby
Pod::Spec.new do |s|
  s.name             = 'flutter_h2'
  s.vendored_frameworks = 'Frameworks/H2Core.xcframework'
end
```

### Direct Swift Usage

```swift
import H2Core

let client = MobileNewClient("vpn.example.com:443", "us")
let port = try client?.start()
// Configure URLSession proxy to 127.0.0.1:port
```

## Framework Structure

```
H2Core.xcframework/
├── Info.plist
├── ios-arm64/
│   └── H2Core.framework/
│       ├── H2Core (binary)
│       ├── Headers/
│       │   ├── H2Core.h
│       │   ├── Mobile.objc.h
│       │   └── Universe.objc.h
│       └── Modules/
│           └── module.modulemap
└── ios-arm64_x86_64-simulator/
    └── H2Core.framework/
        └── ... (same structure)
```

## Constraints

| Constraint | Details |
|------------|---------|
| Min iOS | 12.0 |
| Architectures | arm64 (device), arm64+x86_64 (simulator) |
| Bitcode | Not supported by gomobile |
| Swift version | Any (Obj-C bridge) |

## Edge Cases

| Case | Handling |
|------|----------|
| nil serverAddr | Return nil from NewClient |
| Empty cryptoProvider | Default to "us" |
| Start() when running | Return existing port, no error |
| Stop() when stopped | No-op, return nil |

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-05-16
