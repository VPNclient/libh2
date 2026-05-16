import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/config.dart';
import 'models/connection_status.dart';
import 'models/connection_stats.dart';

/// Log callback
typedef LogCallback = void Function(String level, String message);

/// Status callback
typedef StatusCallback = void Function(ConnectionStatus status);

/// Stats callback
typedef StatsCallback = void Function(ConnectionStats stats);

/// VPN Client Engine - H2 Core Implementation
///
/// Drop-in replacement for vpnclient_engine_flutter using h2.core backend.
/// Provides SOCKS5 proxy instead of TUN-based tunneling.
class VpnClientEngine {
  static const MethodChannel _channel = MethodChannel('flutter_h2');

  static VpnClientEngine? _instance;

  // State
  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionStats _stats = const ConnectionStats();
  int _socksPort = 0;

  // Callbacks
  LogCallback? _logCallback;
  StatusCallback? _statusCallback;
  StatsCallback? _statsCallback;

  // Streams
  StreamController<ConnectionStatus>? _statusStreamController;
  StreamController<ConnectionStats>? _statsStreamController;
  StreamController<Map<String, String>>? _logStreamController;

  // Config
  VpnEngineConfig? _config;
  Timer? _statsTimer;

  VpnClientEngine._() {
    _setupMethodCallHandler();
  }

  /// Get singleton instance
  static VpnClientEngine get instance {
    _instance ??= VpnClientEngine._();
    return _instance!;
  }

  /// Initialize with configuration
  Future<bool> initialize(VpnEngineConfig config) async {
    _config = config;

    // Extract server address from config
    final serverAddr = _extractServerAddress(config);
    final cryptoProvider = config.core.protocol ?? 'us';

    if (serverAddr.isEmpty) {
      _log('ERROR', 'Server address is empty');
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('initialize', {
        'serverAddr': serverAddr,
        'cryptoProvider': cryptoProvider,
      });

      if (result == true) {
        _log('INFO', 'H2 Engine initialized');
        _log('INFO', 'Server: $serverAddr');
        _log('INFO', 'Crypto: $cryptoProvider');
      }
      return result ?? false;
    } catch (e) {
      _log('ERROR', 'Failed to initialize: $e');
      return false;
    }
  }

  /// Connect to VPN (starts SOCKS5 proxy)
  Future<bool> connect() async {
    if (_config == null) {
      _log('ERROR', 'Engine not initialized. Call initialize() first.');
      return false;
    }

    try {
      _updateStatus(ConnectionStatus.connecting);
      _log('INFO', 'Connecting...');

      final port = await _channel.invokeMethod<int>('connect');

      if (port != null && port > 0) {
        _socksPort = port;
        _updateStatus(ConnectionStatus.connected);
        _log('INFO', 'Connected. SOCKS5 proxy at 127.0.0.1:$port');
        _startStatsPolling();
        return true;
      } else {
        _updateStatus(ConnectionStatus.error);
        _log('ERROR', 'Failed to connect');
        return false;
      }
    } catch (e) {
      _log('ERROR', 'Connection error: $e');
      _updateStatus(ConnectionStatus.error);
      return false;
    }
  }

  /// Disconnect from VPN
  Future<void> disconnect() async {
    try {
      _updateStatus(ConnectionStatus.disconnecting);
      _log('INFO', 'Disconnecting...');

      await _channel.invokeMethod('disconnect');

      _socksPort = 0;
      _stopStatsPolling();
      _updateStatus(ConnectionStatus.disconnected);
      _log('INFO', 'Disconnected');
    } catch (e) {
      _log('ERROR', 'Disconnect error: $e');
      _updateStatus(ConnectionStatus.disconnected);
    }
  }

  /// Get SOCKS5 proxy port (h2-specific)
  ///
  /// Returns the local port where SOCKS5 proxy is listening.
  /// Returns 0 if not connected.
  ///
  /// Usage:
  /// ```dart
  /// final port = engine.getSocksPort();
  /// // Configure HTTP client:
  /// httpClient.findProxy = (uri) => 'SOCKS5 127.0.0.1:$port';
  /// ```
  int getSocksPort() => _socksPort;

  /// Current connection status
  ConnectionStatus get status => _status;

  /// Current connection statistics
  ConnectionStats get stats => _stats;

  /// Stream of connection status changes
  Stream<ConnectionStatus> get statusStream {
    _statusStreamController ??= StreamController<ConnectionStatus>.broadcast();
    return _statusStreamController!.stream;
  }

  /// Stream of connection statistics updates
  Stream<ConnectionStats> get statsStream {
    _statsStreamController ??= StreamController<ConnectionStats>.broadcast();
    return _statsStreamController!.stream;
  }

  /// Stream of log messages
  Stream<Map<String, String>> get logStream {
    _logStreamController ??= StreamController<Map<String, String>>.broadcast();
    return _logStreamController!.stream;
  }

  /// Set log callback
  void setLogCallback(LogCallback callback) {
    _logCallback = callback;
  }

  /// Set status callback
  void setStatusCallback(StatusCallback callback) {
    _statusCallback = callback;
  }

  /// Set stats callback
  void setStatsCallback(StatsCallback callback) {
    _statsCallback = callback;
  }

  /// Get core name
  Future<String> getCoreName() async {
    return 'h2.core';
  }

  /// Get core version
  Future<String> getCoreVersion() async {
    try {
      final result = await _channel.invokeMethod<String>('getVersion');
      return result ?? '0.1.0';
    } catch (e) {
      return '0.1.0';
    }
  }

  /// Get driver name (always "none" for h2.core - uses SOCKS5)
  Future<String> getDriverName() async {
    return 'none';
  }

  /// Test connection (ping through proxy)
  Future<bool> testConnection() async {
    if (_status != ConnectionStatus.connected) {
      return false;
    }
    // H2 core doesn't have built-in ping, return true if connected
    return true;
  }

  /// Update stats manually
  Future<void> updateStats() async {
    await _updateStatsInternal();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    _stopStatsPolling();
    await _statusStreamController?.close();
    await _statsStreamController?.close();
    await _logStreamController?.close();
    _statusStreamController = null;
    _statsStreamController = null;
    _logStreamController = null;
  }

  // Private methods

  String _extractServerAddress(VpnEngineConfig config) {
    // Try serverAddress first
    if (config.core.serverAddress != null &&
        config.core.serverAddress!.isNotEmpty) {
      final port = config.core.serverPort ?? 443;
      return '${config.core.serverAddress}:$port';
    }

    // Try parsing configJson for server address
    try {
      final json = jsonDecode(config.core.configJson) as Map<String, dynamic>;

      // Try common JSON fields
      final addr = json['server'] ?? json['serverAddr'] ?? json['address'];
      final port = json['port'] ?? json['serverPort'] ?? 443;

      if (addr != null) {
        return '$addr:$port';
      }
    } catch (_) {
      // JSON parsing failed
    }

    return '';
  }

  void _startStatsPolling() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateStatsInternal(),
    );
  }

  void _stopStatsPolling() {
    _statsTimer?.cancel();
    _statsTimer = null;
  }

  Future<void> _updateStatsInternal() async {
    try {
      final data = await _channel.invokeMethod<Map>('getStats');
      if (data != null) {
        _stats = ConnectionStats(
          bytesSent: (data['bytesOut'] as num?)?.toInt() ?? 0,
          bytesReceived: (data['bytesIn'] as num?)?.toInt() ?? 0,
          packetsSent: 0, // H2 core doesn't track packets
          packetsReceived: 0,
          latencyMs: 0,
        );
        _statsCallback?.call(_stats);
        _statsStreamController?.add(_stats);
      }
    } catch (_) {
      // Stats update failed silently
    }
  }

  void _updateStatus(ConnectionStatus status) {
    _status = status;
    _statusCallback?.call(status);
    _statusStreamController?.add(status);
  }

  void _log(String level, String message) {
    _logCallback?.call(level, message);
    _logStreamController?.add({'level': level, 'message': message});
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStatusChanged':
          final status = ConnectionStatus.fromString(call.arguments as String);
          _updateStatus(status);
          break;
        case 'onStatsUpdated':
          final data = Map<String, dynamic>.from(call.arguments as Map);
          _stats = ConnectionStats.fromMap(data);
          _statsCallback?.call(_stats);
          _statsStreamController?.add(_stats);
          break;
        case 'onLog':
          final data = Map<String, dynamic>.from(call.arguments as Map);
          final level = data['level'] as String;
          final message = data['message'] as String;
          _log(level, message);
          break;
      }
    });
  }
}
