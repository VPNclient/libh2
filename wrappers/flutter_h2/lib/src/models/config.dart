import 'core_type.dart';
import 'driver_type.dart';

/// VPN core configuration
class CoreConfig {
  /// Core type
  final CoreType type;

  /// JSON configuration
  final String configJson;

  /// Server address
  final String? serverAddress;

  /// Server port
  final int? serverPort;

  /// Protocol (vless, vmess, h2, etc.)
  final String? protocol;

  /// Log level
  final String logLevel;

  /// Enable logging
  final bool enableLogging;

  const CoreConfig({
    required this.type,
    required this.configJson,
    this.serverAddress,
    this.serverPort,
    this.protocol,
    this.logLevel = 'info',
    this.enableLogging = true,
  });

  /// Create from Map
  factory CoreConfig.fromMap(Map<String, dynamic> map) {
    return CoreConfig(
      type: CoreType.fromString(map['type'] as String),
      configJson: map['configJson'] as String,
      serverAddress: map['serverAddress'] as String?,
      serverPort: map['serverPort'] as int?,
      protocol: map['protocol'] as String?,
      logLevel: map['logLevel'] as String? ?? 'info',
      enableLogging: map['enableLogging'] as bool? ?? true,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'type': type.toNativeString(),
      'configJson': configJson,
      'serverAddress': serverAddress,
      'serverPort': serverPort,
      'protocol': protocol,
      'logLevel': logLevel,
      'enableLogging': enableLogging,
    };
  }
}

/// Tunnel driver configuration
class DriverConfig {
  /// Driver type
  final DriverType type;

  /// JSON configuration
  final String configJson;

  /// MTU (Maximum Transmission Unit)
  final int mtu;

  /// TUN device name
  final String tunName;

  /// TUN device IP address
  final String tunAddress;

  /// TUN gateway
  final String tunGateway;

  /// TUN netmask
  final String tunNetmask;

  /// DNS server
  final String dnsServer;

  /// Log level
  final String logLevel;

  /// Enable logging
  final bool enableLogging;

  const DriverConfig({
    this.type = DriverType.none,
    this.configJson = '{}',
    this.mtu = 1500,
    this.tunName = 'tun0',
    this.tunAddress = '10.0.0.2',
    this.tunGateway = '10.0.0.1',
    this.tunNetmask = '255.255.255.0',
    this.dnsServer = '8.8.8.8',
    this.logLevel = 'info',
    this.enableLogging = true,
  });

  /// Create from Map
  factory DriverConfig.fromMap(Map<String, dynamic> map) {
    return DriverConfig(
      type: DriverType.fromString(map['type'] as String),
      configJson: map['configJson'] as String? ?? '{}',
      mtu: map['mtu'] as int? ?? 1500,
      tunName: map['tunName'] as String? ?? 'tun0',
      tunAddress: map['tunAddress'] as String? ?? '10.0.0.2',
      tunGateway: map['tunGateway'] as String? ?? '10.0.0.1',
      tunNetmask: map['tunNetmask'] as String? ?? '255.255.255.0',
      dnsServer: map['dnsServer'] as String? ?? '8.8.8.8',
      logLevel: map['logLevel'] as String? ?? 'info',
      enableLogging: map['enableLogging'] as bool? ?? true,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'type': type.toNativeString(),
      'configJson': configJson,
      'mtu': mtu,
      'tunName': tunName,
      'tunAddress': tunAddress,
      'tunGateway': tunGateway,
      'tunNetmask': tunNetmask,
      'dnsServer': dnsServer,
      'logLevel': logLevel,
      'enableLogging': enableLogging,
    };
  }
}

/// VPN Engine configuration
class VpnEngineConfig {
  /// Core configuration
  final CoreConfig core;

  /// Driver configuration
  final DriverConfig driver;

  /// Auto connect
  final bool autoConnect;

  /// Connection timeout (seconds)
  final int connectionTimeout;

  const VpnEngineConfig({
    required this.core,
    this.driver = const DriverConfig(),
    this.autoConnect = false,
    this.connectionTimeout = 30,
  });

  /// Create from Map
  factory VpnEngineConfig.fromMap(Map<String, dynamic> map) {
    return VpnEngineConfig(
      core: CoreConfig.fromMap(map['core'] as Map<String, dynamic>),
      driver: map['driver'] != null
          ? DriverConfig.fromMap(map['driver'] as Map<String, dynamic>)
          : const DriverConfig(),
      autoConnect: map['autoConnect'] as bool? ?? false,
      connectionTimeout: map['connectionTimeout'] as int? ?? 30,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'core': core.toMap(),
      'driver': driver.toMap(),
      'autoConnect': autoConnect,
      'connectionTimeout': connectionTimeout,
    };
  }
}
