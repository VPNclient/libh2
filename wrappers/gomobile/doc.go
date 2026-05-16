// Package mobile provides a gomobile-friendly API for h2.core HTTPS VPN.
//
// This package is designed to be built with gomobile for iOS and Android:
//
//	# Install gomobile
//	go install golang.org/x/mobile/cmd/gomobile@latest
//	gomobile init
//
//	# Build iOS framework
//	gomobile bind -target=ios -o H2Core.xcframework ./mobile
//
//	# Build Android AAR
//	gomobile bind -target=android -o h2core.aar ./mobile
//
// # Usage (Swift)
//
//	import H2Core
//
//	let client = MobileNewClient("vpn.example.com:443", "us")
//	let port = try client.start()
//	// Configure system to use SOCKS5 proxy at 127.0.0.1:port
//	// ...
//	try client.stop()
//
// # Usage (Kotlin)
//
//	import mobile.Mobile
//
//	val client = Mobile.newClient("vpn.example.com:443", "us")
//	val port = client.start()
//	// Configure system to use SOCKS5 proxy at 127.0.0.1:port
//	// ...
//	client.stop()
//
// # API Design Notes
//
// The API is intentionally simple to work well with gomobile's type restrictions:
//   - Only basic types: string, int, int64, bool, []byte, error
//   - Structs with exported fields
//   - No channels, maps, or complex types in public API
//   - Error handling via returned error values
package mobile
