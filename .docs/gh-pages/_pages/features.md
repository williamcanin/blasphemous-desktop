---
layout: base
title: Features e Componentes
permalink: /features/
---

<a href="{{ '/' | relative_url }}">&larr; Voltar para HOME</a>

# Features e Componentes

## Features

- Hyprland 0.55+ configurado em Lua.
- Layout `dwindle`, gaps, cantos arredondados, blur, sombras e animações.
- Workspaces de 1 a 9, navegação por teclado e modo de resize para janelas flutuantes.
- Agrupamento de janelas em abas e alternância global com `snappy-switcher`.
- Waybar superior com workspaces, janela ativa, MPRIS, áudio, rede, CPU, memória, data/hora, idioma do teclado, bandeja, gravação e menu de energia.
- Waybar lateral de sysinfo com máquina, CPU/GPU, memória, storage, processos, rede e lembrete de atalhos.
- Quickshell sidebar direita com notificações, calendário, clima, volume, rede, CPU/RAM/GPU, layout do teclado e perfis de energia.
- Rofi como launcher, seletor de temas, menu de energia, calculadora e clipboard picker.
- Histórico de clipboard com `cliphist`, `wl-clipboard` e integração com Rofi.
- Screenshots com `hyprshot` e edição de região com `satty`.
- Gravação de tela com `gpu-screen-recorder`, pausa/retomada e status na Waybar.
- Bloqueio com `hyprlock`, wallpaper desfocado gerado por `magick`, idle via `hypridle` e tela de logout com `wlogout`.
- Sistema completo de temas com 13 variações temáticas (HyprSlate, HyprAshen e 11 inspiradas em *Blasphemous*). HyprAshen suporta alternância light/dark com `Mod+F5`.
- Wofi como launcher alternativo ao Rofi.
- `my-environment/sh/` — biblioteca shell compartilhada com funções de logging, locale, notificações, JSON, manipulação de strings e caminhos.
- Áudio via PipeWire/WirePlumber, controle por `wpctl`, `pamixer` e `pwvucontrol`.
- Suporte a atalhos multimídia, brilho, color picker, emoji picker e navegador padrão.
- Terminais Kitty e Foot com JetBrainsMono Nerd Font, Font Awesome e temas por tema ativo.
- Superfile (`spf`) como file manager padrão, aberto em Kitty com `Super + Space` e integrado ao sistema de temas.
- Yazi com flavors customizados (flexoki-dark, flexoki-fragment-of-guilt, repose-of-the-silent-one).
- Configurações Wayland para Firefox, Electron, SDL2, Java, LibreOffice e cursor.
- Tema GTK escuro com Graphite-teal-Dark e Mint-Y-Teal para ícones aplicado pelo instalador. No HyprAshen, `Mod+F5` alterna entre GTK dark/light e adapta waybar, quickshell, rofi e wallpaper simultaneamente.
- Suporte bilíngue (Português/Inglês) em cheatsheets, menus, sidebar e scripts.

## Componentes

| Componente | Uso no setup |
| --- | --- |
| Hyprland | Window manager Wayland |
| Hyprlua | Configuração do Hyprland em Lua |
| Hyprpaper | Wallpaper |
| Hypridle | Idle e bloqueio automático |
| Hyprlock | Tela de bloqueio |
| Waybar | Barra superior + painel lateral de sysinfo |
| Quickshell | Sidebar direita com widgets em QML |
| Rofi | Launcher, seletor de temas, menus e calculadora |
| Wofi | Launcher alternativo |
| Dunst | Notificações |
| Kitty / Foot | Terminais |
| Superfile (`spf`) | File manager TUI padrão |
| Yazi | File manager TUI alternativo com flavors temáticos |
| Nautilus | File manager gráfico opcional |
| Snappy Switcher | Alternância de janelas com `Alt+Tab` |
| PipeWire / WirePlumber | Áudio |
| Cliphist / wl-clipboard | Histórico de clipboard |
| Hyprshot / Satty | Screenshots |
| gpu-screen-recorder | Gravação de tela |
| Bottom / Btop | Monitores de sistema |
