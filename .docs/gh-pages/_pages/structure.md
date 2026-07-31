---
layout: base
title: Estrutura e Configurações
permalink: /structure/
---

<!-- markdownlint-disable MD025 MD033 -->

<a href="{{ '/' | relative_url }}">&larr; Voltar para HOME</a>

# Estrutura e Configurações

## Estrutura

```text
src/
  config/
    hypr/                Hyprland, Hyprpaper, Hypridle, Hyprlock, scripts, docs
    waybar/              Barra superior, painel sysinfo, estilos e scripts
    quickshell/          Sidebar direita em QML/Quickshell (10 cards)
    rofi/                Launcher, seletor de temas, menus, scripts
    wofi/                Launcher alternativo
    wlogout/             Tela de logout
    kitty/               Terminal principal com suporte a temas
    foot/                Terminal alternativo
    superfile/           File manager TUI padrão (spf), config, hotkeys e temas
    yazi/                File manager TUI alternativo com flavors e keymaps custom
    dunst/               Notificações com regras por aplicativo
    btop/ bottom/        Monitores de sistema com temas
    snappy-switcher/     Alternância de janelas Alt+Tab
    environment.d/       Variáveis de ambiente Wayland
    term/                Opções compartilhadas do shell
    gtk-3.0/ gtk-4.0/    Temas e configurações GTK3/GTK4
    my-environment/      Tema ativo, .active-theme, .gtk-mode, .my-environment-bootstrap e biblioteca shell (sh/)
  fonts/                 Font Awesome e Terminus local
```

## Configurações importantes

### Teclado e idioma

Layout `br,us`, variante `abnt2` e alternância com `Alt+Shift`. Suporte bilíngue Português/Inglês.

### Sessão Wayland

Variáveis em `environment.d/wayland.conf` priorizam execução nativa Wayland para Qt, Firefox, Electron, SDL2, Java e LibreOffice.

### Autostart

Ao iniciar o Hyprland, `init.sh --started` sobe:

- `hyprpaper`, `hypridle`
- Waybar superior + Waybar sysinfo
- `qs -c sidebar-right` (Quickshell sidebar)
- `dunst`, `snappy-switcher --daemon`
- `cliphist` watchers (texto e imagem)
- `hyprpolkitagent` com estilo Qt/QML `org.hyprland.style`

### Login via TTY

`src/config/my-environment/.my-environment-bootstrap` é o ponto de entrada único (instalado em `~/.config/.my-environment-bootstrap`) que carrega a biblioteca shell. O script `.tools/setup.sh` é o instalador/uninstaller único, compatível com os comandos do Makefile e com instalação remota via `curl | sh`.

### XWayland

`xwayland.enabled = false`. Se precisar, ative em `hyprland.lua`.

### Wallpaper e lockscreen

Wallpapers em `src/config/hypr/wallpapers/`. O lockscreen usa o wallpaper com blur gerado por ImageMagick.
