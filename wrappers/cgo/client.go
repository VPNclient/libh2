// Client mode C-API implementations for h2.core
package main

/*
#include <stdlib.h>

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
	"fmt"
	"io"
	"net"
	"unsafe"

	"github.com/vpnclient/https-vpn/transport"
)

//export h2_client_create
func h2_client_create(serverAddr *C.char, cryptoProvider *C.char) unsafe.Pointer {
	if serverAddr == nil {
		setLastError("server_addr is nil")
		return nil
	}

	goServerAddr := C.GoString(serverAddr)
	goCryptoProvider := "us" // default
	if cryptoProvider != nil {
		goCryptoProvider = C.GoString(cryptoProvider)
	}

	wrapper := &instanceWrapper{
		isClient:       true,
		clientAddr:     goServerAddr,
		cryptoProvider: goCryptoProvider,
	}

	id := getNextID()
	instancesMu.Lock()
	instances[id] = wrapper
	instancesMu.Unlock()

	return unsafe.Pointer(id)
}

//export h2_client_connect
func h2_client_connect(instance unsafe.Pointer) C.int {
	if instance == nil {
		setLastError("instance is nil")
		return C.H2_ERR_NULL_PTR
	}

	wrapper := getInstance(instance)
	if wrapper == nil {
		setLastError("invalid instance handle")
		return C.H2_ERR_INVALID
	}

	if !wrapper.isClient {
		setLastError("not a client instance")
		return C.H2_ERR_INVALID
	}

	if wrapper.running {
		return C.H2_OK // Already connected
	}

	// Start local SOCKS5 listener on random port
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		setLastError("failed to start SOCKS listener: " + err.Error())
		return C.H2_ERR_NETWORK
	}

	wrapper.socksListener = listener
	wrapper.socksPort = listener.Addr().(*net.TCPAddr).Port
	wrapper.running = true

	// Start accepting connections in background
	go acceptSocksConnections(wrapper, listener)

	return C.H2_OK
}

//export h2_client_disconnect
func h2_client_disconnect(instance unsafe.Pointer) C.int {
	if instance == nil {
		setLastError("instance is nil")
		return C.H2_ERR_NULL_PTR
	}

	wrapper := getInstance(instance)
	if wrapper == nil {
		setLastError("invalid instance handle")
		return C.H2_ERR_INVALID
	}

	if !wrapper.isClient {
		setLastError("not a client instance")
		return C.H2_ERR_INVALID
	}

	if !wrapper.running {
		return C.H2_OK // Already disconnected
	}

	// Close listener
	if wrapper.socksListener != nil {
		if listener, ok := wrapper.socksListener.(net.Listener); ok {
			listener.Close()
		}
	}

	wrapper.socksListener = nil
	wrapper.socksPort = 0
	wrapper.running = false

	return C.H2_OK
}

//export h2_client_get_socks_port
func h2_client_get_socks_port(instance unsafe.Pointer) C.int {
	if instance == nil {
		setLastError("instance is nil")
		return C.H2_ERR_NULL_PTR
	}

	wrapper := getInstance(instance)
	if wrapper == nil {
		setLastError("invalid instance handle")
		return C.H2_ERR_INVALID
	}

	if !wrapper.isClient {
		setLastError("not a client instance")
		return C.H2_ERR_INVALID
	}

	if !wrapper.running {
		return 0
	}

	return C.int(wrapper.socksPort)
}

// acceptSocksConnections handles incoming SOCKS5 connections
func acceptSocksConnections(wrapper *instanceWrapper, listener net.Listener) {
	for {
		conn, err := listener.Accept()
		if err != nil {
			return // Listener closed
		}
		go handleSocksConnection(wrapper, conn)
	}
}

// handleSocksConnection handles a single SOCKS5 connection
func handleSocksConnection(wrapper *instanceWrapper, clientConn net.Conn) {
	defer clientConn.Close()

	// SOCKS5 handshake
	// Read version and auth methods
	buf := make([]byte, 256)
	n, err := clientConn.Read(buf)
	if err != nil || n < 2 {
		return
	}

	// Check SOCKS5 version
	if buf[0] != 0x05 {
		return
	}

	// Send no-auth response
	clientConn.Write([]byte{0x05, 0x00})

	// Read connect request
	n, err = clientConn.Read(buf)
	if err != nil || n < 7 {
		return
	}

	// Parse request: VER CMD RSV ATYP DST.ADDR DST.PORT
	if buf[0] != 0x05 || buf[1] != 0x01 { // Only support CONNECT
		clientConn.Write([]byte{0x05, 0x07, 0x00, 0x01, 0, 0, 0, 0, 0, 0})
		return
	}

	// Parse destination address
	var targetAddr string
	switch buf[3] {
	case 0x01: // IPv4
		if n < 10 {
			return
		}
		targetAddr = fmt.Sprintf("%d.%d.%d.%d:%d",
			buf[4], buf[5], buf[6], buf[7],
			int(buf[8])<<8|int(buf[9]))
	case 0x03: // Domain
		domainLen := int(buf[4])
		if n < 5+domainLen+2 {
			return
		}
		domain := string(buf[5 : 5+domainLen])
		port := int(buf[5+domainLen])<<8 | int(buf[5+domainLen+1])
		targetAddr = fmt.Sprintf("%s:%d", domain, port)
	case 0x04: // IPv6
		if n < 22 {
			return
		}
		// Simplified IPv6 parsing
		targetAddr = fmt.Sprintf("[%x:%x:%x:%x:%x:%x:%x:%x]:%d",
			int(buf[4])<<8|int(buf[5]), int(buf[6])<<8|int(buf[7]),
			int(buf[8])<<8|int(buf[9]), int(buf[10])<<8|int(buf[11]),
			int(buf[12])<<8|int(buf[13]), int(buf[14])<<8|int(buf[15]),
			int(buf[16])<<8|int(buf[17]), int(buf[18])<<8|int(buf[19]),
			int(buf[20])<<8|int(buf[21]))
	default:
		clientConn.Write([]byte{0x05, 0x08, 0x00, 0x01, 0, 0, 0, 0, 0, 0})
		return
	}

	// Connect to target via H2 client
	h2Client, err := transport.NewH2Client(&transport.ClientConfig{
		ServerAddr:     wrapper.clientAddr,
		CryptoProvider: wrapper.cryptoProvider,
	})
	if err != nil {
		clientConn.Write([]byte{0x05, 0x01, 0x00, 0x01, 0, 0, 0, 0, 0, 0})
		return
	}
	defer h2Client.Close()

	targetConn, err := h2Client.Connect(targetAddr)
	if err != nil {
		clientConn.Write([]byte{0x05, 0x05, 0x00, 0x01, 0, 0, 0, 0, 0, 0})
		return
	}
	defer targetConn.Close()

	// Send success response
	clientConn.Write([]byte{0x05, 0x00, 0x00, 0x01, 127, 0, 0, 1, 0, 0})

	// Bidirectional copy
	done := make(chan struct{}, 2)
	go func() {
		io.Copy(targetConn, clientConn)
		done <- struct{}{}
	}()
	go func() {
		io.Copy(clientConn, targetConn)
		done <- struct{}{}
	}()
	<-done
}
