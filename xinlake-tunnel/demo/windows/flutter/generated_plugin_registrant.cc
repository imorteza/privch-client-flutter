//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <window_interface/window_interface_plugin.h>
#include <xinlake_tunnel/xinlake_tunnel_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  WindowInterfacePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowInterfacePlugin"));
  XinlakeTunnelPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("XinlakeTunnelPlugin"));
}
