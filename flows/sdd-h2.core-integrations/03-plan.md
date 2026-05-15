# Implementation Plan: h2.core Integrations

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-14
> Specifications: [02-specifications.md](./02-specifications.md)

## Summary

Implement integration interfaces for h2.core: C-API, Gomobile, and HTTP API. Priority order:
1. **C-API** (required for vpnclient_engine_flutter)
2. **Gomobile** (iOS/Android native apps)
3. **HTTP API** (management interface)

## Task Breakdown

### Phase 1: C-API Foundation (Priority: Highest)

#### Task 1.1: Create CGO Directory Structure

- **Description**: Set up cgo package with header and Go files
- **Files**:
  - `cgo/h2core.h` - Create: C header with API definitions
  - `cgo/h2core.go` - Create: CGO exports (main file)
  - `cgo/instance.go` - Create: Instance management
- **Complexity**: Low
- **Dependencies**: None

#### Task 1.2: Implement Core C-API Functions

- **Description**: Implement h2_create, h2_start, h2_stop, h2_destroy
- **Files**:
  - `cgo/h2core.go` - Modify: Add core lifecycle functions
- **Verification**: Unit test creates/starts/stops instance
- **Complexity**: Medium
- **Dependencies**: Task 1.1

#### Task 1.3: Implement Info Functions

- **Description**: Implement h2_version, h2_get_stats, h2_is_running
- **Files**:
  - `cgo/h2core.go` - Modify: Add info functions
- **Verification**: Version returns correct string, stats returns JSON
- **Complexity**: Low
- **Dependencies**: Task 1.2

#### Task 1.4: Implement Client Mode Functions

- **Description**: Implement h2_client_create, h2_client_connect, h2_client_disconnect
- **Files**:
  - `cgo/client.go` - Create: Client mode implementation
  - `cgo/socks.go` - Create: Local SOCKS5 proxy for client mode
- **Verification**: Client connects to test server, SOCKS5 port returned
- **Complexity**: High
- **Dependencies**: Task 1.2

#### Task 1.5: Create CGO Build Script

- **Description**: Build script for shared libraries (.so/.dylib)
- **Files**:
  - `build/cgo.sh` - Create: Build script
- **Verification**: Produces libh2core_*.so and libh2core_*.dylib
- **Complexity**: Low
- **Dependencies**: Task 1.4

#### Task 1.6: Test C-API

- **Description**: Create C test program to verify API
- **Files**:
  - `cgo/test/main.c` - Create: C test program
  - `cgo/test/Makefile` - Create: Build test
- **Verification**: Test program runs successfully
- **Complexity**: Medium
- **Dependencies**: Task 1.5

### Phase 2: Gomobile Library (Priority: High)

#### Task 2.1: Create Mobile Package

- **Description**: Set up mobile package with gomobile-friendly API
- **Files**:
  - `mobile/doc.go` - Create: Package documentation
  - `mobile/client.go` - Create: Mobile client struct and methods
- **Complexity**: Low
- **Dependencies**: None (can parallel with Phase 1)

#### Task 2.2: Implement Mobile Client

- **Description**: Implement NewClient, Start, Stop, GetStats
- **Files**:
  - `mobile/client.go` - Modify: Full implementation
- **Verification**: Can create client, start returns port
- **Complexity**: Medium
- **Dependencies**: Task 2.1

#### Task 2.3: Implement SOCKS5 Proxy for Mobile

- **Description**: Local SOCKS5 server that tunnels via H2Client
- **Files**:
  - `mobile/socks.go` - Create: SOCKS5 server implementation
- **Verification**: SOCKS5 proxy accepts connections
- **Complexity**: High
- **Dependencies**: Task 2.2

#### Task 2.4: Create Gomobile Build Script

- **Description**: Build iOS Framework and Android AAR
- **Files**:
  - `build/mobile.sh` - Create: Gomobile build script
- **Verification**: Produces H2Core.xcframework and h2core.aar
- **Complexity**: Medium
- **Dependencies**: Task 2.3

### Phase 3: HTTP API (Priority: Medium)

#### Task 3.1: Create API Package

- **Description**: HTTP server with REST endpoints
- **Files**:
  - `api/server.go` - Create: HTTP server setup
  - `api/handlers.go` - Create: Request handlers
- **Complexity**: Low
- **Dependencies**: None

#### Task 3.2: Implement API Handlers

- **Description**: Implement start/stop/status/stats endpoints
- **Files**:
  - `api/handlers.go` - Modify: Full implementation
- **Verification**: curl commands work
- **Complexity**: Medium
- **Dependencies**: Task 3.1

#### Task 3.3: Add API to CLI

- **Description**: Add `https-vpn api` command to start HTTP API
- **Files**:
  - `cmd/https-vpn/main.go` - Modify: Add api command
- **Verification**: `https-vpn api -port 8080` starts server
- **Complexity**: Low
- **Dependencies**: Task 3.2

### Phase 4: vpnclient_engine_flutter Integration

#### Task 4.1: Add h2core to CoreType

- **Description**: Add h2core enum value to Dart and C++
- **Files**:
  - `engines/vpnclient_engine_flutter/lib/src/models/core_type.dart` - Modify
  - `engines/vpnclient_engine_flutter/include/vpnclient_engine.h` - Modify
- **Complexity**: Low
- **Dependencies**: Phase 1 complete

#### Task 4.2: Create H2Core C++ Wrapper

- **Description**: C++ class wrapping C-API
- **Files**:
  - `engines/vpnclient_engine_flutter/include/cores/h2_core.h` - Create
  - `engines/vpnclient_engine_flutter/src/cores/h2_core.cpp` - Create
- **Complexity**: Medium
- **Dependencies**: Task 4.1

#### Task 4.3: Update CMakeLists.txt

- **Description**: Link libh2core library
- **Files**:
  - `engines/vpnclient_engine_flutter/CMakeLists.txt` - Modify
- **Verification**: Build succeeds with h2core enabled
- **Complexity**: Low
- **Dependencies**: Task 4.2

#### Task 4.4: Update EngineManager

- **Description**: Add h2core to driver requirement logic
- **Files**:
  - `engines/vpnclient_engine_flutter/lib/src/core/engine_manager.dart` - Modify
- **Verification**: requiresDriver(h2core) returns true
- **Complexity**: Low
- **Dependencies**: Task 4.1

#### Task 4.5: Add Unit Tests

- **Description**: Tests for h2core integration
- **Files**:
  - `engines/vpnclient_engine_flutter/test/h2_core_test.dart` - Create
- **Verification**: All tests pass
- **Complexity**: Medium
- **Dependencies**: Task 4.4

## Dependency Graph

```
Phase 1 (C-API)
├── 1.1 Directory ──→ 1.2 Core Functions ──→ 1.3 Info Functions
│                            │
│                            └──→ 1.4 Client Mode ──→ 1.5 Build Script ──→ 1.6 Test
│
Phase 2 (Gomobile)  [Can start parallel]
├── 2.1 Package ──→ 2.2 Client ──→ 2.3 SOCKS5 ──→ 2.4 Build Script
│
Phase 3 (HTTP API)  [Can start parallel]
├── 3.1 Package ──→ 3.2 Handlers ──→ 3.3 CLI Command
│
Phase 4 (Flutter)   [Depends on Phase 1]
└── 4.1 CoreType ──→ 4.2 C++ Wrapper ──→ 4.3 CMake ──→ 4.4 EngineManager ──→ 4.5 Tests
```

## File Change Summary

| File | Action | Phase |
|------|--------|-------|
| `cgo/h2core.h` | Create | 1 |
| `cgo/h2core.go` | Create | 1 |
| `cgo/instance.go` | Create | 1 |
| `cgo/client.go` | Create | 1 |
| `cgo/socks.go` | Create | 1 |
| `build/cgo.sh` | Create | 1 |
| `cgo/test/main.c` | Create | 1 |
| `mobile/doc.go` | Create | 2 |
| `mobile/client.go` | Create | 2 |
| `mobile/socks.go` | Create | 2 |
| `build/mobile.sh` | Create | 2 |
| `api/server.go` | Create | 3 |
| `api/handlers.go` | Create | 3 |
| `cmd/https-vpn/main.go` | Modify | 3 |
| `../engines/.../core_type.dart` | Modify | 4 |
| `../engines/.../h2_core.h` | Create | 4 |
| `../engines/.../h2_core.cpp` | Create | 4 |
| `../engines/.../CMakeLists.txt` | Modify | 4 |
| `../engines/.../engine_manager.dart` | Modify | 4 |
| `../engines/.../h2_core_test.dart` | Create | 4 |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CGO complexity on cross-compile | Medium | High | Test on each platform, use Docker for Linux |
| Gomobile version incompatibility | Low | Medium | Pin gomobile version |
| SOCKS5 implementation bugs | Medium | Medium | Use existing library (go-socks5) |
| Flutter FFI issues | Low | High | Test incrementally, follow singbox pattern |

## Checkpoints

### After Phase 1
- [ ] `build/cgo.sh` produces .so and .dylib
- [ ] C test program links and runs
- [ ] h2_create/start/stop/destroy work

### After Phase 2
- [ ] `build/mobile.sh` produces .xcframework and .aar
- [ ] Mobile client can connect (manual test)

### After Phase 3
- [ ] `https-vpn api` command works
- [ ] curl can start/stop via HTTP

### After Phase 4
- [ ] Flutter engine builds with h2core
- [ ] Unit tests pass
- [ ] Integration test connects via h2core

## Execution Order Recommendation

1. **Week 1**: Phase 1 (Tasks 1.1-1.6) - C-API complete
2. **Week 2**: Phase 4 (Tasks 4.1-4.5) - Flutter integration
3. **Week 3**: Phase 2 (Tasks 2.1-2.4) - Gomobile
4. **Week 4**: Phase 3 (Tasks 3.1-3.3) - HTTP API

Phases 2 and 3 can be deferred if not immediately needed.

---

## Approval

- [ ] Reviewed by: User
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
