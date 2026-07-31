#!/usr/bin/env sh

# shellcheck disable=SC1091,SC2086

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

. "$SCRIPT_DIR/libs/base.sh"
. "$SCRIPT_DIR/libs/version.sh"
. "$SCRIPT_DIR/libs/msg.sh"
. "$SCRIPT_DIR/libs/help.sh"
. "$SCRIPT_DIR/libs/symlink.sh"
. "$SCRIPT_DIR/libs/term.sh"
. "$SCRIPT_DIR/libs/cosmic.sh"
. "$SCRIPT_DIR/libs/copyright.sh"

CONFIG_SRC="$REPO_ROOT/src/config"
CONFIG_DST="$HOME/.config"
FONTS_SRC="$REPO_ROOT/src/fonts"
FONTS_DST="$HOME/.local/share/fonts"
LOCK_FILE="$CONFIG_DST/my-environment/.install.lock"

DRY_RUN=false
REMOVE_BACKUPS=false
PURGE_PACKAGES=false

# ----- helpers -----

dry() {
  if $DRY_RUN; then
    warn "[DRY-RUN] $*"
  else
    "$@"
  fi
}

confirm() {
  printf "%b%s %s%b" \
    "$MSG_COLOR_YELLOW" \
    "$MSG_ICON_WARN" \
    "$1" \
    "$MSG_COLOR_RESET" >&2
  printf " [y/N] " >&2
  read -r answer
  case "$answer" in
    y|Y|yes|Yes) return 0 ;;
    *) return 1 ;;
  esac
}

remove_symlinks() {
  log "Removing symbolic links from ~/.local/bin..." "\n"

  for link in "kitty-help" "my-environment-theme" "theme-switch"; do
    target="$HOME/.local/bin/$link"
    if [ -L "$target" ] || [ -f "$target" ]; then
      if $DRY_RUN; then
        warn "[DRY-RUN] rm $target"
      else
        rm -f "$target"
        ok "Removed: $target"
      fi
    fi
  done
}

remove_configs() {
  log "Removing installed configurations from ~/.config..." "\n"

  if [ ! -d "$CONFIG_SRC" ]; then
    warn "Source directory not found: $CONFIG_SRC — cannot determine config list."
    return
  fi

  for src_dir in "$CONFIG_SRC"/*/; do
    [ -d "$src_dir" ] || continue

    name="${src_dir%/}"
    name="${name##*/}"
    dst_dir="$CONFIG_DST/$name"

    if [ -d "$dst_dir" ]; then
      if $DRY_RUN; then
        warn "[DRY-RUN] rm -rf $dst_dir"
      else
        rm -rf "$dst_dir"
        ok "Removed: $dst_dir"
      fi
    else
      warn "Not found: $dst_dir"
    fi
  done

  bootstrap_dst="$CONFIG_DST/.environment-bootstrap"
  if [ -f "$bootstrap_dst" ]; then
    if $DRY_RUN; then
      warn "[DRY-RUN] rm $bootstrap_dst"
    else
      rm -f "$bootstrap_dst"
      ok "Removed: $bootstrap_dst"
    fi
  fi

  warn "Backups (files ending with .bak.*) were preserved in $CONFIG_DST/"
  if $REMOVE_BACKUPS; then
    if confirm "Remove all backup directories?"; then
      if $DRY_RUN; then
        warn "[DRY-RUN] find $CONFIG_DST -maxdepth 1 -name '*.bak.*' -exec rm -rf {} +"
      else
        find "$CONFIG_DST" -maxdepth 1 -name "*.bak.*" -exec rm -rf {} +
        ok "Backups removed."
      fi
    fi
  fi
}

remove_fonts() {
  [ -d "$FONTS_DST" ] || {
    warn "Fonts directory not found: $FONTS_DST"
    return
  }
  [ -d "$FONTS_SRC" ] || {
    warn "Source fonts not found: $FONTS_SRC — cannot determine which fonts to remove."
    return
  }

  log "Removing fonts installed by this project..." "\n"
  removed=0

  for font in "$FONTS_SRC"/*; do
    [ -e "$font" ] || continue
    name="$(basename "$font")"
    dst="$FONTS_DST/$name"

    if [ -e "$dst" ]; then
      removed=$((removed + 1))
      if $DRY_RUN; then
        warn "[DRY-RUN] rm -rf $dst"
      else
        rm -rf "$dst"
      fi
    fi
  done

  if [ "$removed" -gt 0 ]; then
    if command -v fc-cache >/dev/null 2>&1; then
      log "Updating font cache..." "\n"
      $DRY_RUN || fc-cache -f "$FONTS_DST"
    fi
    ok "$removed font(s) removed."
  else
    warn "No installed fonts found."
  fi
}

remove_term_options() {
  log "Removing term options from shell rc files..." "\n"

  source_line='. "$HOME/.config/term/options.sh"'
  comment_line='# Colors by Hyprland'

  for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    [ -f "$rc" ] || continue

    if grep -Fxq "$source_line" "$rc" 2>/dev/null; then
      if $DRY_RUN; then
        warn "[DRY-RUN] Remove term options from $rc"
      else
        tmpfile="$(mktemp)"
        grep -vFx "$source_line" "$rc" | grep -vFx "$comment_line" > "$tmpfile" || true
        mv "$tmpfile" "$rc"
        ok "Cleaned: $rc"
      fi
    fi
  done
}

remove_cosmic_settings() {
  cosmic_dir="$HOME/.config/cosmic"

  if [ -d "$cosmic_dir" ]; then
    if confirm "Remove Cosmic settings directory ($cosmic_dir)?"; then
      if $DRY_RUN; then
        warn "[DRY-RUN] rm -rf $cosmic_dir"
      else
        rm -rf "$cosmic_dir"
        ok "Removed Cosmic settings."
      fi
    fi
  else
    warn "Cosmic settings not found."
  fi
}

remove_lock() {
  if [ -f "$LOCK_FILE" ]; then
    if $DRY_RUN; then
      warn "[DRY-RUN] rm $LOCK_FILE"
    else
      rm -f "$LOCK_FILE"
      ok "Removed install lock: $LOCK_FILE"
    fi
  fi
}

remove_waybar_cache() {
  cache_file="${HOME}/.cache/waybar/sidebar-state"

  if [ -f "$cache_file" ]; then
    if $DRY_RUN; then
      warn "[DRY-RUN] rm $cache_file"
    else
      rm -f "$cache_file"
      ok "Removed: $cache_file"
    fi
  fi
}

revert_fedora_patches() {
  hyprland_lua="$CONFIG_DST/hypr/hyprland.lua"
  [ -f "$hyprland_lua" ] || return

  if grep -q "qalculate-gtk" "$hyprland_lua" 2>/dev/null; then
    if $DRY_RUN; then
      warn "[DRY-RUN] sed -i 's|qalculate-gtk|rofi -show calc -modi calc -no-show-match -no-sort|' $hyprland_lua"
    else
      sed -i 's|qalculate-gtk|rofi -show calc -modi calc -no-show-match -no-sort|' "$hyprland_lua"
      ok "Reverted Fedora calc patch in $hyprland_lua"
    fi
  fi
}

revert_gsettings() {
  command -v gsettings >/dev/null 2>&1 || {
    warn "gsettings not found — skipping."
    return
  }

  log "Resetting GTK settings to default..." "\n"

  if confirm "Reset GTK theme/icon/cursor settings to default?"; then
    $DRY_RUN || gsettings set org.gnome.desktop.interface icon-theme "Adwaita" 2>/dev/null || true
    $DRY_RUN || gsettings set org.gnome.desktop.interface gtk-theme "Adwaita" 2>/dev/null || true
    $DRY_RUN || gsettings set org.gnome.desktop.interface color-scheme "default" 2>/dev/null || true
    $DRY_RUN || gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" 2>/dev/null || true
    $DRY_RUN || gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close" 2>/dev/null || true
    ok "GTK settings reset."
  fi
}

revert_default_apps() {
  command -v xdg-settings >/dev/null 2>&1 || {
    warn "xdg-settings not found — skipping."
    return
  }

  if confirm "Reset default browser?"; then
    $DRY_RUN || xdg-settings set default-web-browser "" 2>/dev/null || true
    ok "Default browser reset."
  fi
}

list_installed_configs() {
  echo ""
  accent "Configurations installed in ~/.config/:"
  echo ""
  if [ -d "$CONFIG_SRC" ]; then
    for src_dir in "$CONFIG_SRC"/*/; do
      [ -d "$src_dir" ] || continue
      name="${src_dir%/}"
      name="${name##*/}"
      dst_dir="$CONFIG_DST/$name"
      if [ -d "$dst_dir" ]; then
        printf "  %b•%b %s\n" "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET" "$dst_dir"
      fi
    done
  fi
  if [ -f "$CONFIG_DST/.environment-bootstrap" ]; then
    printf "  %b•%b %s\n" "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET" "$CONFIG_DST/.environment-bootstrap"
  fi

  echo ""
  accent "Symlinks:"
  for link in "kitty-help" "my-environment-theme" "theme-switch"; do
    target="$HOME/.local/bin/$link"
    [ -L "$target" ] && printf "  %b•%b %s → %s\n" "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET" "$target" "$(readlink "$target")"
    [ -f "$target" ] && printf "  %b•%b %s (file)\n" "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET" "$target"
  done

  echo ""
  accent "Terminal integration:"
  for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    [ -f "$rc" ] && grep -q '. "$HOME/.config/term/options.sh"' "$rc" 2>/dev/null && printf "  %b•%b Term options found in %s\n" "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET" "$rc"
  done

  echo ""
  accent "Fonts:"
  if [ -d "$FONTS_DST" ] && [ -d "$FONTS_SRC" ]; then
    for font in "$FONTS_SRC"/*; do
      [ -e "$font" ] || continue
      name="$(basename "$font")"
      [ -e "$FONTS_DST/$name" ] && printf "  %b•%b %s\n" "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET" "$FONTS_DST/$name"
    done
  fi

  echo ""
  if [ -f "$LOCK_FILE" ]; then
    accent "Install lock exists ($LOCK_FILE)"
    echo ""
  fi
  if [ -f "${HOME}/.cache/waybar/sidebar-state" ]; then
    accent "Waybar sidebar state exists"
    echo ""
  fi
  if [ -d "$HOME/.config/cosmic" ]; then
    accent "Cosmic settings exist"
    echo ""
  fi
}

uninstall() {
  echo ""
  log "my-environment — Uninstall" "\n"
  echo "========================================"
  warn "This will remove configurations installed by this project."
  warn "Backups made during installation will be preserved in ~/.config/*.bak.*"
  echo ""

  if ! confirm "Proceed with uninstall?"; then
    ok "Uninstall cancelled."
    exit 0
  fi

  echo ""
  list_installed_configs

  echo ""
  if ! confirm "Continue with full uninstall?"; then
    ok "Uninstall cancelled."
    exit 0
  fi

  echo ""

  remove_lock
  echo ""
  remove_symlinks
  echo ""
  revert_default_apps
  echo ""
  revert_gsettings
  echo ""
  remove_cosmic_settings
  echo ""
  remove_waybar_cache
  echo ""
  remove_term_options
  echo ""
  remove_fonts
  echo ""

  if [ -f /etc/os-release ] && grep -qi "fedora" /etc/os-release 2>/dev/null; then
    revert_fedora_patches
    echo ""
  fi

  remove_configs
  echo ""

  if $PURGE_PACKAGES; then
    warn "Package removal not implemented — uninstall packages manually to avoid breaking your system."
    echo "  Arch:   yay -Rns firefox hyprland hyprpaper ..."
    echo "  Fedora: sudo dnf remove firefox hyprland hyprpaper ..."
  else
    warn "Packages were NOT removed. To see installed packages, check the installer script."
  fi

  echo ""
  ok "Uninstall complete!"

  if confirm "Logout now to apply changes?"; then
    if $DRY_RUN; then
      warn "[DRY-RUN] Would log out"
    else
      ok "Logging out..."
      case "${DESKTOP_SESSION:-${XDG_SESSION_DESKTOP:-}}" in
        *hyprland*|*Hyprland*)
          if command -v hyprctl >/dev/null 2>&1; then
            hyprctl dispatch exit
          else
            loginctl terminate-session self
          fi
          ;;
        sway)
          if command -v swaymsg >/dev/null 2>&1; then
            swaymsg exit
          else
            loginctl terminate-session self
          fi
          ;;
        *)
          loginctl terminate-session self
          ;;
      esac
    fi
  fi
}

usage() {
  cat <<EOF
Usage: make uninstall [OPTIONS]
   or: sh .tools/installer/uninstall.sh [OPTIONS]

Options:
  --dry-run          Show what would be removed without actually removing
  --remove-backups   Also remove .bak.* backup directories
  --purge-packages   Enable package removal hints (does NOT actually remove packages)
  --help             Show this message
EOF
}

# ----- CLI -----
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --remove-backups) REMOVE_BACKUPS=true ;;
    --purge-packages) PURGE_PACKAGES=true ;;
    --help) usage; exit 0 ;;
    *) warn "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

uninstall
copyright
