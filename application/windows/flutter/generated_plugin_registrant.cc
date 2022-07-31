//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <url_launcher_windows/url_launcher_windows.h>
#include <window_interface/window_interface_plugin_c_api.h>
#include <xinlake_platform/xinlake_platform_plugin.h>
#include <xinlake_qrcode/xinlake_qrcode_plugin.h>
#include <xinlake_tunnel/xinlake_tunnel_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WindowInterfacePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowInterfacePluginCApi"));
  XinlakePlatformPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("XinlakePlatformPlugin"));
  XinlakeQrcodePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("XinlakeQrcodePlugin"));
  XinlakeTunnelPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("XinlakeTunnelPluginCApi"));
}
