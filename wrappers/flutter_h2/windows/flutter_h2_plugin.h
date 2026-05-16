#ifndef FLUTTER_PLUGIN_FLUTTER_H2_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_H2_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_h2 {

class FlutterH2Plugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterH2Plugin();

  virtual ~FlutterH2Plugin();

  // Disallow copy and assign.
  FlutterH2Plugin(const FlutterH2Plugin&) = delete;
  FlutterH2Plugin& operator=(const FlutterH2Plugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_h2

#endif  // FLUTTER_PLUGIN_FLUTTER_H2_PLUGIN_H_
