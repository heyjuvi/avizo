# Lets the session bus start avizo-service when a client needs it.
dbus_service_conf = configuration_data()
dbus_service_conf.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))
configure_file(
  input : 'org.danb.avizo.service.service.in',
  output : 'org.danb.avizo.service.service',
  configuration : dbus_service_conf,
  install_dir : join_paths(get_option('datadir'), 'dbus-1', 'services')
)
