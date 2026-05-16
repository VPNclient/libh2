module github.com/vpnclient/libh2/wrappers/gomobile

go 1.25.0

require github.com/vpnclient/https-vpn v0.1.0

require (
	golang.org/x/mobile v0.0.0-20260514233045-7de0a8fa7f4d // indirect
	golang.org/x/mod v0.36.0 // indirect
	golang.org/x/sync v0.20.0 // indirect
	golang.org/x/tools v0.45.0 // indirect
)

// For local development, use replace directive
replace github.com/vpnclient/https-vpn => ../../../h2.core
