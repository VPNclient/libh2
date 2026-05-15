# SDD Flow Status: h2.core Integration Flutter

## Current Phase: IMPLEMENTATION
## Status: IN PROGRESS

## Progress

- [x] Flow created
- [x] Requirements documented
- [x] Requirements approved
- [x] Specifications documented
- [x] Specifications approved
- [x] Plan created
- [x] Plan approved
- [ ] Implementation complete

## Context

Creating `engines/flutter_h2` - a drop-in replacement for `vpnclient_engine_flutter` that:
1. Has identical API (same methods, events, callbacks, streams)
2. Internally uses gomobile-compiled h2.core for VPN connectivity
3. Allows seamless substitution without app code changes

## Related Files

- Gomobile package: `vendors/h2.core/mobile/`
- Reference API: `engines/vpnclient_engine_flutter/`
- Target: `engines/flutter_h2/`

## Blockers

None

## Notes

- flutter_h2 directory already exists with scaffold
- Need to implement VpnClientEngine-compatible API
- h2.core uses SOCKS5 proxy model (different from TUN-based vpnclient_engine)
