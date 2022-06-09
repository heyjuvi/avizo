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


## Helper scripts

### volumectl

Adjust the sound or mic volume and show Avizo notification.

**Requirements:**

* POSIX-sh compatible shell (e.g. Busybox ash, dash, ZSH, bash, …)
* common \*nix userland (BSD, Busybox or GNU)
* [pamixer](https://github.com/cdemoulins/pamixer)
* [pactl](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/CLI/#pactl), PulseAudio's Command Line Interface utility, for the optional tracking of the currently playing sink 

### lightctl

Adjust (display) brightness and show Avizo notification.

**Requirements:**

* POSIX-sh compatible shell (e.g. Busybox ash, dash, ZSH, bash, …)
* common \*nix userland (BSD, Busybox or GNU)
* [brightnessctl](https://github.com/Hummer12007/brightnessctl) or [light](https://github.com/haikarainen/light)


## Sway config

```
bindsym XF86AudioRaiseVolume exec volumectl -u up
bindsym XF86AudioLowerVolume exec volumectl -u down
bindsym XF86AudioMute exec volumectl toggle-mute
bindsym XF86AudioMicMute exec volumectl -m toggle-mute

bindsym XF86MonBrightnessUp exec lightctl up
bindsym XF86MonBrightnessDown exec lightctl down

exec "avizo-service"
```

## Install

### From package repository

Avizo is available in the following repositories:

[![Packaging status](https://repology.org/badge/vertical-allrepos/avizo-notification-daemon.svg)](https://repology.org/project/avizo-notification-daemon/versions)

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
