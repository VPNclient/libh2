module github.com/vpnclient/libh2/wrappers/cgo

go 1.25.0

require github.com/vpnclient/https-vpn v0.1.0

// For local development, use replace directive
replace github.com/vpnclient/https-vpn => ../../../h2.core
