/// H2 VPN Engine - Drop-in replacement for vpnclient_engine_flutter
///
/// Uses h2.core backend with SOCKS5 proxy model.
///
/// ## Usage
///
/// ```dart
/// import 'package:flutter_h2/flutter_h2.dart';
///
/// final engine = VpnClientEngine.instance;
///
/// await engine.initialize(VpnEngineConfig(
///   core: CoreConfig(
///     type: CoreType.h2,
///     configJson: '{}',
///     serverAddress: 'vpn.example.com',
///     serverPort: 443,
///     protocol: 'us', // crypto provider
///   ),
/// ));
///
/// await engine.connect();
///
/// // Get SOCKS5 proxy port
/// final port = engine.getSocksPort();
/// // Configure HTTP client: SOCKS5 127.0.0.1:$port
///
/// await engine.disconnect();
/// ```
library flutter_h2;

// Main API - compatible with vpnclient_engine_flutter
export 'src/vpnclient_engine.dart';

// Models
export 'src/models/connection_status.dart';
export 'src/models/connection_stats.dart';
export 'src/models/config.dart';
export 'src/models/core_type.dart';
export 'src/models/driver_type.dart';
