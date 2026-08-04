---
layout: base
title: Temas
permalink: /themes/
---

<a href="{{ '/' | relative_url }}">&larr; Voltar para HOME</a>

# Temas

O projeto possui **11 temas** inspirados na série *Blasphemous* e *Blasphemous II*, com suporte completo a:

- Hyprland (bordas, sombras, gaps)
- Waybar (barra superior + sysinfo)
- Quickshell (sidebar direita)
- Rofi
- Kitty
- Btop / Bottom
- Dunst
- Wlogout
- Snappy-switcher
- Yazi (flavor)
- Hyprlock

## Lista de Temas

| # | Tema | Tipo |
| --- | --- | --- |
| 01 | Blasphemous - Penitent | Monocromático preto + `#e0e0e0` |
| 02 | Blasphemous - Echoes Of Salt | Escuro teal/cyan |
| 03 | Blasphemous - Fragment Of Guilt | Escuro olive/teal |
| 04 | Blasphemous - Kneeling Stone | Escuro roxo (Catppuccin-like) |
| 05 | Blasphemous - Requiem Aeternam | Monocromático preto + `#ba8540` |
| 06 | Blasphemous - Ten Piedad | Escuro terroso/warm |
| 07 | Blasphemous II - Mea Culpa | Escuro warm neutro |
| 08 | Blasphemous II - Repose Of The Silent One | Escuro teal/azulado |
| 09 | Blasphemous II - Red Forest | Claro bege/cinza |
| 10 | Blasphemous II - The Third Sin | Escuro navy/teal |
| 11 | Blasphemous II - Main Menu | Escuro azul-cinza com acentos dourados (`#996548`). Baseado na tela de menu do jogo. |

Veja o preview de cada tema na [Galeria de Temas]({{ '/gallery/' | relative_url }}).

## Como usar

```sh
# Com seletor Rofi (menu interativo)
theme-switch

# Ou diretamente pelo nome
theme-switch blasphemous-echoes-of-salt
```

O tema ativo é armazenado em:

```text
~/.config/my-environment/.active-theme
```

## Estrutura de arquivos do tema

```text
src/config/hypr/themes/<theme>/theme.lua          # Bordas, gaps, sombras
src/config/hypr/themes/<theme>/hyprlock.conf       # Cores do lockscreen
src/config/hypr/themes/<theme>/hyprtoolkit.conf    # Paleta do hyprpolkitagent/Hypr* toolkit
src/config/hypr/themes/<theme>/application-style.conf # Estilo Qt/QML dos apps Hypr*
src/config/waybar/themes/<theme>/theme.css         # Cores da waybar topo
src/config/waybar/themes/<theme>/sysinfo-theme.css # Cores do painel sysinfo
src/config/quickshell/sidebar-right/themes/<theme>/Theme.qml  # Cores da sidebar QML
src/config/rofi/themes/<theme>/theme.rasi          # Cores do launcher
src/config/waybar/mode.css                         # Override dinâmico do modo light (gerado)
src/config/rofi/mode.rasi                          # Override dinâmico do modo light (gerado)
src/config/kitty/themes/<theme>/theme.conf         # Esquema de cores do terminal
src/config/btop/themes/<theme>/theme.theme         # Cores do monitor de sistema
src/config/bottom/themes/<theme>/bottom.toml       # Cores do btm
src/config/dunst/themes/<theme>/dunstrc.theme      # Cores das notificações
src/config/wlogout/themes/<theme>/theme.css        # Cores da tela de logout
src/config/snappy-switcher/themes/<theme>/theme.ini # Cores do alternador de janelas
src/config/superfile/theme/<theme>.toml            # Cores do file manager padrão
src/config/yazi/themes/<theme>/theme.toml          # Flavor do file manager
```

## Wallpapers

Cada tema possui um wallpaper correspondente em `src/config/hypr/wallpapers/`:

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
| `flexoki-dark` | Escuro (`#100F0F`) com accent cyan |
| `flexoki-fragment-of-guilt` | Claro (`#EEF7F4`) com accent verde |
| `repose-of-the-silent-one` | Escuro (`#141E1E`) com accent teal |
