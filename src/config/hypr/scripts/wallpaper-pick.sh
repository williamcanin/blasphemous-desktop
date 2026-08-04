#!/usr/bin/env sh

. "$HOME/.config/.blasphemous-desktop-bootstrap"

WALLPAPERS_DIR="${HOME}/.config/hypr/wallpapers"
SELECTED_FILE=$(mktemp)

apply_wallpaper_runtime() {
  _wall="$1"

  if command -v hyprpaper >/dev/null 2>&1; then
    systemctl --user stop blasphemous-desktop-wallpaper.service 2>/dev/null || true
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

"$TERM" -e yazi --chooser-file="$SELECTED_FILE" "$WALLPAPERS_DIR"

SELECTED_PATH=$(cat "$SELECTED_FILE")
rm -f "$SELECTED_FILE"

[ -z "$SELECTED_PATH" ] && exit 0

# Convert $HOME to ~ for config file consistency
CONFIG_PATH=$(echo "$SELECTED_PATH" | sed "s|^$HOME|~|")
MONITOR="$(get_active_monitor)"

# Update hyprpaper.conf with ~ path
[ -n "$MONITOR" ] && sed -i "s|^[[:space:]]*monitor[[:space:]]*=.*$|  monitor = ${MONITOR}|" "$HYPRPAPER_FILE"
sed -i "s|^[[:space:]]*path[[:space:]]*=.*$|  path =  ${CONFIG_PATH}|" "$HYPRPAPER_FILE"

# Apply with full path
apply_wallpaper_runtime "$SELECTED_PATH"

# Remove old lock screen image
rm -f "$HYPRLOCK_PATH"

notify-send "Wallpaper" "Alterado para:\n$(basename "$SELECTED_PATH")"
