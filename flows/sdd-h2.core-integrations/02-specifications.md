# Specifications: h2.core Integrations

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-14
> Requirements: [01-requirements.md](./01-requirements.md)

## Overview

This document specifies the technical design for h2.core integration interfaces:
1. **C-API** - CGO exports for FFI bindings
2. **Gomobile** - iOS/Android library
3. **HTTP API** - REST control interface

## 1. C-API Specification

### 1.1 Header File (`cgo/h2core.h`)

```c
#ifndef H2_CORE_H
#define H2_CORE_H

#ifdef __cplusplus
extern "C" {
#endif

// Opaque handle to h2.core instance
typedef void* H2Instance;

// Error codes
#define H2_OK              0
#define H2_ERR_NULL_PTR   -1
#define H2_ERR_INVALID    -2
#define H2_ERR_INIT       -3
#define H2_ERR_START      -4
#define H2_ERR_STOPPED    -5

// Instance lifecycle
H2Instance h2_create(const char* config_json);
int h2_start(H2Instance instance);
int h2_stop(H2Instance instance);
void h2_destroy(H2Instance instance);

// Information
const char* h2_version(void);
const char* h2_get_stats(H2Instance instance);
int h2_is_running(H2Instance instance);

// Client mode (for mobile VPN client use)
H2Instance h2_client_create(const char* server_addr, const char* crypto_provider);
int h2_client_connect(H2Instance instance);
int h2_client_disconnect(H2Instance instance);
int h2_client_get_socks_port(H2Instance instance);

// Memory management
void h2_free_string(const char* str);

#ifdef __cplusplus
}
#endif

#endif // H2_CORE_H
```

### 1.2 CGO Implementation (`cgo/h2.go`)

```go
package main

/*
#include <stdlib.h>
#include "h2core.h"
*/
import "C"
import (
    "encoding/json"
    "sync"
    "unsafe"

    "github.com/vpnclient/https-vpn/core"
    "github.com/vpnclient/https-vpn/infra/conf"
)

var (
    instances   = make(map[uintptr]*instanceWrapper)
    instancesMu sync.RWMutex
    nextID      uintptr = 1
)

type instanceWrapper struct {
    instance *core.Instance
    config   *conf.Config
    running  bool
    // Client mode fields
    isClient   bool
    socksPort  int
}

//export h2_create
func h2_create(configJSON *C.char) C.H2Instance {
    if configJSON == nil {
        return nil
    }

    cfg, err := conf.ParseConfig([]byte(C.GoString(configJSON)))
    if err != nil {
        return nil
    }

    inst, err := core.New(cfg)
    if err != nil {
        return nil
    }

    instancesMu.Lock()
    id := nextID
    nextID++
    instances[id] = &instanceWrapper{
        instance: inst,
        config:   cfg,
    }
    instancesMu.Unlock()

    return C.H2Instance(unsafe.Pointer(id))
}

//export h2_start
func h2_start(handle C.H2Instance) C.int {
    wrapper := getInstance(handle)
    if wrapper == nil {
        return C.H2_ERR_NULL_PTR
    }

    if err := wrapper.instance.Start(); err != nil {
        return C.H2_ERR_START
    }

    wrapper.running = true
    return C.H2_OK
}

//export h2_stop
func h2_stop(handle C.H2Instance) C.int {
    wrapper := getInstance(handle)
    if wrapper == nil {
        return C.H2_ERR_NULL_PTR
    }

    if err := wrapper.instance.Close(); err != nil {
        return C.H2_ERR_STOPPED
    }

    wrapper.running = false
    return C.H2_OK
}

//export h2_destroy
func h2_destroy(handle C.H2Instance) {
    id := uintptr(unsafe.Pointer(handle))

    instancesMu.Lock()
    delete(instances, id)
    instancesMu.Unlock()
}

//export h2_version
func h2_version() *C.char {
    return C.CString("0.1.0") // TODO: from build
}

//export h2_get_stats
func h2_get_stats(handle C.H2Instance) *C.char {
    wrapper := getInstance(handle)
    if wrapper == nil {
        return C.CString("{\"error\": \"invalid instance\"}")
    }

    stats := map[string]interface{}{
        "running": wrapper.running,
        // TODO: Add actual stats from instance
    }

    data, _ := json.Marshal(stats)
    return C.CString(string(data))
}

//export h2_is_running
func h2_is_running(handle C.H2Instance) C.int {
    wrapper := getInstance(handle)
    if wrapper == nil {
        return 0
    }
    if wrapper.running {
        return 1
    }
    return 0
}

//export h2_free_string
func h2_free_string(str *C.char) {
    C.free(unsafe.Pointer(str))
}

func getInstance(handle C.H2Instance) *instanceWrapper {
    id := uintptr(unsafe.Pointer(handle))
    instancesMu.RLock()
    defer instancesMu.RUnlock()
    return instances[id]
}

func main() {} // Required for CGO
```

### 1.3 Build Script (`build/cgo.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="${OUT_DIR:-dist}"
VERSION="${VERSION:-$(git describe --tags --always --dirty 2>/dev/null || echo "0.1.0-dev")}"

mkdir -p "$OUT_DIR"

build_shared() {
    local goos="$1"
    local goarch="$2"
    local ext="$3"
    local outfile="$OUT_DIR/libh2_${goos}_${goarch}${ext}"

    echo "Building $outfile"
    env CGO_ENABLED=1 GOOS="$goos" GOARCH="$goarch" \
        go build -buildmode=c-shared \
        -ldflags "-s -w -X main.Version=$VERSION" \
        -o "$outfile" ./cgo
}

# Detect host platform
case "$(uname -s)" in
    Darwin)
        build_shared darwin arm64 .dylib
        build_shared darwin amd64 .dylib
        ;;
    Linux)
        build_shared linux amd64 .so
        build_shared linux arm64 .so
        ;;
esac

# Copy header
cp cgo/h2core.h "$OUT_DIR/"

echo "Done. Outputs in $OUT_DIR/"
```

## 2. Gomobile Specification

### 2.1 Mobile Package (`mobile/client.go`)

```go
// Package mobile provides a gomobile-friendly API for h2.core.
// This package is designed to be built with gomobile for iOS/Android.
package mobile

import (
    "encoding/json"
    "fmt"
    "net"
    "sync"

    "github.com/vpnclient/https-vpn/transport"
)

// Client represents an h2.core VPN client for mobile platforms.
type Client struct {
    mu           sync.Mutex
    h2Client     *transport.H2Client
    socksServer  net.Listener
    running      bool
    serverAddr   string
    cryptoProvider string
    socksPort    int

    // Stats
    bytesIn      int64
    bytesOut     int64
}

// NewClient creates a new h2.core client.
// serverAddr: VPN server address (e.g., "vpn.example.com:443")
// cryptoProvider: crypto provider name (e.g., "us", "ua", "cn")
func NewClient(serverAddr, cryptoProvider string) *Client {
    return &Client{
        serverAddr:     serverAddr,
        cryptoProvider: cryptoProvider,
        socksPort:      0, // Will be assigned dynamically
    }
}

// Start connects to the VPN server and starts local SOCKS5 proxy.
// Returns the local SOCKS5 port number.
func (c *Client) Start() (int, error) {
    c.mu.Lock()
    defer c.mu.Unlock()

    if c.running {
        return c.socksPort, nil
    }

    // Create H2 client
    h2Client, err := transport.NewH2Client(&transport.ClientConfig{
        ServerAddr:     c.serverAddr,
        CryptoProvider: c.cryptoProvider,
    })
    if err != nil {
        return 0, fmt.Errorf("failed to create client: %w", err)
    }
    c.h2Client = h2Client

    // Start local SOCKS5 server
    listener, err := net.Listen("tcp", "127.0.0.1:0")
    if err != nil {
        return 0, fmt.Errorf("failed to start SOCKS server: %w", err)
    }
    c.socksServer = listener
    c.socksPort = listener.Addr().(*net.TCPAddr).Port

    // Start accepting connections
    go c.acceptLoop()

    c.running = true
    return c.socksPort, nil
}

// Stop disconnects from VPN and stops SOCKS5 proxy.
func (c *Client) Stop() error {
    c.mu.Lock()
    defer c.mu.Unlock()

    if !c.running {
        return nil
    }

    if c.socksServer != nil {
        c.socksServer.Close()
    }

    if c.h2Client != nil {
        c.h2Client.Close()
    }

    c.running = false
    return nil
}

// IsRunning returns true if client is connected.
func (c *Client) IsRunning() bool {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.running
}

// GetSocksPort returns the local SOCKS5 proxy port.
func (c *Client) GetSocksPort() int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.socksPort
}

// GetStats returns JSON-encoded statistics.
func (c *Client) GetStats() string {
    c.mu.Lock()
    defer c.mu.Unlock()

    stats := map[string]interface{}{
        "running":   c.running,
        "bytesIn":   c.bytesIn,
        "bytesOut":  c.bytesOut,
        "socksPort": c.socksPort,
    }

    data, _ := json.Marshal(stats)
    return string(data)
}

func (c *Client) acceptLoop() {
    for {
        conn, err := c.socksServer.Accept()
        if err != nil {
            return // Server closed
        }
        go c.handleSocksConnection(conn)
    }
}

func (c *Client) handleSocksConnection(clientConn net.Conn) {
    defer clientConn.Close()
    // TODO: Implement SOCKS5 protocol and tunnel via h2Client
}
```

### 2.2 Build Script (`build/mobile.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="${OUT_DIR:-dist/mobile}"
mkdir -p "$OUT_DIR"

# Check gomobile
if ! command -v gomobile &> /dev/null; then
    echo "Installing gomobile..."
    go install golang.org/x/mobile/cmd/gomobile@latest
    gomobile init
fi

echo "Building iOS framework..."
gomobile bind -target=ios -o "$OUT_DIR/H2Core.xcframework" ./mobile

echo "Building Android AAR..."
gomobile bind -target=android -o "$OUT_DIR/h2core.aar" ./mobile

echo "Done. Outputs in $OUT_DIR/"
```

## 3. HTTP API Specification

### 3.1 Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/start` | Start VPN with config |
| POST | `/api/v1/stop` | Stop VPN |
| GET | `/api/v1/status` | Get current status |
| GET | `/api/v1/stats` | Get traffic statistics |
| GET | `/api/v1/version` | Get version info |

### 3.2 Request/Response Schemas

#### POST /api/v1/start

Request:
```json
{
  "config": { /* xray-compatible config */ }
}
```

Response:
```json
{
  "success": true,
  "message": "VPN started",
  "socksPort": 1080
}
```

#### GET /api/v1/status

Response:
```json
{
  "running": true,
  "uptime": 3600,
  "serverAddr": "vpn.example.com:443",
  "cryptoProvider": "ua"
}
```

#### GET /api/v1/stats

Response:
```json
{
  "bytesIn": 1048576,
  "bytesOut": 524288,
  "connections": 5,
  "uptime": 3600
}
```

### 3.3 Implementation (`api/server.go`)

```go
package api

import (
    "encoding/json"
    "net/http"
    "sync"

    "github.com/vpnclient/https-vpn/core"
    "github.com/vpnclient/https-vpn/infra/conf"
)

type Server struct {
    mu       sync.Mutex
    instance *core.Instance
    httpSrv  *http.Server
}

func NewServer(addr string) *Server {
    s := &Server{}

    mux := http.NewServeMux()
    mux.HandleFunc("/api/v1/start", s.handleStart)
    mux.HandleFunc("/api/v1/stop", s.handleStop)
    mux.HandleFunc("/api/v1/status", s.handleStatus)
    mux.HandleFunc("/api/v1/stats", s.handleStats)
    mux.HandleFunc("/api/v1/version", s.handleVersion)

    s.httpSrv = &http.Server{
        Addr:    addr,
        Handler: mux,
    }

    return s
}

func (s *Server) Start() error {
    return s.httpSrv.ListenAndServe()
}
```

## 4. Directory Structure

```
h2.core/
├── core/               # Existing
├── transport/          # Existing
├── crypto/             # Existing
├── infra/conf/         # Existing
├── cmd/https-vpn/      # Existing CLI
│
├── cgo/                # NEW: C-API
│   ├── h2.go           # CGO exports
│   ├── h2core.h            # C header
│   └── client.go       # Client mode support
│
├── mobile/             # NEW: Gomobile
│   ├── client.go       # Mobile client API
│   ├── doc.go          # Package documentation
│   └── socks.go        # SOCKS5 implementation
│
├── api/                # NEW: HTTP API
│   ├── server.go       # HTTP server
│   ├── handlers.go     # Request handlers
│   └── middleware.go   # Auth, logging
│
├── build/
│   ├── unix.sh         # Existing
│   ├── cgo.sh          # NEW: Build .so/.dylib
│   └── mobile.sh       # NEW: Build iOS/Android
│
└── dist/
    ├── h2_linux_amd64      # Existing CLI
    ├── h2_linux_arm64      # Existing CLI
    ├── h2_macos_silicon    # Existing CLI
    ├── libh2_linux_amd64.so    # NEW: Shared lib
    ├── libh2_darwin_arm64.dylib # NEW: Shared lib
    ├── h2core.h                # NEW: C header
    └── mobile/
        ├── H2Core.xcframework  # NEW: iOS
        └── h2core.aar          # NEW: Android
```

## 5. Integration with vpnclient_engine_flutter

### 5.1 CMakeLists.txt Changes

```cmake
# In engines/vpnclient_engine_flutter/CMakeLists.txt

option(ENABLE_H2CORE "Enable h2.core" ON)

set(H2CORE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../vendors/h2.core)

if(ENABLE_H2CORE)
    list(APPEND CORE_IMPL_SOURCES src/cores/h2_core.cpp)
    add_compile_definitions(ENABLE_H2CORE)

    target_include_directories(${PROJECT_NAME} PRIVATE ${H2CORE_DIR}/dist)

    if(APPLE)
        target_link_libraries(${PROJECT_NAME} PRIVATE
            ${H2CORE_DIR}/dist/libh2_darwin_arm64.dylib)
    elseif(UNIX)
        target_link_libraries(${PROJECT_NAME} PRIVATE
            ${H2CORE_DIR}/dist/libh2_linux_${CMAKE_SYSTEM_PROCESSOR}.so)
    endif()
endif()
```

### 5.2 CoreType Extension

```dart
// In lib/src/models/core_type.dart

enum CoreType {
  singbox,
  libxray,
  v2ray,
  wireguard,
  h2core;  // NEW

  String toNativeString() {
    switch (this) {
      // ... existing cases
      case CoreType.h2core:
        return 'H2CORE';
    }
  }
}
```

### 5.3 EngineManager Update

```dart
// h2.core provides SOCKS5, needs TUN driver
static bool requiresDriver(CoreType core) {
  switch (core) {
    case CoreType.singbox:
    case CoreType.wireguard:
      return false;
    case CoreType.libxray:
    case CoreType.v2ray:
    case CoreType.h2core:  // NEW
      return true;
  }
}
```

## 6. Error Handling

### 6.1 Error Codes

| Code | Name | Description |
|------|------|-------------|
| 0 | H2_OK | Success |
| -1 | H2_ERR_NULL_PTR | Null pointer passed |
| -2 | H2_ERR_INVALID | Invalid parameter |
| -3 | H2_ERR_INIT | Initialization failed |
| -4 | H2_ERR_START | Start failed |
| -5 | H2_ERR_STOPPED | Already stopped |
| -6 | H2_ERR_CONFIG | Config parse error |
| -7 | H2_ERR_NETWORK | Network error |

### 6.2 Error Reporting

All C-API functions return error codes. Detailed error messages available via:

```c
const char* h2_get_last_error(void);
```

## 7. Thread Safety

- All C-API functions are thread-safe (protected by mutex)
- Instance handles are unique per-process
- Gomobile Client uses internal mutex for state
- HTTP API handlers are concurrent-safe

---

## Approval

- [ ] Reviewed by: User
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
