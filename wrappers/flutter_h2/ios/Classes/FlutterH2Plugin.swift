import Flutter
import UIKit
import H2Core

public class FlutterH2Plugin: NSObject, FlutterPlugin {
    private var client: MobileClient?
    private var channel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_h2",
            binaryMessenger: registrar.messenger()
        )
        let instance = FlutterH2Plugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "connect":
            handleConnect(result: result)
        case "disconnect":
            handleDisconnect(result: result)
        case "getStats":
            handleGetStats(result: result)
        case "getVersion":
            result(MobileVersion())
        case "isRunning":
            result(client?.isRunning() ?? false)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let serverAddr = args["serverAddr"] as? String else {
            result(false)
            return
        }

        let cryptoProvider = args["cryptoProvider"] as? String ?? "us"

        // Create new client
        client = MobileNewClient(serverAddr, cryptoProvider)
        result(client != nil)
    }

    private func handleConnect(result: @escaping FlutterResult) {
        guard let client = client else {
            result(-1)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                var port: Int = 0
                try client.start(&port)
                DispatchQueue.main.async {
                    result(port)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.sendLog(level: "ERROR", message: "Connect failed: \(error.localizedDescription)")
                    result(-1)
                }
            }
        }
    }

    private func handleDisconnect(result: @escaping FlutterResult) {
        guard let client = client else {
            result(nil)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                try client.stop()
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.sendLog(level: "ERROR", message: "Disconnect failed: \(error.localizedDescription)")
                    result(FlutterError(
                        code: "DISCONNECT_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            }
        }
    }

    private func handleGetStats(result: @escaping FlutterResult) {
        guard let client = client else {
            result(nil)
            return
        }

        let stats = client.getStats()
        if let stats = stats {
            result([
                "bytesIn": stats.bytesIn,
                "bytesOut": stats.bytesOut,
                "connCount": stats.connCount,
                "running": stats.running,
                "socksPort": stats.socksPort
            ])
        } else {
            result(nil)
        }
    }

    private func sendLog(level: String, message: String) {
        channel?.invokeMethod("onLog", arguments: [
            "level": level,
            "message": message
        ])
    }

    private func sendStatusChange(status: String) {
        channel?.invokeMethod("onStatusChanged", arguments: status)
    }
}
