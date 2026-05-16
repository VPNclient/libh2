/// VPN core type
enum CoreType {
  /// Xray core
  xray,

  /// V2Ray core
  v2ray,

  /// Sing-box core
  sing,

  /// H2 core (HTTPS VPN)
  h2,

  /// Custom core
  custom;

  /// Create from string
  static CoreType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'xray':
        return CoreType.xray;
      case 'v2ray':
        return CoreType.v2ray;
      case 'sing':
      case 'singbox':
      case 'sing-box':
        return CoreType.sing;
      case 'h2':
      case 'h2core':
      case 'h2.core':
        return CoreType.h2;
      case 'custom':
        return CoreType.custom;
      default:
        throw ArgumentError('Unknown core type: $value');
    }
  }

  /// Convert to native string
  String toNativeString() {
    switch (this) {
      case CoreType.xray:
        return 'xray';
      case CoreType.v2ray:
        return 'v2ray';
      case CoreType.sing:
        return 'sing';
      case CoreType.h2:
        return 'h2';
      case CoreType.custom:
        return 'custom';
    }
  }
}
