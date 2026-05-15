package mobile

import (
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"sync"
	"sync/atomic"

	"github.com/vpnclient/https-vpn/transport"
)

// Version returns the h2.core version string.
func Version() string {
	return "0.1.0"
}

// Client represents an h2.core VPN client for mobile platforms.
// It connects to an HTTPS VPN server and exposes a local SOCKS5 proxy.
type Client struct {
	mu sync.Mutex

	// Configuration
	serverAddr     string
	cryptoProvider string

	// Runtime state
	running       bool
	socksListener net.Listener
	socksPort     int

	// Statistics (atomic for thread safety)
	bytesIn    int64
	bytesOut   int64
	connCount  int64
}

// NewClient creates a new h2.core VPN client.
//
// Parameters:
//   - serverAddr: VPN server address (e.g., "vpn.example.com:443")
//   - cryptoProvider: Crypto provider name ("us", "ua", "cn", "th", "fr", "uk")
//
// Returns a new Client instance.
func NewClient(serverAddr, cryptoProvider string) *Client {
	if cryptoProvider == "" {
		cryptoProvider = "us"
	}
	return &Client{
		serverAddr:     serverAddr,
		cryptoProvider: cryptoProvider,
	}
}

// Start connects to the VPN server and starts a local SOCKS5 proxy.
// Returns the local SOCKS5 port number that can be used for proxy configuration.
//
// On iOS/Android, configure the system or app to use this SOCKS5 proxy:
//   - Host: 127.0.0.1
//   - Port: (returned value)
func (c *Client) Start() (int, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if c.running {
		return c.socksPort, nil
	}

	if c.serverAddr == "" {
		return 0, errors.New("server address is empty")
	}

	// Start local SOCKS5 listener on random available port
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		return 0, fmt.Errorf("failed to start SOCKS5 listener: %w", err)
	}

	c.socksListener = listener
	c.socksPort = listener.Addr().(*net.TCPAddr).Port
	c.running = true

	// Reset stats
	atomic.StoreInt64(&c.bytesIn, 0)
	atomic.StoreInt64(&c.bytesOut, 0)
	atomic.StoreInt64(&c.connCount, 0)

	// Start accepting connections
	go c.acceptLoop()

	return c.socksPort, nil
}

// Stop disconnects from the VPN server and stops the SOCKS5 proxy.
func (c *Client) Stop() error {
	c.mu.Lock()
	defer c.mu.Unlock()

	if !c.running {
		return nil
	}

	if c.socksListener != nil {
		c.socksListener.Close()
		c.socksListener = nil
	}

	c.socksPort = 0
	c.running = false

	return nil
}

// IsRunning returns true if the client is connected and running.
func (c *Client) IsRunning() bool {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.running
}

// GetSocksPort returns the local SOCKS5 proxy port, or 0 if not running.
func (c *Client) GetSocksPort() int {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.socksPort
}

// GetServerAddr returns the configured VPN server address.
func (c *Client) GetServerAddr() string {
	return c.serverAddr
}

// GetCryptoProvider returns the configured crypto provider name.
func (c *Client) GetCryptoProvider() string {
	return c.cryptoProvider
}

// Stats holds runtime statistics.
type Stats struct {
	Running    bool
	SocksPort  int
	BytesIn    int64
	BytesOut   int64
	ConnCount  int64
	ServerAddr string
}

// GetStats returns current runtime statistics.
func (c *Client) GetStats() *Stats {
	c.mu.Lock()
	running := c.running
	port := c.socksPort
	c.mu.Unlock()

	return &Stats{
		Running:    running,
		SocksPort:  port,
		BytesIn:    atomic.LoadInt64(&c.bytesIn),
		BytesOut:   atomic.LoadInt64(&c.bytesOut),
		ConnCount:  atomic.LoadInt64(&c.connCount),
		ServerAddr: c.serverAddr,
	}
}

// GetStatsJSON returns statistics as a JSON string.
// This is useful for platforms that don't support complex types.
func (c *Client) GetStatsJSON() string {
	stats := c.GetStats()
	data, _ := json.Marshal(stats)
	return string(data)
}

// acceptLoop accepts incoming SOCKS5 connections.
func (c *Client) acceptLoop() {
	for {
		conn, err := c.socksListener.Accept()
		if err != nil {
			// Listener closed
			return
		}
		atomic.AddInt64(&c.connCount, 1)
		go c.handleConnection(conn)
	}
}

// handleConnection handles a single SOCKS5 client connection.
func (c *Client) handleConnection(clientConn net.Conn) {
	defer clientConn.Close()

	// Parse SOCKS5 request and get target address
	targetAddr, err := c.handleSocks5Handshake(clientConn)
	if err != nil {
		return
	}

	// Connect to target via H2 VPN
	h2Client, err := transport.NewH2Client(&transport.ClientConfig{
		ServerAddr:     c.serverAddr,
		CryptoProvider: c.cryptoProvider,
	})
	if err != nil {
		c.sendSocks5Error(clientConn, 0x01) // General failure
		return
	}
	defer h2Client.Close()

	targetConn, err := h2Client.Connect(targetAddr)
	if err != nil {
		c.sendSocks5Error(clientConn, 0x05) // Connection refused
		return
	}
	defer targetConn.Close()

	// Send success response
	c.sendSocks5Success(clientConn)

	// Bidirectional copy with stats tracking
	c.relay(clientConn, targetConn)
}

// relay copies data bidirectionally between two connections.
func (c *Client) relay(client, target net.Conn) {
	done := make(chan struct{}, 2)

	// Client -> Target
	go func() {
		n, _ := copyWithStats(target, client, &c.bytesOut)
		_ = n
		done <- struct{}{}
	}()

	// Target -> Client
	go func() {
		n, _ := copyWithStats(client, target, &c.bytesIn)
		_ = n
		done <- struct{}{}
	}()

	// Wait for one direction to finish
	<-done
}

// copyWithStats copies data and updates byte counter.
func copyWithStats(dst, src net.Conn, counter *int64) (int64, error) {
	buf := make([]byte, 32*1024)
	var total int64
	for {
		n, err := src.Read(buf)
		if n > 0 {
			written, werr := dst.Write(buf[:n])
			if written > 0 {
				total += int64(written)
				atomic.AddInt64(counter, int64(written))
			}
			if werr != nil {
				return total, werr
			}
		}
		if err != nil {
			return total, err
		}
	}
}
