---
layout: base
title: Themes
permalink: /themes/
---

<a href="{{ '/' | relative_url }}">&larr; Back to HOME</a>

# Themes

The project has **11 themes** inspired by the *Blasphemous* and *Blasphemous II* series, with full support for:

- Hyprland (borders, shadows, gaps)
- Waybar (top bar + sysinfo)
- Quickshell (right sidebar)
- Rofi
- Kitty
- Btop / Bottom
- Dunst
- Wlogout
- Snappy-switcher
- Yazi (flavor)
- Hyprlock

## Theme list

| # | Theme | Type |
| --- | --- | --- |
| 01 | Blasphemous - Penitent | Black monochrome + `#e0e0e0` |
| 02 | Blasphemous - Echoes Of Salt | Dark teal/cyan |
| 03 | Blasphemous - Fragment Of Guilt | Dark olive/teal |
| 04 | Blasphemous - Kneeling Stone | Dark purple (Catppuccin-like) |
| 05 | Blasphemous - Requiem Aeternam | Black monochrome + `#ba8540` |
| 06 | Blasphemous - Ten Piedad | Dark earthy/warm |
| 07 | Blasphemous II - Mea Culpa | Dark warm neutral |
| 08 | Blasphemous II - Repose Of The Silent One | Dark teal/bluish |
| 09 | Blasphemous II - Red Forest | Light beige/gray |
| 10 | Blasphemous II - The Third Sin | Dark navy/teal |
| 11 | Blasphemous II - Main Menu | Dark blue-gray with golden accents (`#996548`). Based on the game's menu screen. |

See the preview of each theme in the [Theme Gallery]({{ '/gallery/' | relative_url }}).

## How to use

```sh
# With the Rofi selector (interactive menu)
theme-switch

# Or directly by name
theme-switch blasphemous-echoes-of-salt
```

The active theme is stored in:

```text
~/.config/blasphemous-desktop/.active-theme
```

## Theme file structure

```text
src/config/hypr/themes/<theme>/theme.lua          # Borders, gaps, shadows
src/config/hypr/themes/<theme>/hyprlock.conf       # Lockscreen colors
src/config/hypr/themes/<theme>/hyprtoolkit.conf    # hyprpolkitagent/Hypr* toolkit palette
src/config/hypr/themes/<theme>/application-style.conf # Qt/QML style for Hypr* apps
src/config/waybar/themes/<theme>/theme.css         # Top Waybar colors
src/config/waybar/themes/<theme>/sysinfo-theme.css # Sysinfo panel colors
src/config/quickshell/sidebar-right/themes/<theme>/Theme.qml  # QML sidebar colors
src/config/rofi/themes/<theme>/theme.rasi          # Launcher colors
src/config/waybar/mode.css                         # Dynamic light mode override (generated)
src/config/rofi/mode.rasi                          # Dynamic light mode override (generated)
src/config/kitty/themes/<theme>/theme.conf         # Terminal color scheme
src/config/btop/themes/<theme>/theme.theme         # System monitor colors
src/config/bottom/themes/<theme>/bottom.toml       # btm colors
src/config/dunst/themes/<theme>/dunstrc.theme      # Notification colors
src/config/wlogout/themes/<theme>/theme.css        # Logout screen colors
src/config/snappy-switcher/themes/<theme>/theme.ini # Window switcher colors
src/config/superfile/theme/<theme>.toml            # Default file manager colors
src/config/yazi/themes/<theme>/theme.toml          # File manager flavor
```

## Wallpapers

Each theme has a matching wallpaper in `src/config/hypr/wallpapers/`:

```text
blasphemous-echoes-of-salt.jpeg
blasphemous-fragment-of-guilt.png
blasphemous-kneeling-stone.png
blasphemous-mea-culpa.png
blasphemous-II-repose-of-the-silent-one.jpg
blasphemous-II-red-forest.png
blasphemous-II-the-third-sin.jpg
blasphemous-II-main-menu.png
blasphemous-ten-piedad.jpg
blasphemous-penitent.jpg
blasphemous-requiem-aeternam.jpg
```

## Yazi Flavors

| Flavor | Base |
| --- | --- |
| `flexoki-dark` | Dark (`#100F0F`) with cyan accent |
| `flexoki-fragment-of-guilt` | Light (`#EEF7F4`) with green accent |
| `repose-of-the-silent-one` | Dark (`#141E1E`) with teal accent |
