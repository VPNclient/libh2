/// VPN connection status
enum ConnectionStatus {
  /// Disconnected
  disconnected,

  /// Connecting
  connecting,

  /// Connected
  connected,

  /// Disconnecting
  disconnecting,

  /// Error
  error;

  /// Create from string
  static ConnectionStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DISCONNECTED':
        return ConnectionStatus.disconnected;
      case 'CONNECTING':
        return ConnectionStatus.connecting;
      case 'CONNECTED':
        return ConnectionStatus.connected;
      case 'DISCONNECTING':
        return ConnectionStatus.disconnecting;
      case 'ERROR':
        return ConnectionStatus.error;
      default:
        throw ArgumentError('Unknown connection status: $value');
    }
  }

  /// Convert to native string
  String toNativeString() {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'DISCONNECTED';
      case ConnectionStatus.connecting:
        return 'CONNECTING';
      case ConnectionStatus.connected:
        return 'CONNECTED';
      case ConnectionStatus.disconnecting:
        return 'DISCONNECTING';
      case ConnectionStatus.error:
        return 'ERROR';
    }
  }
}
