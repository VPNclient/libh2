# Project Context: libh2

Library wrappers for h2.core HTTPS VPN.

## Structure

```
libh2/
├── wrappers/
│   ├── gomobile/      # Go source for iOS/Android (H2Core.xcframework, h2core.aar)
│   ├── cgo/           # C-API exports (libh2core.so)
│   └── flutter_h2/    # Flutter plugin using gomobile wrappers
├── build/
│   └── gomobile.sh    # Build script for mobile frameworks
├── dist/              # Build outputs (not committed)
└── flows/             # SDD flows for each wrapper
```

## Responsibility

- **libh2**: Mobile/Flutter wrappers for h2.core
- **h2.core**: Core code + CLI binaries (no wrappers)

## Active Flows

<!-- FLOWS_INDEX_START -->
### SDD Flows (Spec-Driven)

| Name | Status File | Current Phase |
|------|-------------|---------------|
| `sdd-swift-h2` | `flows/sdd-swift-h2/_status.md` | IMPLEMENTATION (ready to build) |
| `sdd-kotlin-h2` | `flows/sdd-kotlin-h2/_status.md` | IMPLEMENTATION (ready to build) |
| `sdd-flutter-h2` | `flows/sdd-flutter-h2/_status.md` | COMPLETE |
<!-- FLOWS_INDEX_END -->

## Build Commands

```bash
# Build iOS framework
./build/gomobile.sh ios

# Build Android AAR
./build/gomobile.sh android

# Build both
./build/gomobile.sh all
```

## Dependencies

- h2.core (`../h2.core`) - via Go replace directive
- gomobile - `go install golang.org/x/mobile/cmd/gomobile@latest`
