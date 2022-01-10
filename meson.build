project('avizo', 'c', 'vala',
        version: '1.1',
        license: 'GPLv3+')

add_project_arguments(['--target-glib=2.38'],
                      language: 'vala')

gnome = import('gnome')

app_resources_service = gnome.compile_resources(
  'avizo-resources', 'avizo.gresource.xml',
  source_dir : '.',
  c_name : 'avizo_resources')

sysconfdir = get_option('sysconfdir')

install_data('config.ini', install_dir: join_paths(sysconfdir, 'xdg/avizo'))
install_data('volumectl', install_dir: 'bin')
install_data('lightctl', install_dir: 'bin')

subdir('src')
subdir('data')
