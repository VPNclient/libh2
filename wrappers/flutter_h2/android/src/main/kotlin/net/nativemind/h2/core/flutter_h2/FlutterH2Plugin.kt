package net.nativemind.h2.core.flutter_h2

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import mobile.Mobile
import mobile.Client

/** FlutterH2Plugin - H2 VPN Engine for Flutter */
class FlutterH2Plugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var client: Client? = null
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_h2")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "connect" -> handleConnect(result)
            "disconnect" -> handleDisconnect(result)
            "getStats" -> handleGetStats(result)
            "getVersion" -> result.success(Mobile.version())
            "isRunning" -> result.success(client?.isRunning ?: false)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val serverAddr = call.argument<String>("serverAddr") ?: ""
        val cryptoProvider = call.argument<String>("cryptoProvider") ?: "us"

        if (serverAddr.isEmpty()) {
            result.success(false)
            return
        }

        client = Mobile.newClient(serverAddr, cryptoProvider)
        result.success(client != null)
    }

    private fun handleConnect(result: Result) {
        val currentClient = client
        if (currentClient == null) {
            result.success(-1)
            return
        }

        scope.launch {
            try {
                val port = currentClient.start()
                withContext(Dispatchers.Main) {
                    result.success(port.toInt())
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    sendLog("ERROR", "Connect failed: ${e.message}")
                    result.success(-1)
                }
            }
        }
    }

    private fun handleDisconnect(result: Result) {
        val currentClient = client
        if (currentClient == null) {
            result.success(null)
            return
        }

        scope.launch {
            try {
                currentClient.stop()
                withContext(Dispatchers.Main) {
                    result.success(null)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    sendLog("ERROR", "Disconnect failed: ${e.message}")
                    result.error("DISCONNECT_ERROR", e.message, null)
                }
            }
        }
    }

    private fun handleGetStats(result: Result) {
        val currentClient = client
        if (currentClient == null) {
            result.success(null)
            return
        }

        val stats = currentClient.stats
        if (stats != null) {
            result.success(
                mapOf(
                    "bytesIn" to stats.bytesIn,
                    "bytesOut" to stats.bytesOut,
                    "connCount" to stats.connCount,
                    "running" to stats.running,
                    "socksPort" to stats.socksPort
                )
            )
        } else {
            result.success(null)
        }
    }

    private fun sendLog(level: String, message: String) {
        channel.invokeMethod(
            "onLog",
            mapOf("level" to level, "message" to message)
        )
    }

    private fun sendStatusChange(status: String) {
        channel.invokeMethod("onStatusChanged", status)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
        try {
            client?.stop()
        } catch (_: Exception) {
        }
        client = null
    }
}
