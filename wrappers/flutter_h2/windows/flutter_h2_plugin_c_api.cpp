#include "include/flutter_h2/flutter_h2_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_h2_plugin.h"

void FlutterH2PluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_h2::FlutterH2Plugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
