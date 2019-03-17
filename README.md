# Avizo

## Sway config

```
bindsym XF86AudioRaiseVolume exec volumectl raise
bindsym XF86AudioLowerVolume exec volumectl lower
bindsym XF86AudioMute exec volumectl mute

bindsym XF86MonBrightnessUp exec lightctl raise
bindsym XF86MonBrightnessDown exec lightctl lower

exec "avizo-service"
```

## Install

### Manually

```
meson build
ninja install
```

### Arch User Repository

A package called avizo is also available in the Arch Linux User Repository.
