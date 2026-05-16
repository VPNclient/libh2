/// Tunnel driver type
enum DriverType {
  /// No driver (proxy mode)
  none,

  /// System TUN
  tun,

  /// WireGuard
  wireguard,

  /// Custom driver
  custom;

  /// Create from string
  static DriverType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'none':
        return DriverType.none;
      case 'tun':
        return DriverType.tun;
      case 'wireguard':
      case 'wg':
        return DriverType.wireguard;
      case 'custom':
        return DriverType.custom;
      default:
        throw ArgumentError('Unknown driver type: $value');
    }
  }

  /// Convert to native string
  String toNativeString() {
    switch (this) {
      case DriverType.none:
        return 'none';
      case DriverType.tun:
        return 'tun';
      case DriverType.wireguard:
        return 'wireguard';
      case DriverType.custom:
        return 'custom';
    }
  }
}
