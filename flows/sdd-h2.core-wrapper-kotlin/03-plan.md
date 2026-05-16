# Plan: kotlin-h2

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-05-16

## Overview

Android gomobile wrapper producing h2core.aar.

## Tasks

### Phase 1: Go Source (shared with swift-h2)

| # | Task | Files | Complexity |
|---|------|-------|------------|
| 1.1 | Verify gomobile Go source exists | `wrappers/gomobile/*.go` | Done |
| 1.2 | Verify go.mod with h2.core dependency | `wrappers/gomobile/go.mod` | Done |

### Phase 2: Build

| # | Task | Files | Complexity |
|---|------|-------|------------|
| 2.1 | Update build/gomobile.sh for Android | `build/gomobile.sh` | Low |
| 2.2 | Run gomobile bind -target=android | - | Low |
| 2.3 | Verify h2core.aar structure | `dist/h2core.aar` | Low |

### Phase 3: Integration

| # | Task | Files | Complexity |
|---|------|-------|------------|
| 3.1 | Copy to flutter_h2/android/libs/ | `build/copy_to_flutter.sh` | Done |
| 3.2 | Verify build.gradle.kts AAR reference | `wrappers/flutter_h2/android/build.gradle.kts` | Low |

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `wrappers/gomobile/*.go` | Exists | Go source (already created) |
| `wrappers/gomobile/go.mod` | Exists | Module definition |
| `build/gomobile.sh` | Exists | Build script |
| `dist/h2core.aar` | Create | Build output |

## Dependencies

```
Phase 1 (source) ─► Phase 2 (build) ─► Phase 3 (integrate)
```

## Prerequisites

```bash
# Install gomobile
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

# Android NDK
export ANDROID_NDK_HOME=/path/to/ndk
# Or use Android Studio's NDK
```

## Execution Order

1. **2.1** Ensure gomobile.sh is ready
2. **2.2** Run `./build/gomobile.sh android`
3. **2.3** Check `dist/h2core.aar` exists
4. **3.1** Run `./build/copy_to_flutter.sh`
5. **3.2** Verify flutter_h2 Android works

## Estimated Scope

- **Files changed**: 0 (all exist)
- **Build commands**: 2
- **Output**: h2core.aar (~15MB with 3 ABIs)

---

## Approval

- [x] Reviewed by: User
- [x] Approved on: 2026-05-16
