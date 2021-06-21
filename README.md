# Avizo

Avizo is a simple notification daemon, mainly intended to be used for multimedia keys for example with Sway.

![Screenshot of Avizo's volume notification](https://raw.githubusercontent.com/misterdanb/avizo/master/github/screenshot.png)

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
