#ifndef FLUTTER_PLUGIN_WINDOW_INTERFACE_PLUGIN_H_
#define FLUTTER_PLUGIN_WINDOW_INTERFACE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace WindowInterface {

    class WindowInterfacePlugin : public flutter::Plugin {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

        WindowInterfacePlugin();
        virtual ~WindowInterfacePlugin();

        // Disallow copy and assign.
        WindowInterfacePlugin(const WindowInterfacePlugin&) = delete;
        WindowInterfacePlugin& operator=(const WindowInterfacePlugin&) = delete;

    private:
        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue>& method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    };

}

#endif  // FLUTTER_PLUGIN_WINDOW_INTERFACE_PLUGIN_H_
