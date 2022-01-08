glib_dep = dependency('glib-2.0')
gtk_dep = dependency('gtk+-3.0')
gobject_dep = dependency('gobject-2.0')

app_sources_service = files(
  'avizo_service.vala'
)

app_sources_client = files(
  'avizo_client.vala'
)

sources_service = [
  app_resources_service,
  app_sources_service
]

sources_client = [
  app_sources_client
]

executable('avizo-service',
  sources_service,
  vala_args: ['--pkg=GtkLayerShell-0.1'],
  dependencies: [
    glib_dep,
    gtk_dep,
    gobject_dep,
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
  ],
  install: true,
)
