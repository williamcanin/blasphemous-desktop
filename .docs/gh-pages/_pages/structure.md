---
layout: base
title: Structure and Settings
permalink: /structure/
---

<!-- markdownlint-disable MD025 MD033 -->

<a href="{{ '/' | relative_url }}">&larr; Back to HOME</a>

# Structure and Settings

## Structure

```text
src/
  config/
    hypr/                Hyprland, Hyprpaper, Hypridle, Hyprlock, scripts, docs
    waybar/              Top bar, sysinfo panel, styles and scripts
    quickshell/          Right sidebar in QML/Quickshell (10 cards)
    rofi/                Launcher, theme selector, menus, scripts
    wofi/                Alternative launcher
    wlogout/             Logout screen
    kitty/               Main terminal with theme support
    foot/                Alternative terminal
    superfile/           Default TUI file manager (spf), config, hotkeys and themes
    yazi/                Alternative TUI file manager with flavors and custom keymaps
    dunst/               Notifications with per-app rules
    btop/ bottom/        System monitors with themes
    snappy-switcher/     Alt+Tab window switching
    environment.d/       Wayland environment variables
    term/                Shared shell options
    gtk-3.0/ gtk-4.0/    GTK3/GTK4 themes and settings
    blasphemous-desktop/      Active theme, .active-theme, .gtk-mode, .blasphemous-desktop-bootstrap and shell library (sh/)
  fonts/                 Local Font Awesome and Terminus
```

## Important settings

### Keyboard and language

`br,us` layout, `abnt2` variant and `Alt+Shift` to switch. Bilingual Portuguese/English support.

### Wayland session

Variables in `environment.d/wayland.conf` prioritize native Wayland execution for Qt, Firefox, Electron, SDL2, Java and LibreOffice.

### Autostart

When Hyprland starts, `init.sh --started` brings up:

- `hyprpaper`, `hypridle`
- Top Waybar + Waybar sysinfo
- `qs -c sidebar-right` (Quickshell sidebar)
- `dunst`, `snappy-switcher --daemon`
- `cliphist` watchers (text and image)
- `hyprpolkitagent` with Qt/QML style `org.hyprland.style`

### TTY login

`src/config/blasphemous-desktop/.blasphemous-desktop-bootstrap` is the single entry point (installed as `~/.config/.blasphemous-desktop-bootstrap`) that loads the shell library. The `.tools/setup.sh` script is the single installer/uninstaller, compatible with the Makefile commands and with remote installation via `curl | sh`.

### XWayland

`xwayland.enabled = false`. If needed, enable it in `hyprland.lua`.

### Wallpaper and lockscreen

Wallpapers are in `src/config/hypr/wallpapers/`. The lockscreen uses the wallpaper blurred by ImageMagick.
