---
layout: base
title: Uso no dia a dia
permalink: /usage/
---

<a href="{{ '/' | relative_url }}">&larr; Voltar para HOME</a>

# Uso no dia a dia

## Sidebar Quickshell

Sidebar direita com painéis expansíveis em QML:

| Card | Função |
| --- | --- |
| User | Avatar, nome, usuário@hostname |
| Notifications | Histórico do Dunst (9 notificações, paginação) |
| Calendar | Calendário interativo com navegação |
| Weather | Clima via wttr.in (atualização a cada 15min) |
| Volume | Controle de áudio com `wpctl` |
| Network | IP, SSID, velocidades up/down |
| System | CPU, RAM, GPU, VRAM, temperatura GPU |
| Keyboard | Alternador de layout (BR ABNT2 / US) |
| Appearance | Seleção de wallpaper e tema |
| Power | Perfis de energia (powersave/balanced/performance) |

A sidebar carrega o tema dinamicamente — ao trocar o tema, as cores são atualizadas sem reiniciar.

## Scripts

### Hyprland (`src/config/hypr/scripts/`)

| Script | Função |
| --- | --- |
| `init.sh` | Inicialização/restart do ambiente |
| `screenshot.sh` | Screenshot e gravação de tela |
| `wallpaper-pick.sh` | Seletor de wallpaper com Yazi |
| `power-menu.sh` | Menu de energia (lock/suspend/logout/reboot/shutdown) |
| `cheatsheets.sh` | Cheatsheet de atalhos no Rofi |

### Waybar (`src/config/waybar/scripts/`)

| Script | Função |
| --- | --- |
| `taskbar.sh` | Dispatcher de ações da barra |
| `window-or-mpris.sh` | Título da janela ativa ou MPRIS |
| `netctl.sh` | Ativar/desativar interface de rede |

### Sysinfo (`src/config/waybar/scripts/sysinfo/`)

| Script | Função |
| --- | --- |
| `header.sh` | Cabeçalhos do painel (i18n) |
| `machine-info.sh` | SO, kernel, CPU, GPU, uptime |
| `temperature-usage_cpu-gpu.sh` | Temperatura e uso CPU/GPU |
| `memory.sh` | Uso de RAM |
| `storage.sh` | Uso de disco |
| `top-processes.sh` | Top processos por CPU |
| `network.sh` | Informações de rede |
| `gpu.sh` | Detalhes da GPU |

### Shell library (`src/config/my-environment/sh/`)

| Módulo | Função |
| --- | --- |
| `bootstrap.sh` | Carrega todos os módulos |
| `variables.sh` | Variáveis de ambiente do sistema |
| `paths.sh` | Funções `paths_cache()` e `paths_config()` |
| `locale.sh` | Detecção de locale PT/EN |
| `log.sh` | Logging (info, warn, error, die) |
| `notify.sh` | Notificações via notify-send |
| `string.sh` | Utilitários de string (barra de progresso) |
| `json.sh` | Escape e saída JSON para Waybar |
| `hypr.sh` | Parse de caminhos do Hyprland |
| `theme-switch.sh` | Alternância completa de temas (symlink: `theme-switch`) |
| `toggle-mode.sh` | Alterna modo claro/escuro (GTK + waybar + quickshell + rofi + wallpaper) |

## Atalhos principais

| Atalho | Ação |
| --- | --- |
| `Super + Enter` | Abrir Kitty |
| `Super + Space` | Abrir Superfile (`spf`) |
| `Super + D` | Abrir launcher Rofi |
| `Super + B` | Abrir navegador padrão |
| `Super + Q` | Fechar janela |
| `Super + F5` | Alternar modo claro/escuro (HyprAshen) |
| `Super + F` | Alternar fullscreen |
| `Super + S` | Alternar maximizado |
| `Super + E` | Alternar direção do split |
| `Super + W` | Agrupar/desagrupar janelas em abas |
| `Super + Tab` | Navegar entre abas do grupo |
| `Alt + Tab` | Alternar entre janelas com Snappy Switcher |
| `Super + ,` | Abrir/fechar sidebar Quickshell |
| `Super + Shift + T` | Selecionar tema com Rofi |
| `Super + 1..9` | Ir para workspace |
| `Super + Shift + 1..9` | Mover janela para workspace |
| `Ctrl + Alt + ←/→` | Navegar workspaces (loop) |
| `Super + ↑/↓/←/→` | Foco direcional |
| `Super + Shift + ↑/↓/←/→` | Mover janela na direção |
| `Super + R` | Entrar no modo resize para janela flutuante |
| `Super + H` | Abrir histórico do clipboard |
| `Super + Shift + H` | Limpar histórico do clipboard |
| `Super + P` | Seletor de cores (hyprpicker) |
| `Super + C` | Calculadora no Rofi |
| `Super + .` | Seletor de emoji (rofimoji) |
| `Super + L` | Bloquear sessão |
| `Super + Esc` | Sair do sistema |
| `Super + Shift + M` | Alternar DPMS do monitor |
| `Super + Shift + R` | Recarregar Hyprland |
| `Print` | Capturar região (hyprshot + satty) |
| `Super + Print` | Capturar janela |
| `Super + Shift + Print` | Capturar tela inteira |
| `Super + G` | Iniciar, pausar ou retomar gravação |
| `Super + Shift + G` | Parar e salvar gravação |

Para ver a lista completa dentro da sessão:

```text
Super + Shift + /?
```

Os textos completos ficam em:

- `src/config/hypr/docs/cheatsheets/pt.txt`
- `src/config/hypr/docs/cheatsheets/en.txt`
- `src/config/kitty/docs/cheatsheets/pt.txt`
- `src/config/kitty/docs/cheatsheets/en.txt`
