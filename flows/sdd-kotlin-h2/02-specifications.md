# Specifications: kotlin-h2

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-16

## Overview

Android gomobile wrapper for h2.core, producing h2core.aar.

## Architecture

```
wrappers/gomobile/
├── doc.go          # Package documentation
├── client.go       # Client struct + methods
├── socks.go        # SOCKS5 implementation
└── go.mod          # Module with h2.core dependency
        │
        ▼
  gomobile bind -target=android
        │
        ▼
dist/h2core.aar
├── classes.jar
├── jni/
│   ├── arm64-v8a/libgojni.so
│   ├── armeabi-v7a/libgojni.so
│   └── x86_64/libgojni.so
└── AndroidManifest.xml
```

## Go Source API

Same as swift-h2 (shared `wrappers/gomobile/` source).

```go
package mobile

func Version() string
func NewClient(serverAddr, cryptoProvider string) *Client

type Client struct { ... }
func (c *Client) Start() (int, error)
func (c *Client) Stop() error
func (c *Client) IsRunning() bool
func (c *Client) GetSocksPort() int
func (c *Client) GetStatsJSON() string
```

## Kotlin API (Generated)

```kotlin
package mobile

object Mobile {
    fun newClient(serverAddr: String, cryptoProvider: String): Client
    fun version(): String
}

class Client {
    fun start(): Long  // Returns port
    fun stop()
    val isRunning: Boolean
    val socksPort: Long
    val statsJSON: String
}
```

## Build Process

### Prerequisites

```bash
# Install gomobile
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

# Android NDK (via Android Studio or standalone)
export ANDROID_NDK_HOME=/path/to/ndk
```

### Build Command

```bash
cd wrappers/gomobile
gomobile bind \
    -target=android \
    -androidapi 21 \
    -o ../../dist/h2core.aar \
    .
```

### Build Script

**File**: `build/gomobile.sh android`

```bash
#!/bin/bash
cd wrappers/gomobile
gomobile bind -target=android -androidapi 21 -o ../../dist/h2core.aar .
```

## Integration

### Gradle (for flutter_h2)

```kotlin
// android/build.gradle.kts
dependencies {
    implementation(files("libs/h2core.aar"))
}
```

### Direct Kotlin Usage

```kotlin
import mobile.Mobile

val client = Mobile.newClient("vpn.example.com:443", "us")
val port = client.start()
// Configure OkHttp proxy to 127.0.0.1:port
```

## AAR Structure

```
h2core.aar (ZIP format)
├── AndroidManifest.xml
├── classes.jar
│   └── mobile/
│       ├── Mobile.class
│       ├── Client.class
│       └── Stats.class
├── jni/
│   ├── arm64-v8a/
│   │   └── libgojni.so
│   ├── armeabi-v7a/
│   │   └── libgojni.so
│   └── x86_64/
│       └── libgojni.so
├── R.txt
└── proguard.txt
```

## Constraints

| Constraint | Details |
|------------|---------|
| Min SDK | API 21 (Android 5.0) |
| ABIs | arm64-v8a, armeabi-v7a, x86_64 |
| Kotlin version | Any (Java interop) |
| ProGuard | Keep mobile.* classes |

## ProGuard Rules

```proguard
-keep class mobile.** { *; }
-keep class go.** { *; }
```

## Edge Cases

| Case | Handling |
|------|----------|
| null serverAddr | Throw exception |
| Empty cryptoProvider | Default to "us" |
| Start() when running | Return existing port |
| Stop() when stopped | No-op |
| Background thread | All methods thread-safe |

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-05-16
