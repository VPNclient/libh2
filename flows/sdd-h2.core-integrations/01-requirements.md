# Requirements: h2.core Integrations

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-14

## Problem Statement

h2.core is currently a standalone CLI tool (`cmd/https-vpn`). To be useful in mobile apps, desktop applications, and as a library component, we need to expose h2.core's functionality through various integration interfaces.

Current state:
- ✅ CLI binary (`https-vpn run`, `https-vpn init`)
- ✅ Go API (`core.New()`, `core.Start()`, `core.Close()`)
- ❌ No C-API for native bindings
- ❌ No gomobile support for iOS/Android
- ❌ No HTTP/gRPC control API
- ❌ No library build (.so/.dylib/.a)

## User Stories

### Primary: Mobile Integration

**As a** mobile app developer using vpnclient_engine_flutter
**I want** to integrate h2.core as a VPN core
**So that** my users can connect via HTTPS VPN that evades DPI

### Secondary: Desktop Library

**As a** desktop application developer
**I want** to link h2.core as a shared library
**So that** I can embed HTTPS VPN functionality without process management

### Tertiary: Remote Management

**As a** system administrator
**I want** an HTTP API to control h2.core instances
**So that** I can manage VPN servers programmatically

## Integration Types

### 1. C-API (CGO Export)

Expose h2.core functions via C-compatible API for FFI bindings.

```c
// Proposed C API
typedef void* H2Instance;

H2Instance h2_create(const char* config_json);
int h2_start(H2Instance instance);
int h2_stop(H2Instance instance);
void h2_destroy(H2Instance instance);
const char* h2_version();
const char* h2_get_stats(H2Instance instance);
```

**Use cases:**
- vpnclient_engine_flutter (via dart:ffi → C++)
- Python bindings (via ctypes/cffi)
- Ruby, Node.js FFI bindings

### 2. Gomobile Library

Build h2.core as iOS Framework / Android AAR via gomobile.

```go
// Proposed gomobile-friendly API (mobile package)
package mobile

func NewClient(configJSON string) (*Client, error)
func (c *Client) Start() error
func (c *Client) Stop() error
func (c *Client) GetStats() string
```

**Use cases:**
- Native iOS apps (Swift/Objective-C)
- Native Android apps (Kotlin/Java)
- React Native (via native modules)
- Flutter (via platform channels)

### 3. HTTP Control API

REST API for managing h2.core instances.

```
POST   /api/v1/start        - Start VPN with config
POST   /api/v1/stop         - Stop VPN
GET    /api/v1/status       - Get current status
GET    /api/v1/stats        - Get traffic statistics
```

**Use cases:**
- Remote management dashboards
- Kubernetes/Docker orchestration
- CLI tools communicating with daemon

### 4. Process-Based Integration (Current)

Spawn `https-vpn` binary as child process, communicate via:
- Command-line arguments
- stdout/stderr for logs
- Unix signals for control

**Use cases:**
- Quick integration without library compilation
- Sandboxed execution
- Crash isolation

## Acceptance Criteria

### Must Have

1. **C-API Export**
   - `h2_create()`, `h2_start()`, `h2_stop()`, `h2_destroy()` functions
   - Build as shared library (.so, .dylib)
   - Works with vpnclient_engine_flutter FFI

2. **Gomobile Build**
   - Build iOS Framework
   - Build Android AAR
   - Simple API suitable for mobile

3. **Version & Stats API**
   - `h2_version()` returns version string
   - `h2_get_stats()` returns JSON stats

### Should Have

4. **HTTP Control API**
   - Start/stop via HTTP
   - Status and stats endpoints
   - Optional TLS for control API

5. **Client Mode Support**
   - Not just server mode - client mode for mobile use
   - SOCKS5 local proxy interface

### Won't Have (This Iteration)

- gRPC API (HTTP sufficient for now)
- Prometheus metrics endpoint
- Hot config reload
- Multiple simultaneous instances

## Constraints

- **Technical**: CGO required for C-API, adds build complexity
- **Platform**: gomobile limits to iOS/Android; C-API works everywhere
- **Size**: gomobile binaries tend to be large (~10-20MB)
- **Compatibility**: Must maintain existing CLI interface

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         h2.core                                  │
├─────────────────────────────────────────────────────────────────┤
│  core/              │  transport/        │  crypto/             │
│  (Instance API)     │  (H2Server,Client) │  (providers)         │
├─────────────────────────────────────────────────────────────────┤
│                    Integration Layer                             │
├────────────┬────────────┬────────────┬────────────┬─────────────┤
│  C-API     │  gomobile  │  HTTP API  │  CLI       │  (future)   │
│  (cgo/)    │  (mobile/) │  (api/)    │  (cmd/)    │             │
└────────────┴────────────┴────────────┴────────────┴─────────────┘
        │           │            │            │
        ▼           ▼            ▼            ▼
   .so/.dylib   .framework   localhost   subprocess
   FFI bindings   /AAR        :8080       mgmt
```

## File Structure Proposal

```
h2.core/
├── core/           # Existing - main Instance API
├── transport/      # Existing - H2Server, H2Client
├── crypto/         # Existing - crypto providers
├── infra/conf/     # Existing - config parsing
├── cmd/https-vpn/  # Existing - CLI
├── cgo/            # NEW - C-API exports
│   ├── h2.go       # CGO export functions
│   └── h2.h        # C header
├── mobile/         # NEW - gomobile package
│   ├── client.go   # Mobile-friendly API
│   └── doc.go      # Package docs
├── api/            # NEW - HTTP control API
│   ├── server.go   # HTTP server
│   └── handlers.go # API handlers
└── build/
    ├── unix.sh     # Existing
    ├── cgo.sh      # NEW - Build shared library
    └── mobile.sh   # NEW - Build iOS/Android
```

## Open Questions

- [ ] Should C-API support both client and server modes?
- [ ] What stats should `h2_get_stats()` return? (bytes in/out, connections, etc.)
- [ ] Should gomobile build include all crypto providers or be configurable?
- [ ] HTTP API authentication mechanism?

## Priority Order

1. **C-API** (highest) - Required for vpnclient_engine_flutter
2. **Gomobile** (high) - Required for native mobile apps
3. **HTTP API** (medium) - Nice-to-have for management
4. **Process-based** (existing) - Already works

## References

- h2.core README: `README.md`
- vpnclient_engine_flutter: `engines/vpnclient_engine_flutter/`
- gomobile docs: https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile
- CGO docs: https://pkg.go.dev/cmd/cgo

---

## Approval

- [ ] Reviewed by: User
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
