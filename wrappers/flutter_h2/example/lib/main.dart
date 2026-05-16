import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_h2/flutter_h2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _engine = VpnClientEngine.instance;
  String _status = 'Disconnected';
  String _stats = '';
  int _socksPort = 0;

  StreamSubscription<ConnectionStatus>? _statusSub;
  StreamSubscription<ConnectionStats>? _statsSub;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _statusSub = _engine.statusStream.listen((status) {
      setState(() {
        _status = status.toNativeString();
        _socksPort = _engine.getSocksPort();
      });
    });

    _statsSub = _engine.statsStream.listen((stats) {
      setState(() {
        _stats = 'Up: ${stats.formattedBytesSent}, Down: ${stats.formattedBytesReceived}';
      });
    });
  }

  Future<void> _connect() async {
    // Example config - replace with your server
    final config = VpnEngineConfig(
      core: CoreConfig(
        type: CoreType.h2,
        configJson: '{}',
        serverAddress: 'vpn.example.com',
        serverPort: 443,
        protocol: 'us',
      ),
    );

    await _engine.initialize(config);
    await _engine.connect();
  }

  Future<void> _disconnect() async {
    await _engine.disconnect();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _statsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('H2 VPN Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: $_status', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              if (_socksPort > 0)
                Text('SOCKS5 Proxy: 127.0.0.1:$_socksPort'),
              const SizedBox(height: 8),
              if (_stats.isNotEmpty)
                Text('Traffic: $_stats'),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _connect,
                    child: const Text('Connect'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _disconnect,
                    child: const Text('Disconnect'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
