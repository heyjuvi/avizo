# Avizo

Avizo is a simple notification daemon, mainly intended to be used for multimedia keys for example with Sway.

![Screenshot of Avizo's volume notification](https://raw.githubusercontent.com/misterdanb/avizo/master/github/screenshot.png)

## Configuration

Avizo can be configured using the configuration file and CLI options.

`avizo-client` looks for configuration file `avizo/config.ini` in the standard [XDG directories](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) `XDG_CONFIG_HOME` (defaults to `~/.config`) and `XDG_CONFIG_DIRS` (defaults to `/etc/xdg`), in that order.
The first found file is used.
Missing configuration file is not an error.

The configuration file must be in INI format and should define keys in section named `default`.
Names of the configuration keys correspond to the CLI options (e.g. `block-height`).

Any configuration key can be overridden by corresponding CLI option (i.e. CLI options take precedence).

## Sway config

```
bindsym XF86AudioRaiseVolume exec volumectl raise
bindsym XF86AudioLowerVolume exec volumectl lower
bindsym XF86AudioMute exec volumectl mute
bindsym XF86AudioMicMute exec volumectl mute --mic

bindsym XF86MonBrightnessUp exec lightctl raise
bindsym XF86MonBrightnessDown exec lightctl lower

exec "avizo-service"
```

## Install

### Manually

```
meson build
ninja -C build install
```

You may want to specify the installation directory (the above default to
`/usr/local/bin`). In such case you may use

```
meson -Dprefix=<your/installation/path> build
ninja -C build install
```

In some cases (like if you want to install the results to `/usr/bin`), the last
command needs to be run with root privileges.

### Arch User Repository

A package called avizo is also available in the Arch Linux User Repository.
