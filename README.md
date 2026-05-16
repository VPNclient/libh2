# libh2

Mobile/Flutter wrappers for [h2.core](../h2.core) HTTPS VPN.

## Overview

libh2 provides platform-specific bindings for h2.core:

| Platform | Output | API |
|----------|--------|-----|
| iOS | `H2Core.xcframework` | Swift/ObjC |
| Android | `h2core.aar` | Kotlin/Java |
| Flutter | `flutter_h2` plugin | Dart |

## Architecture

```
libh2/
├── wrappers/
│   ├── gomobile/         # Go source for iOS/Android
│   │   ├── client.go     # Client API
│   │   ├── socks.go      # SOCKS5 proxy
│   │   └── go.mod        # Module with h2.core dependency
│   └── flutter_h2/       # Flutter plugin
│       ├── lib/          # Dart API
│       ├── ios/          # iOS plugin + H2Core.xcframework
│       └── android/      # Android plugin + h2core.aar
├── build/
│   ├── gomobile.sh       # Build iOS/Android frameworks
│   └── copy_to_flutter.sh
└── dist/                 # Build outputs
    ├── H2Core.xcframework
    └── h2core.aar
```

## Quick Start

### Prerequisites

```bash
# Go 1.21+
go version

# gomobile
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

# iOS: Xcode 15+
xcode-select --install

# Android: NDK (via Android Studio or standalone)
export ANDROID_NDK_HOME=/path/to/ndk
```

### Build

```bash
# iOS framework
./build/gomobile.sh ios
# Output: dist/H2Core.xcframework

# Android AAR
./build/gomobile.sh android
# Output: dist/h2core.aar

# Both
./build/gomobile.sh all

# Copy to Flutter plugin
./build/copy_to_flutter.sh
```

## API

### Go (gomobile)

```go
import "github.com/vpnclient/libh2/wrappers/gomobile"

// Create client
client := mobile.NewClient("vpn.example.com:443", "us")

// Connect - returns SOCKS5 port
port, err := client.Start()

// Check status
running := client.IsRunning()

// Get statistics
stats := client.GetStats()
// or JSON: client.GetStatsJSON()

// Disconnect
client.Stop()
```

### Swift (iOS)

```swift
import H2Core

// Create client
let client = MobileNewClient("vpn.example.com:443", "us")

// Connect
var error: NSError?
let port = client?.start(&error)

// Configure URLSession proxy
let config = URLSessionConfiguration.default
config.connectionProxyDictionary = [
    kCFProxyTypeKey: kCFProxyTypeSOCKS,
    kCFStreamPropertySOCKSProxyHost: "127.0.0.1",
    kCFStreamPropertySOCKSProxyPort: port
]

// Disconnect
client?.stop()
```

### Kotlin (Android)

```kotlin
import mobile.Mobile

// Create client
val client = Mobile.newClient("vpn.example.com:443", "us")

// Connect
val port = client.start()

// Configure OkHttp proxy
val proxy = Proxy(Proxy.Type.SOCKS, InetSocketAddress("127.0.0.1", port.toInt()))
val okhttp = OkHttpClient.Builder().proxy(proxy).build()

// Disconnect
client.stop()
```

### Flutter/Dart

See [flutter_h2/README.md](wrappers/flutter_h2/README.md)

## Crypto Providers

| Code | Region |
|------|--------|
| `us` | United States (default) |
| `ua` | Ukraine |
| `cn` | China |
| `th` | Thailand |
| `fr` | France |
| `uk` | United Kingdom |

## SOCKS5 Proxy Model

Unlike TUN-based VPNs, h2.core uses a local SOCKS5 proxy:

```
App → SOCKS5 (127.0.0.1:port) → h2.core → HTTPS/H2 → VPN Server → Internet
```

Benefits:
- No root/VPN permissions required
- Per-app routing (configure which apps use proxy)
- Works in restricted environments

Limitations:
- App must support SOCKS5 proxy configuration
- Not system-wide (unless using proxy PAC/WPAD)

## Statistics

```go
type Stats struct {
    Running    bool   // Connection state
    SocksPort  int    // Local proxy port
    BytesIn    int64  // Downloaded bytes
    BytesOut   int64  // Uploaded bytes
    ConnCount  int64  // Total connections handled
    ServerAddr string // VPN server address
}
```

## Dependencies

- [h2.core](../h2.core) - Core HTTPS VPN implementation
- [gomobile](https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile) - Go mobile bindings

## License

Proprietary - NativeMind
