glib_dep = dependency('glib-2.0')
gtk_dep = dependency('gtk+-3.0')
gobject_dep = dependency('gobject-2.0')
gobject_introspection_dep = dependency('gobject-introspection-1.0')

config_data = configuration_data()
config_data.set_quoted('VERSION', meson.project_version())
config_vala = configure_file(
  input : 'config.vala.in',
  output : 'config.vala',
  configuration : config_data
)

app_sources_service = files(
  'avizo_service.vala'
)

app_sources_client = files(
  'avizo_client.vala'
)

sources_service = [
  config_vala,
  app_resources_service,
  app_sources_service
]

sources_client = [
  config_vala,
  app_sources_client
]

gtk_layer_shell = dependency('gtk-layer-shell-0', fallback: ['gtk-layer-shell'])
if gtk_layer_shell.version() >= '0.6.0'
  add_project_arguments('-D', 'HAVE_LATEST_GTK_LAYER_SHELL', language: 'vala')
endif

executable('avizo-service',
  sources_service,
  vala_args: ['--pkg=GtkLayerShell-0.1'],
  dependencies: [
    glib_dep,
    gtk_dep,
    gobject_dep,
    gobject_introspection_dep,
    meson.get_compiler('c').find_library('gtk-layer-shell'),
    meson.get_compiler('c').find_library('m', required : false)
  ],
  install: true,
)

executable('avizo-client',
  sources_client,
  dependencies: [
    glib_dep,
    gtk_dep,
    gobject_dep,
    gobject_introspection_dep,
  ],
  install: true,
)
