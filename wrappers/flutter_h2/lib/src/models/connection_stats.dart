/// VPN connection statistics
class ConnectionStats {
  /// Bytes sent
  final int bytesSent;

  /// Bytes received
  final int bytesReceived;

  /// Packets sent
  final int packetsSent;

  /// Packets received
  final int packetsReceived;

  /// Latency in milliseconds
  final int latencyMs;

  const ConnectionStats({
    this.bytesSent = 0,
    this.bytesReceived = 0,
    this.packetsSent = 0,
    this.packetsReceived = 0,
    this.latencyMs = 0,
  });

  /// Create from Map
  factory ConnectionStats.fromMap(Map<String, dynamic> map) {
    return ConnectionStats(
      bytesSent: map['bytesSent'] as int? ?? map['bytesOut'] as int? ?? 0,
      bytesReceived: map['bytesReceived'] as int? ?? map['bytesIn'] as int? ?? 0,
      packetsSent: map['packetsSent'] as int? ?? 0,
      packetsReceived: map['packetsReceived'] as int? ?? 0,
      latencyMs: map['latencyMs'] as int? ?? 0,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'bytesSent': bytesSent,
      'bytesReceived': bytesReceived,
      'packetsSent': packetsSent,
      'packetsReceived': packetsReceived,
      'latencyMs': latencyMs,
    };
  }

  /// Formatted bytes sent
  String get formattedBytesSent => _formatBytes(bytesSent);

  /// Formatted bytes received
  String get formattedBytesReceived => _formatBytes(bytesReceived);

  /// Total bytes
  int get totalBytes => bytesSent + bytesReceived;

  /// Formatted total bytes
  String get formattedTotalBytes => _formatBytes(totalBytes);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  String toString() {
    return 'ConnectionStats(sent: $formattedBytesSent, received: $formattedBytesReceived, latency: ${latencyMs}ms)';
  }
}
