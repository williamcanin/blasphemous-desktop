---
layout: base
title: Instalação
permalink: /install/
---

<a href="{{ '/' | relative_url }}">&larr; Voltar para HOME</a>

# Instalação

## Requisitos

- **Arch Linux** ou **Fedora** 41+.
- Sessão Wayland com `systemd`.
- Placa de vídeo e drivers compatíveis com Wayland/Hyprland.

> Nota: os configs incluem ajustes para NVIDIA e Nouveau, como
> `WLR_NO_HARDWARE_CURSORS`, `WLR_RENDERER_ALLOW_SOFTWARE`, `GBM_BACKEND=nvidia-drm`
> e `LIBVA_DRIVER_NAME=nvidia`. Revise esses valores se usar outra GPU.

## Instalador

O script `.tools/setup.sh` funciona tanto como instalador local quanto como instalador remoto via GitHub Releases.

**Instalação online (RECOMENDADO) — baixa a última release estável:**

```sh
sh -c "$(curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh)"
```

Liste as versões disponíveis:

```sh
sh -c "$(curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh)" -- --releases
```

Instalar uma versão específica:

```sh
sh -c "$(curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh)" -- 0.2.0
```

**Instalação offline (a partir do repositório clonado):**

```sh
git clone --depth=1 https://github.com/williamcanin/blasphemous-desktop.git && cd blasphemous-desktop && sh .tools/setup.sh --install
```

> Nota: Essa forma de instalação usa a branch principal (`main`), que pode conter arquivos com bugs por falta de revisão. Prefira sempre a opção `RECOMENDADA` que usa releases estáveis.
>
> Se você mantiver o repositório, atualize antes de instalar:

```sh
sh .tools/setup.sh --upgrade
```

Comandos úteis no modo offline:

```sh
make help          # ou: sh .tools/setup.sh --help
make version       # ou: sh .tools/setup.sh --version
make install       # ou: sh .tools/setup.sh --install
make upgrade       # ou: sh .tools/setup.sh --upgrade
make uninstall     # ou: sh .tools/setup.sh --uninstall [--dry-run]
make set-permissions
```

O instalador detecta automaticamente a distribuição via `/etc/os-release` — sem necessidade de seleção manual.

Na instalação remota (`sh -c "$(curl ...)"`), o instalador também verifica o shell padrão do usuário e oferece trocar para `/usr/bin/zsh` se necessário.

Em resumo, o instalador:

- **Arch**: instala `yay` (se necessário) e pacotes via AUR;
- **Fedora**: ativa COPR `solopasha/hyprland` e instala pacotes via `dnf`;
- copia `src/config/*` para `~/.config`;
- cria backup dos diretórios existentes em `~/.config/*.bak.DATA`;
- copia `src/fonts` para `~/.local/share/fonts`;
- atualiza cache de fontes;
- adiciona `~/.config/term/options.sh` ao shell;
- aplica Firefox como navegador padrão e tema GTK escuro.

> **Fedora**: `hyprshutdown` é compilado do fonte, `rofi-calc` é substituído por `qalculate-gtk`.
