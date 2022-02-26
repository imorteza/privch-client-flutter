cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "xinlake_tunnel")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "xinlake_tunnel_plugin")

add_library(${PLUGIN_NAME} SHARED
  "xinlake_tunnel_plugin.cpp"
  "xinlake_tunnel_event.cpp"
  "xinlake_tunnel_method.cpp"
  "process_ctrl.cpp"  
  "proxy_ctrl.cpp"
  "resource.rc"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(xinlake_tunnel_bundled_libraries
  ""
  PARENT_SCOPE
)
