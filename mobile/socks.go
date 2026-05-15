package mobile

import (
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"net"
)

// SOCKS5 constants
const (
	socks5Version = 0x05

	// Authentication methods
	authNone     = 0x00
	authPassword = 0x02
	authNoAccept = 0xFF

	// Commands
	cmdConnect = 0x01

	// Address types
	atypIPv4   = 0x01
	atypDomain = 0x03
	atypIPv6   = 0x04

	// Reply codes
	repSuccess         = 0x00
	repGeneralFailure  = 0x01
	repConnNotAllowed  = 0x02
	repNetUnreachable  = 0x03
	repHostUnreachable = 0x04
	repConnRefused     = 0x05
	repTTLExpired      = 0x06
	repCmdNotSupported = 0x07
	repAtypNotSupported = 0x08
)

// handleSocks5Handshake performs SOCKS5 handshake and returns target address.
func (c *Client) handleSocks5Handshake(conn net.Conn) (string, error) {
	// Read version and number of methods
	header := make([]byte, 2)
	if _, err := io.ReadFull(conn, header); err != nil {
		return "", err
	}

	if header[0] != socks5Version {
		return "", errors.New("unsupported SOCKS version")
	}

	// Read authentication methods
	numMethods := int(header[1])
	methods := make([]byte, numMethods)
	if _, err := io.ReadFull(conn, methods); err != nil {
		return "", err
	}

	// We only support no-auth
	hasNoAuth := false
	for _, m := range methods {
		if m == authNone {
			hasNoAuth = true
			break
		}
	}

	if !hasNoAuth {
		conn.Write([]byte{socks5Version, authNoAccept})
		return "", errors.New("no acceptable auth method")
	}

	// Send auth method selection (no auth)
	if _, err := conn.Write([]byte{socks5Version, authNone}); err != nil {
		return "", err
	}

	// Read connect request
	// +----+-----+-------+------+----------+----------+
	// |VER | CMD |  RSV  | ATYP | DST.ADDR | DST.PORT |
	// +----+-----+-------+------+----------+----------+
	request := make([]byte, 4)
	if _, err := io.ReadFull(conn, request); err != nil {
		return "", err
	}

	if request[0] != socks5Version {
		return "", errors.New("invalid SOCKS version in request")
	}

	if request[1] != cmdConnect {
		c.sendSocks5Error(conn, repCmdNotSupported)
		return "", errors.New("only CONNECT command is supported")
	}

	// Parse destination address
	var targetAddr string
	atyp := request[3]

	switch atyp {
	case atypIPv4:
		// IPv4: 4 bytes
		addr := make([]byte, 4)
		if _, err := io.ReadFull(conn, addr); err != nil {
			return "", err
		}
		targetAddr = net.IP(addr).String()

	case atypDomain:
		// Domain: 1 byte length + domain
		lenBuf := make([]byte, 1)
		if _, err := io.ReadFull(conn, lenBuf); err != nil {
			return "", err
		}
		domainLen := int(lenBuf[0])
		domain := make([]byte, domainLen)
		if _, err := io.ReadFull(conn, domain); err != nil {
			return "", err
		}
		targetAddr = string(domain)

	case atypIPv6:
		// IPv6: 16 bytes
		addr := make([]byte, 16)
		if _, err := io.ReadFull(conn, addr); err != nil {
			return "", err
		}
		targetAddr = "[" + net.IP(addr).String() + "]"

	default:
		c.sendSocks5Error(conn, repAtypNotSupported)
		return "", fmt.Errorf("unsupported address type: %d", atyp)
	}

	// Read port (2 bytes, big endian)
	portBuf := make([]byte, 2)
	if _, err := io.ReadFull(conn, portBuf); err != nil {
		return "", err
	}
	port := binary.BigEndian.Uint16(portBuf)

	return fmt.Sprintf("%s:%d", targetAddr, port), nil
}

// sendSocks5Error sends a SOCKS5 error response.
func (c *Client) sendSocks5Error(conn net.Conn, code byte) {
	// +----+-----+-------+------+----------+----------+
	// |VER | REP |  RSV  | ATYP | BND.ADDR | BND.PORT |
	// +----+-----+-------+------+----------+----------+
	response := []byte{
		socks5Version,
		code,
		0x00,       // RSV
		atypIPv4,   // ATYP
		0, 0, 0, 0, // BND.ADDR (0.0.0.0)
		0, 0,       // BND.PORT (0)
	}
	conn.Write(response)
}

// sendSocks5Success sends a SOCKS5 success response.
func (c *Client) sendSocks5Success(conn net.Conn) {
	// Get local address for response (use 127.0.0.1 as bind address)
	response := []byte{
		socks5Version,
		repSuccess,
		0x00,          // RSV
		atypIPv4,      // ATYP
		127, 0, 0, 1,  // BND.ADDR
		0, 0,          // BND.PORT
	}
	conn.Write(response)
}
