# Implementation Plan: flutter_h2

## Overview

Transform existing `flutter_h2` scaffold into a drop-in replacement for `vpnclient_engine_flutter` using gomobile-compiled h2.core.

## Phase 1: Dart Layer

### 1.1 Models
Copy and adapt models from vpnclient_engine_flutter:

| Task | File | Action |
|------|------|--------|
| 1.1.1 | `lib/src/models/connection_status.dart` | Copy from vpnclient_engine_flutter |
| 1.1.2 | `lib/src/models/connection_stats.dart` | Copy from vpnclient_engine_flutter |
| 1.1.3 | `lib/src/models/config.dart` | Copy (CoreConfig, DriverConfig, VpnEngineConfig) |
| 1.1.4 | `lib/src/models/core_type.dart` | Copy + add `h2` enum value |
| 1.1.5 | `lib/src/models/driver_type.dart` | Copy from vpnclient_engine_flutter |

### 1.2 Main Engine Class
| Task | File | Action |
|------|------|--------|
| 1.2.1 | `lib/src/vpnclient_engine.dart` | Create VpnClientEngine with h2 backend |

### 1.3 Library Exports
| Task | File | Action |
|------|------|--------|
| 1.3.1 | `lib/flutter_h2.dart` | Update exports to match vpnclient_engine_flutter |

### 1.4 Cleanup
| Task | File | Action |
|------|------|--------|
| 1.4.1 | Remove | `lib/flutter_h2_platform_interface.dart` (not needed) |
| 1.4.2 | Remove | `lib/flutter_h2_method_channel.dart` (not needed) |
| 1.4.3 | Remove | `lib/flutter_h2_web.dart` (not needed) |

## Phase 2: iOS Platform

### 2.1 Framework Integration
| Task | File | Action |
|------|------|--------|
| 2.1.1 | `ios/Frameworks/` | Create directory for H2Core.xcframework |
| 2.1.2 | `ios/flutter_h2.podspec` | Update with vendored_frameworks |

### 2.2 Plugin Implementation
| Task | File | Action |
|------|------|--------|
| 2.2.1 | `ios/Classes/FlutterH2Plugin.swift` | Implement full method channel handler |

## Phase 3: Android Platform

### 3.1 AAR Integration
| Task | File | Action |
|------|------|--------|
| 3.1.1 | `android/libs/` | Create directory for h2core.aar |
| 3.1.2 | `android/build.gradle` | Add libs dependency |

### 3.2 Plugin Implementation
| Task | File | Action |
|------|------|--------|
| 3.2.1 | `android/.../FlutterH2Plugin.kt` | Implement full method channel handler |

## Phase 4: Build & Test

### 4.1 Build Scripts
| Task | File | Action |
|------|------|--------|
| 4.1.1 | `build/copy_frameworks.sh` | Script to copy gomobile outputs to plugin |

### 4.2 Verification
| Task | Action |
|------|--------|
| 4.2.1 | `flutter pub get` in flutter_h2 |
| 4.2.2 | `flutter analyze` - no errors |
| 4.2.3 | Run example app (manual test) |

## Task Checklist

```
Phase 1: Dart Layer
[ ] 1.1.1 connection_status.dart
[ ] 1.1.2 connection_stats.dart
[ ] 1.1.3 config.dart
[ ] 1.1.4 core_type.dart
[ ] 1.1.5 driver_type.dart
[ ] 1.2.1 vpnclient_engine.dart
[ ] 1.3.1 flutter_h2.dart exports
[ ] 1.4.1 Remove platform_interface
[ ] 1.4.2 Remove method_channel
[ ] 1.4.3 Remove web

Phase 2: iOS
[ ] 2.1.1 Create Frameworks dir
[ ] 2.1.2 Update podspec
[ ] 2.2.1 FlutterH2Plugin.swift

Phase 3: Android
[ ] 3.1.1 Create libs dir
[ ] 3.1.2 Update build.gradle
[ ] 3.2.1 FlutterH2Plugin.kt

Phase 4: Build & Test
[ ] 4.1.1 copy_frameworks.sh
[ ] 4.2.1 flutter pub get
[ ] 4.2.2 flutter analyze
[ ] 4.2.3 Example app test
```

## Dependencies

- H2Core.xcframework must be built first: `vendors/h2.core/build/mobile.sh ios`
- h2core.aar must be built first: `vendors/h2.core/build/mobile.sh android`

## Notes

- Desktop platforms (macOS, Windows, Linux) are out of scope
- Web platform not supported (no gomobile for web)
- Framework files are NOT committed to git (built artifacts)
