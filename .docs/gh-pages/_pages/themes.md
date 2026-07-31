---
layout: base
title: Temas
permalink: /themes/
---

<a href="{{ '/' | relative_url }}">&larr; Voltar para HOME</a>

# Temas

O projeto possui **13 temas** (HyprSlate, HyprAshen + 11 inspirados na série *Blasphemous* e *Blasphemous II*), com suporte completo a:

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
| 01 | HyprSlate | Plano escuro ardósia (`#2F3541`) + texto `#A6B8C4` |
| 02 | HyprAshen | Plano escuro cinza (`#181818`) + texto `#757575`. Suporta alternância light/dark via `Mod+F5` — fundo `#cccccc`, texto `#181818` |
| 03 | Blasphemous - Penitent | Monocromático preto + `#e0e0e0` |
| 04 | Blasphemous - Echoes Of Salt | Escuro teal/cyan |
| 05 | Blasphemous - Fragment Of Guilt | Escuro olive/teal |
| 06 | Blasphemous - Kneeling Stone | Escuro roxo (Catppuccin-like) |
| 07 | Blasphemous - Requiem Aeternam | Monocromático preto + `#ba8540` |
| 08 | Blasphemous - Ten Piedad | Escuro terroso/warm |
| 09 | Blasphemous II - Mea Culpa | Escuro warm neutro |
| 10 | Blasphemous II - Repose Of The Silent One | Escuro teal/azulado |
| 11 | Blasphemous II - Red Forest | Claro bege/cinza |
| 12 | Blasphemous II - The Third Sin | Escuro navy/teal |
| 13 | Blasphemous II - Main Menu | Escuro azul-cinza com acentos dourados (`#996548`). Baseado na tela de menu do jogo. |

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

## Modo adaptativo (light/dark)

O HyprAshen suporta alternância entre modo escuro (dark) e claro (light) com `Mod+F5`, que aciona o script `toggle-mode.sh`.

Quando ativado, o script:

1. Alterna o tema GTK entre `Adwaita-dark` e `Adwaita` (`gsettings`).
2. Gera `mode.css` em `~/.config/waybar/` com as cores do modo claro, sobrescrevendo as variáveis do tema (importado por último em `style.css` e `sysinfo.css`).
3. Gera `mode.rasi` em `~/.config/rofi/` com as cores claras para o launcher.
4. Reinicia a waybar para aplicar o novo CSS.
5. Gera o wallpaper sólido `hyprashen-light.png` (`#386775`, 1920×1080) via ImageMagick e aplica com hyprpaper.
6. Escreve o arquivo `~/.config/my-environment/.gtk-mode` com `"light"` ou `"dark"` para o Quickshell.
7. O `Theme.qml` da sidebar lê `.gtk-mode` e ativa o objeto `light` com as cores invertidas.

Os arquivos de override são gerados dinamicamente e resetados para dark ao trocar de tema via `theme-switch.sh`.

```text
~/.config/waybar/mode.css              # Override de cores da waybar (gerado)
~/.config/rofi/mode.rasi               # Override de cores do rofi (gerado)
~/.config/my-environment/.gtk-mode     # Flag "light"/"dark" para o Quickshell (gerado)
~/.config/hypr/wallpapers/hyprashen-light.png  # Wallpaper sólido claro (gerado)
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
hyprslate.png     (gerado dinamicamente pelo theme-switch.sh via ImageMagick)
hyprashen.png     (symlink)
hyprashen-light.png  (gerado dinamicamente pelo toggle-mode.sh)
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
