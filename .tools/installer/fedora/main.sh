#!/usr/bin/env sh

# shellcheck disable=SC1091,SC2086

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

. "$SCRIPT_DIR/../libs/base.sh"
. "$SCRIPT_DIR/../libs/version.sh"
. "$SCRIPT_DIR/../libs/msg.sh"
. "$SCRIPT_DIR/../libs/help.sh"
. "$SCRIPT_DIR/../libs/symlink.sh"
. "$SCRIPT_DIR/../libs/term.sh"
. "$SCRIPT_DIR/../libs/cosmic.sh"
. "$SCRIPT_DIR/../libs/copyright.sh"

# When run via sudo, adjust HOME to the original user
if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-${DOAS_USER:-}}" ]; then
  user="${SUDO_USER:-${DOAS_USER:-}}"
  REAL_HOME="$(getent passwd "$user" | cut -d: -f6)" || REAL_HOME=""
  if [ -n "$REAL_HOME" ] && [ -d "$REAL_HOME" ]; then
    HOME="$REAL_HOME"
    warn "Root execution detected — using HOME=$HOME"
  fi
fi

CONFIG_SRC="$REPO_ROOT/src/config"
CONFIG_DST="$HOME/.config"
FONTS_SRC="$REPO_ROOT/src/fonts"
FONTS_DST="$HOME/.local/share/fonts"
LOCK_FILE="$CONFIG_DST/blasphemous-desktop/.install.lock"

BASE_DEPS="git @development-tools golang gcc lua wayland wayland-protocols-devel"

PACKAGES="
  firefox hyprland hyprland-qt-support hyprpaper hypridle hyprlock
  hyprshot rofi-wayland kitty wev playerctl brightnessctl moreutils quickshell
  flameshot grim cliphist wl-clipboard slurp zsh wf-recorder
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk mpv
  xdg-desktop-portal-wlr unzip zathura terminus-fonts nautilus ImageMagick
  dunst jq rofimoji qalculate-gtk bottom btop satty gsimplecal calcurse hyprpicker
  xdg-utils gtk3 gtk4 adwaita-icon-theme google-noto-fonts google-noto-emoji-fonts
  vivid libnotify pamixer wireplumber NetworkManager swappy foot
  xarchiver zip just libqalculate fontconfig qt5-qtquickcontrols2
  kvantum nwg-look qt5ct qt6ct qt6-qtdeclarative qt6-qttools
  file-roller pwvucontrol wtype fastfetch polkit-gnome bluez
  bluez-utils blueman imv hyprpolkitagent superfile
"

HYPERSHUTDOWN_REPO="https://github.com/hyprwm/hyprshutdown.git"

settings() {
  mkdir -p "${HOME}/.cache/waybar"
  echo "open" > "${HOME}/.cache/waybar/sidebar-state"
}

ensure_copr() {
  if ! command -v dnf >/dev/null 2>&1; then
    die "dnf not found. Are you sure this is Fedora?"
  fi

  log "Enabling COPR: solopasha/hyprland..." "\n"
  sudo dnf copr enable -y solopasha/hyprland || die "Failed to enable COPR solopasha/hyprland."
  ok "COPR solopasha/hyprland enabled."
}

default_apps() {
  if command -v xdg-settings >/dev/null 2>&1; then
    if xdg-settings set default-web-browser firefox.desktop; then
      ok "Default browser applied to: Firefox."
    else
      warn "Could not set Firefox as default browser."
    fi
  else
    warn "xdg-settings not found — default browser not changed."
  fi
}

set_gsettings() {
  if command -v gsettings >/dev/null 2>&1; then

    if
      gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" &&
      gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" &&
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' &&
      gsettings set org.gnome.desktop.interface cursor-theme "$GTK_CURSOR"
    then
      ok "GTK theme applied."
    else
      warn "Could not apply GTK theme."
    fi

    if
      gsettings set org.gnome.desktop.wm.preferences button-layout "$BUTTON_LAYOUT"
    then
      ok "Disabled buttons 'minimize,maximize,close' in window"
    fi
  fi
}

cleaner() {
  rm -rf "$HOME"/.local/share/gvfs-metadata/
}

install_base_deps() {
  log "Installing base dependencies..." "\n"
  sudo dnf install -y $BASE_DEPS || die "Failed to install base dependencies."
  ok "Base dependencies installed."
}

install_packages() {
  log "Installing necessary packages..." "\n"

  sudo dnf install -y $PACKAGES || die "Failed to install required packages."
  ok "All packages installed."
}

install_hyprshutdown() {
  if command -v hyprshutdown >/dev/null 2>&1; then
    ok "hyprshutdown already installed."
    return
  fi

  log "Installing hyprshutdown from git..." "\n"

  tmp="$(mktemp -d)" && trap 'rm -rf "$tmp"' EXIT INT TERM

  git clone "$HYPERSHUTDOWN_REPO" "$tmp/hyprshutdown" || die "Failed to clone hyprshutdown."

  (
    cd "$tmp/hyprshutdown" || die
    cmake --no-warn-unused-cli -B build || die "Failed to configure hyprshutdown."
    cmake --build build || die "Failed to build hyprshutdown."
    sudo cmake --install build || die "Failed to install hyprshutdown."
  )

  ok "hyprshutdown installed."
}

copy_configs() {
  [ -d "$CONFIG_SRC" ] || die "Directory of configurations not found: $CONFIG_SRC."

  log "Copying configs → $CONFIG_DST" "\n"
  mkdir -p "$CONFIG_DST"

  find "$CONFIG_SRC" -type f -name "*.sh" -exec chmod +x {} \;

  skip_backup=false
  [ -f "$LOCK_FILE" ] && skip_backup=true

  for src_dir in "$CONFIG_SRC"/*/; do
    [ -d "$src_dir" ] || continue

    name="${src_dir%/}"
    name="${name##*/}"
    dst_dir="$CONFIG_DST/$name"

    if [ -e "$dst_dir" ] || [ -L "$dst_dir" ]; then
      if [ -d "$dst_dir" ] && [ ! -L "$dst_dir" ]; then
        if [ "$skip_backup" = true ]; then
          rm -rf "$dst_dir"
          warn "$name — overwritten (lock present)"
        else
          backup="${dst_dir}.bak.$(date +%Y%m%d%H%M%S)"
          mv "$dst_dir" "$backup"
          warn "$name — backup saved in $backup"
        fi
      else
        rm -rf "$dst_dir"
        warn "$name — removed conflicting non-directory (file or symlink)"
      fi
    fi

    cp -rv "$src_dir" "$CONFIG_DST/"
    ok "$name"
  done

  ENV_BOOTSTRAP_SRC="$CONFIG_SRC/blasphemous-desktop/.blasphemous-desktop-bootstrap"
  if [ -f "$ENV_BOOTSTRAP_SRC" ]; then
    rm -f "$CONFIG_DST/.blasphemous-desktop-bootstrap"
    cp -v "$ENV_BOOTSTRAP_SRC" "$CONFIG_DST/.blasphemous-desktop-bootstrap"
    ok ".blasphemous-desktop-bootstrap"
  fi

  find "$CONFIG_DST" -maxdepth 1 -name "*.bak.*" -mtime +30 | while IFS= read -r old; do
    rm -rfv "$old"
    warn "Old backup removed: $old"
  done
}

create_lock() {
  mkdir -p "$(dirname "$LOCK_FILE")"
  printf '%s\n' "Installed on: $(date)" > "$LOCK_FILE"
  printf '%s\n' "Version: $VERSION" >> "$LOCK_FILE"
  ok "Installation locked."
}

patch_configs_for_fedora() {
  log "Applying Fedora-specific config patches..." "\n"

  # Replace rofi-calc with qalculate-gtk in keybinding
  if [ -f "$CONFIG_DST/hypr/hyprland.lua" ]; then
    sed -i 's|rofi -show calc -modi calc -no-show-match -no-sort|qalculate-gtk|' \
      "$CONFIG_DST/hypr/hyprland.lua" 2>/dev/null || warn "Could not update calc keybinding"
    ok "Keybinding Super+C now opens qalculate-gtk (Fedora)."
  fi
}

symlinks() {
  log "Creating symbolic links..." "\n"
  mkdir -p "$HOME/.local/bin"

  symlink "$HOME/.config/kitty/scripts/shortcuts.sh" "$HOME/.local/bin/kitty-help"
  symlink "$HOME/.config/blasphemous-desktop/sh/theme-switch.sh" "$HOME/.local/bin/theme-switch"

  ok "Creation of symbolic links completed."
  warn "Adding \"\$HOME/.local/bin\" in PATH"
}

copy_fonts() {
  [ -d "$FONTS_SRC" ] || {
    warn "Fonts directory not found: $FONTS_SRC — jumping."
    return
  }

  log "Copying fonts → $FONTS_DST" "\n"
  mkdir -p "$FONTS_DST"

  count=0
  for font in "$FONTS_SRC"/*; do
    [ -e "$font" ] || continue
    cp -rfv "$font" "$FONTS_DST/"
    count=$((count + 1))
  done

  if [ "$count" -eq 0 ]; then
    warn "No source found in $FONTS_SRC."
  else
    ok "$count file(s)/folder(s) copied."

    if command -v fc-cache >/dev/null 2>&1; then
      log "Updating font cache..." "\n"
      fc-cache -f "$FONTS_DST"
      ok "Cache fonts updated."
    else
      warn "fc-cache not found — refresh the cache manually afterwards."
    fi
  fi
}

install() {
  ensure_copr
  cleaner
  install_base_deps
  install_packages
  install_hyprshutdown
  default_apps
  settings_cosmic
  set_gsettings
  copy_configs
  create_lock
  patch_configs_for_fedora
  symlinks
  copy_fonts
  install_term_options
  settings
}

case "$1" in
--install)
  install
  copyright
  ;;
--help)
  help
  copyright
  ;;
--help-dev)
  help_dev
  copyright
  ;;
--version)
  plain "Version: $VERSION" "\n"
  ;;
*)
  help
  copyright
  exit 1
  ;;
esac
exit 0
