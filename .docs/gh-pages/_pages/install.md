---
layout: base
title: Installation
permalink: /install/
---

<a href="{{ '/' | relative_url }}">&larr; Back to HOME</a>

# Installation

## Requirements

- **Arch Linux** or **Fedora** 41+.
- Wayland session with `systemd`.
- Graphics card and drivers compatible with Wayland/Hyprland.

> Note: the configs include tweaks for NVIDIA and Nouveau, such as
> `WLR_NO_HARDWARE_CURSORS`, `WLR_RENDERER_ALLOW_SOFTWARE`, `GBM_BACKEND=nvidia-drm`
> and `LIBVA_DRIVER_NAME=nvidia`. Review these values if you use a different GPU.

## Installer

The `.tools/setup.sh` script works both as a local installer and as a remote installer via GitHub Releases.

**Online installation (RECOMMENDED) — downloads the latest stable release:**

```sh
sh -c "$(curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh)"
```

List the available versions:

```sh
sh -c "$(curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh)" -- --releases
```

Install a specific version:

```sh
sh -c "$(curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh)" -- 0.2.0
```

**Offline installation (from a cloned repository):**

```sh
git clone --depth=1 https://github.com/williamcanin/blasphemous-desktop.git && cd blasphemous-desktop && sh .tools/setup.sh --install
```

> Note: this installation method uses the `main` branch, which may contain files with bugs due to lack of review. Always prefer the `RECOMMENDED` option, which uses stable releases.
>
> If you keep the repository, update it before installing:

```sh
sh .tools/setup.sh --upgrade
```

Useful commands in offline mode:

```sh
make help          # or: sh .tools/setup.sh --help
make version       # or: sh .tools/setup.sh --version
make install       # or: sh .tools/setup.sh --install
make upgrade       # or: sh .tools/setup.sh --upgrade
make uninstall     # or: sh .tools/setup.sh --uninstall [--dry-run]
make set-permissions
```

The installer automatically detects the distribution via `/etc/os-release` — no manual selection needed.

In remote installation (`sh -c "$(curl ...)"`), the installer also checks the user's default shell and offers to switch to `/usr/bin/zsh` if needed.

In summary, the installer:

- **Arch**: installs `yay` (if needed) and packages via AUR;
- **Fedora**: enables the `solopasha/hyprland` COPR and installs packages via `dnf`;
- copies `src/config/*` to `~/.config`;
- backs up existing directories in `~/.config/*.bak.DATE`;
- copies `src/fonts` to `~/.local/share/fonts`;
- updates the font cache;
- adds `~/.config/term/options.sh` to the shell;
- applies Firefox as the default browser and a dark GTK theme.

> **Fedora**: `hyprshutdown` is compiled from source, `rofi-calc` is replaced by `qalculate-gtk`.
