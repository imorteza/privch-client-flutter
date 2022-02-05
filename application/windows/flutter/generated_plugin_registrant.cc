//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <url_launcher_windows/url_launcher_windows.h>
#include <window_interface/window_interface_plugin.h>
#include <xinlake_platform/xinlake_platform_plugin.h>
#include <xinlake_qrcode/xinlake_qrcode_plugin.h>
#include <xinlake_tunnel/xinlake_tunnel_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WindowInterfacePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowInterfacePlugin"));
  XinlakePlatformPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("XinlakePlatformPlugin"));
  XinlakeQrcodePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("XinlakeQrcodePlugin"));
  XinlakeTunnelPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("XinlakeTunnelPlugin"));
}
