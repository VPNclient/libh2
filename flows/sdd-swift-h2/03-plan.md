# Plan: swift-h2

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-16

## Overview

iOS gomobile wrapper producing H2Core.xcframework.

## Tasks

### Phase 1: Go Source (shared with kotlin-h2)

| # | Task | Files | Complexity |
|---|------|-------|------------|
| 1.1 | Verify gomobile Go source exists | `wrappers/gomobile/*.go` | Done |
| 1.2 | Verify go.mod with h2.core dependency | `wrappers/gomobile/go.mod` | Done |

### Phase 2: Build

| # | Task | Files | Complexity |
|---|------|-------|------------|
| 2.1 | Update build/gomobile.sh for iOS | `build/gomobile.sh` | Low |
| 2.2 | Run gomobile bind -target=ios | - | Low |
| 2.3 | Verify H2Core.xcframework structure | `dist/H2Core.xcframework/` | Low |

### Phase 3: Integration

| # | Task | Files | Complexity |
|---|------|-------|------------|
| 3.1 | Copy to flutter_h2/ios/Frameworks/ | `build/copy_to_flutter.sh` | Done |
| 3.2 | Verify podspec vendored_frameworks | `wrappers/flutter_h2/ios/flutter_h2.podspec` | Low |

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `wrappers/gomobile/*.go` | Exists | Go source (already created) |
| `wrappers/gomobile/go.mod` | Exists | Module definition |
| `build/gomobile.sh` | Exists | Build script |
| `dist/H2Core.xcframework/` | Create | Build output |

## Dependencies

```
Phase 1 (source) ─► Phase 2 (build) ─► Phase 3 (integrate)
```

## Prerequisites

```bash
# Install gomobile
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

# Xcode must be installed
xcode-select --install
```

## Execution Order

1. **2.1** Ensure gomobile.sh is ready
2. **2.2** Run `./build/gomobile.sh ios`
3. **2.3** Check `dist/H2Core.xcframework/` exists
4. **3.1** Run `./build/copy_to_flutter.sh`
5. **3.2** Verify flutter_h2 iOS works

## Estimated Scope

- **Files changed**: 0 (all exist)
- **Build commands**: 2
- **Output**: H2Core.xcframework (~20MB)

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-05-16
