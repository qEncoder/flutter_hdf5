//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <numd_c_libs/numd_c_libs_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) numd_c_libs_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "NumdCLibsPlugin");
  numd_c_libs_plugin_register_with_registrar(numd_c_libs_registrar);
}
