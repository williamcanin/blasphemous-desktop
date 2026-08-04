#!/usr/bin/env sh

# Toggle GTK dark/light mode
current="$(gsettings get org.gnome.desktop.interface color-scheme)"

if [ "$current" = "'prefer-dark'" ]; then
  gsettings set org.gnome.desktop.interface color-scheme prefer-light
  gsettings set org.gnome.desktop.interface gtk-theme Adwaita
  MODE="light"
else
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
  MODE="dark"
fi

# Read current theme
THEME="$(cat "$HOME/.config/my-environment/.active-theme" 2>/dev/null || echo "blasphemous-echoes-of-salt")"
HYPRPAPER_FILE="$HOME/.config/hypr/hyprpaper.conf"
HYPRPAPER_DIR="$HOME/.config/hypr/wallpapers"
HYPR_THEMES="$HOME/.config/hypr/themes"

apply_wallpaper_runtime() {
  _wall="$1"

  if command -v hyprpaper >/dev/null 2>&1; then
    systemctl --user stop my-environment-wallpaper.service 2>/dev/null || true
    pkill -x swaybg 2>/dev/null || true
    systemctl --user restart hyprpaper 2>/dev/null || {
      pkill -x hyprpaper 2>/dev/null || true
      hyprpaper >/tmp/hyprpaper.log 2>&1 &
    }
    return 0
  fi

  if command -v swaybg >/dev/null 2>&1; then
    pkill -x swaybg 2>/dev/null || true
    nohup swaybg -m fill -i "$_wall" >/tmp/swaybg.log 2>&1 &
  fi
}

get_active_monitor() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl monitors 2>/dev/null |
      sed -n 's/^Monitor \([^ ]*\).*/\1/p' |
      head -n1
  fi
}

apply_wallpaper() {
  _wall="$1"
  [ -z "$_wall" ] && return 0

  _config_path=$(printf '%s\n' "$_wall" | sed "s|^$HOME|~|")
  _monitor="$(get_active_monitor)"

  if [ -n "$_monitor" ]; then
    sed -i "s|^[[:space:]]*monitor[[:space:]]*=.*$|  monitor = ${_monitor}|" \
      "$HYPRPAPER_FILE" 2>/dev/null || true
  fi

  sed -i "s|^[[:space:]]*path[[:space:]]*=.*$|  path =  ${_config_path}|" \
    "$HYPRPAPER_FILE" 2>/dev/null || true

  apply_wallpaper_runtime "$_wall"
}

find_theme_wallpaper() {
  _theme="$1"

  for _ext in jpeg jpg png webp; do
    _wall="${HYPR_THEMES}/${_theme}/wallpaper.${_ext}"
    [ -f "$_wall" ] && { printf '%s\n' "$_wall"; return 0; }

    _wall="${HYPRPAPER_DIR}/${_theme}.${_ext}"
    [ -f "$_wall" ] && { printf '%s\n' "$_wall"; return 0; }
  done

  find "$HYPRPAPER_DIR" -maxdepth 1 -type f -iname "${_theme}.*" | head -n1
}

# ==============================================================================
# WAYBAR — mode.css
# ==============================================================================
MODE_CSS="$HOME/.config/waybar/mode.css"
mkdir -p "$(dirname "$MODE_CSS")"

printf '/* mode.css — Dark mode (no overrides) */\n' > "$MODE_CSS"

# Restart waybar
sh "$HOME/.config/hypr/scripts/init.sh" --waybars

# ==============================================================================
# WALLPAPER
# ==============================================================================
# Restore theme wallpaper
apply_wallpaper "$(find_theme_wallpaper "$THEME")"

# ==============================================================================
# ROFI — mode.rasi
# ==============================================================================
MODE_RASI="$HOME/.config/rofi/mode.rasi"
mkdir -p "$(dirname "$MODE_RASI")"

printf '/* mode.rasi — Dark mode (no overrides) */\n' > "$MODE_RASI"

# ==============================================================================
# QUICKSHELL — .gtk-mode flag
# ==============================================================================
GTK_MODE_FILE="$HOME/.config/my-environment/.gtk-mode"
mkdir -p "$(dirname "$GTK_MODE_FILE")"
printf '%s\n' "$MODE" > "$GTK_MODE_FILE"
