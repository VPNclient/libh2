// Package main provides C-compatible API exports for h2.core.
// Build with: go build -buildmode=c-shared -o libh2core.so ./cgo
package main

/*
#include <stdlib.h>

// Error codes (must match h2core.h)
#define H2_OK              0
#define H2_ERR_NULL_PTR   -1
#define H2_ERR_INVALID    -2
#define H2_ERR_INIT       -3
#define H2_ERR_START      -4
#define H2_ERR_STOPPED    -5
#define H2_ERR_CONFIG     -6
#define H2_ERR_NETWORK    -7
*/
import "C"
import (
	"encoding/json"
	"sync"
	"unsafe"

	"github.com/vpnclient/https-vpn/core"
	"github.com/vpnclient/https-vpn/infra/conf"
)

// Version is set at build time
var Version = "0.1.0-dev"

// Global state
var (
	instances   = make(map[uintptr]*instanceWrapper)
	instancesMu sync.RWMutex
	nextID      uintptr = 1
	lastError   string
	lastErrorMu sync.RWMutex
)

// instanceWrapper holds instance state
type instanceWrapper struct {
	// Server mode
	serverInstance *core.Instance
	serverConfig   *conf.Config

	// Client mode
	isClient       bool
	clientAddr     string
	cryptoProvider string
	socksPort      int
	socksListener  interface{} // Will be net.Listener

	// Common
	running bool
}

// setLastError stores the last error message
func setLastError(err string) {
	lastErrorMu.Lock()
	lastError = err
	lastErrorMu.Unlock()
}

// getNextID returns the next instance ID
func getNextID() uintptr {
	instancesMu.Lock()
	id := nextID
	nextID++
	instancesMu.Unlock()
	return id
}

// storeInstance stores an instance and returns its handle
func storeInstance(w *instanceWrapper) C.ulong {
	id := getNextID()
	instancesMu.Lock()
	instances[id] = w
	instancesMu.Unlock()
	return C.ulong(id)
}

// getInstance retrieves an instance by handle
func getInstance(handle unsafe.Pointer) *instanceWrapper {
	id := uintptr(handle)
	instancesMu.RLock()
	defer instancesMu.RUnlock()
	return instances[id]
}

// removeInstance removes an instance by handle
func removeInstance(handle unsafe.Pointer) {
	id := uintptr(handle)
	instancesMu.Lock()
	delete(instances, id)
	instancesMu.Unlock()
}

//export h2_create
func h2_create(configJSON *C.char) unsafe.Pointer {
	if configJSON == nil {
		setLastError("config_json is nil")
		return nil
	}

	goConfig := C.GoString(configJSON)

	// Parse config using json.Unmarshal
	var cfg conf.Config
	if err := json.Unmarshal([]byte(goConfig), &cfg); err != nil {
		setLastError("config parse error: " + err.Error())
		return nil
	}

	// Create core instance
	inst, err := core.New(&cfg)
	if err != nil {
		setLastError("instance creation error: " + err.Error())
		return nil
	}

	// Store wrapper
	wrapper := &instanceWrapper{
		serverInstance: inst,
		serverConfig:   &cfg,
		isClient:       false,
	}

	id := getNextID()
	instancesMu.Lock()
	instances[id] = wrapper
	instancesMu.Unlock()

	return unsafe.Pointer(id)
}

//export h2_start
func h2_start(instance unsafe.Pointer) C.int {
	if instance == nil {
		setLastError("instance is nil")
		return C.H2_ERR_NULL_PTR
	}

	wrapper := getInstance(instance)
	if wrapper == nil {
		setLastError("invalid instance handle")
		return C.H2_ERR_INVALID
	}

	if wrapper.running {
		return C.H2_OK // Already running
	}

	if wrapper.isClient {
		setLastError("use h2_client_connect for client instances")
		return C.H2_ERR_INVALID
	}

	if err := wrapper.serverInstance.Start(); err != nil {
		setLastError("start error: " + err.Error())
		return C.H2_ERR_START
	}

	wrapper.running = true
	return C.H2_OK
}

//export h2_stop
func h2_stop(instance unsafe.Pointer) C.int {
	if instance == nil {
		setLastError("instance is nil")
		return C.H2_ERR_NULL_PTR
	}

	wrapper := getInstance(instance)
	if wrapper == nil {
		setLastError("invalid instance handle")
		return C.H2_ERR_INVALID
	}

	if !wrapper.running {
		return C.H2_OK // Already stopped
	}

	if wrapper.isClient {
		setLastError("use h2_client_disconnect for client instances")
		return C.H2_ERR_INVALID
	}

	if err := wrapper.serverInstance.Close(); err != nil {
		setLastError("stop error: " + err.Error())
		return C.H2_ERR_STOPPED
	}

	wrapper.running = false
	return C.H2_OK
}

//export h2_destroy
func h2_destroy(instance unsafe.Pointer) {
	if instance == nil {
		return
	}

	wrapper := getInstance(instance)
	if wrapper == nil {
		return
	}

	// Stop if running
	if wrapper.running {
		if wrapper.isClient {
			h2_client_disconnect(instance)
		} else {
			h2_stop(instance)
		}
	}

	removeInstance(instance)
}

//export h2_version
func h2_version() *C.char {
	// Return static string - caller must NOT free
	return C.CString(Version)
}

//export h2_get_stats
func h2_get_stats(instance unsafe.Pointer) *C.char {
	if instance == nil {
		return C.CString(`{"error":"instance is nil"}`)
	}

	wrapper := getInstance(instance)
	if wrapper == nil {
		return C.CString(`{"error":"invalid instance"}`)
	}

	stats := map[string]interface{}{
		"running":   wrapper.running,
		"isClient":  wrapper.isClient,
		"socksPort": wrapper.socksPort,
		// TODO: Add bytesIn, bytesOut, connections when available
	}

	data, err := json.Marshal(stats)
	if err != nil {
		return C.CString(`{"error":"json marshal failed"}`)
	}

	// Caller must free with h2_free_string
	return C.CString(string(data))
}

//export h2_is_running
func h2_is_running(instance unsafe.Pointer) C.int {
	if instance == nil {
		return C.H2_ERR_NULL_PTR
	}

	wrapper := getInstance(instance)
	if wrapper == nil {
		return C.H2_ERR_INVALID
	}

	if wrapper.running {
		return 1
	}
	return 0
}

//export h2_get_last_error
func h2_get_last_error() *C.char {
	lastErrorMu.RLock()
	err := lastError
	lastErrorMu.RUnlock()

	if err == "" {
		return C.CString("no error")
	}
	return C.CString(err)
}

//export h2_free_string
func h2_free_string(str *C.char) {
	if str != nil {
		C.free(unsafe.Pointer(str))
	}
}

// Client mode functions - implemented in client.go
// h2_client_create, h2_client_connect, h2_client_disconnect, h2_client_get_socks_port

func main() {
	// Required for -buildmode=c-shared
}
