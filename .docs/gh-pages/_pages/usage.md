---
layout: base
title: Daily usage
permalink: /usage/
---

<a href="{{ '/' | relative_url }}">&larr; Back to HOME</a>

# Daily usage

## Quickshell sidebar

Right sidebar with expandable panels in QML:

| Card | Function |
| --- | --- |
| User | Avatar, name, user@hostname |
| Notifications | Dunst history (9 notifications, pagination) |
| Calendar | Interactive calendar with navigation |
| Weather | Weather via wttr.in (updates every 15min) |
| Volume | Audio control with `wpctl` |
| Network | IP, SSID, up/down speeds |
| System | CPU, RAM, GPU, VRAM, GPU temperature |
| Keyboard | Layout switcher (BR ABNT2 / US) |
| Appearance | Wallpaper and theme selection |
| Power | Power profiles (powersave/balanced/performance) |

The sidebar loads the theme dynamically — when switching themes, colors update without restarting.

## Scripts

### Hyprland (`src/config/hypr/scripts/`)

| Script | Function |
| --- | --- |
| `init.sh` | Environment startup/restart |
| `screenshot.sh` | Screenshot and screen recording |
| `wallpaper-pick.sh` | Wallpaper picker with Yazi |
| `power-menu.sh` | Power menu (lock/suspend/logout/reboot/shutdown) |
| `cheatsheets.sh` | Keyboard shortcut cheatsheet in Rofi |

### Waybar (`src/config/waybar/scripts/`)

| Script | Function |
| --- | --- |
| `taskbar.sh` | Bar action dispatcher |
| `window-or-mpris.sh` | Active window title or MPRIS |
| `netctl.sh` | Enable/disable network interface |

### Sysinfo (`src/config/waybar/scripts/sysinfo/`)

| Script | Function |
| --- | --- |
| `header.sh` | Panel headers (i18n) |
| `machine-info.sh` | OS, kernel, CPU, GPU, uptime |
| `temperature-usage_cpu-gpu.sh` | CPU/GPU temperature and usage |
| `memory.sh` | RAM usage |
| `storage.sh` | Disk usage |
| `top-processes.sh` | Top processes by CPU |
| `network.sh` | Network information |
| `gpu.sh` | GPU details |

### Shell library (`src/config/blasphemous-desktop/sh/`)

| Module | Function |
| --- | --- |
| `bootstrap.sh` | Loads all modules |
| `variables.sh` | System environment variables |
| `paths.sh` | `paths_cache()` and `paths_config()` functions |
| `locale.sh` | PT/EN locale detection |
| `log.sh` | Logging (info, warn, error, die) |
| `notify.sh` | Notifications via notify-send |
| `string.sh` | String utilities (progress bar) |
| `json.sh` | JSON escaping and output for Waybar |
| `hypr.sh` | Hyprland path parsing |
| `theme-switch.sh` | Full theme switching (symlink: `theme-switch`) |
| `toggle-mode.sh` | Toggles light/dark mode (GTK + waybar + quickshell + rofi + wallpaper) |

## Main shortcuts

| Shortcut | Action |
| --- | --- |
| `Super + Enter` | Open Kitty |
| `Super + Space` | Open Superfile (`spf`) |
| `Super + D` | Open Rofi launcher |
| `Super + B` | Open default browser |
| `Super + Q` | Close window |
| `Super + F5` | Toggle light/dark GTK theme |
| `Super + F` | Toggle fullscreen |
| `Super + S` | Toggle maximize |
| `Super + E` | Toggle split direction |
| `Super + W` | Group/ungroup windows into tabs |
| `Super + Tab` | Navigate between group tabs |
| `Alt + Tab` | Switch between windows with Snappy Switcher |
| `Super + ,` | Open/close Quickshell sidebar |
| `Super + Shift + T` | Select theme with Rofi |
| `Super + 1..9` | Go to workspace |
| `Super + Shift + 1..9` | Move window to workspace |
| `Ctrl + Alt + ←/→` | Navigate workspaces (loop) |
| `Super + ↑/↓/←/→` | Directional focus |
| `Super + Shift + ↑/↓/←/→` | Move window in direction |
| `Super + R` | Enter resize mode for floating window |
| `Super + H` | Open clipboard history |
| `Super + Shift + H` | Clear clipboard history |
| `Super + P` | Color picker (hyprpicker) |
| `Super + C` | Calculator in Rofi |
| `Super + .` | Emoji picker (rofimoji) |
| `Super + L` | Lock session |
| `Super + Esc` | Exit system |
| `Super + Shift + M` | Toggle monitor DPMS |
| `Super + Shift + R` | Reload Hyprland |
| `Print` | Capture region (hyprshot + satty) |
| `Super + Print` | Capture window |
| `Super + Shift + Print` | Capture entire screen |
| `Super + G` | Start, pause or resume recording |
| `Super + Shift + G` | Stop and save recording |

To see the full list inside the session:

```text
Super + Shift + /?
```

The full texts are located in:

- `src/config/hypr/docs/cheatsheets/pt.txt`
- `src/config/hypr/docs/cheatsheets/en.txt`
- `src/config/kitty/docs/cheatsheets/pt.txt`
- `src/config/kitty/docs/cheatsheets/en.txt`
