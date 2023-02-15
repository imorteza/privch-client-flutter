#include "include/window_interface/window_interface_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "window_interface_plugin.h"

void WindowInterfacePluginCApiRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
    WindowInterface::WindowInterfacePlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
        ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
