#!/usr/bin/env sh

. "$HOME/.config/.my-environment-bootstrap"

WALLPAPERS_DIR="${HOME}/.config/hypr/wallpapers"
SELECTED_FILE=$(mktemp)

ensure_hyprpaper() {
  if ! pgrep -x hyprpaper >/dev/null 2>&1; then
    if ! systemctl --user start hyprpaper 2>/dev/null; then
      hyprpaper >/tmp/hyprpaper.log 2>&1 &
    fi
    sleep 0.4
  fi
}

apply_wallpaper_runtime() {
  _wall="$1"
  _monitor="$2"

  if command -v swaybg >/dev/null 2>&1; then
    systemctl --user stop hyprpaper 2>/dev/null || true
    systemctl --user stop my-environment-wallpaper.service 2>/dev/null || true
    pkill -x swaybg 2>/dev/null || true
    if ! systemd-run --user --unit=my-environment-wallpaper --collect --quiet \
      swaybg -m fill -i "$_wall" >/tmp/swaybg.log 2>&1; then
      nohup swaybg -m fill -i "$_wall" >/tmp/swaybg.log 2>&1 &
    fi
    return 0
  fi

  ensure_hyprpaper
  hyprctl hyprpaper wallpaper "${_monitor},$_wall,cover"
}

get_hyprpaper_monitor() {
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
MONITOR="$(get_hyprpaper_monitor)"

# Update hyprpaper.conf with ~ path
[ -n "$MONITOR" ] && sed -i "s|^[[:space:]]*monitor[[:space:]]*=.*$|  monitor = ${MONITOR}|" "$HYPRPAPER_FILE"
sed -i "s|^[[:space:]]*path[[:space:]]*=.*$|  path =  ${CONFIG_PATH}|" "$HYPRPAPER_FILE"

# Apply with full path
apply_wallpaper_runtime "$SELECTED_PATH" "$MONITOR"

# Remove old lock screen image
rm -f "$HYPRLOCK_PATH"

notify-send "Wallpaper" "Alterado para:\n$(basename "$SELECTED_PATH")"
