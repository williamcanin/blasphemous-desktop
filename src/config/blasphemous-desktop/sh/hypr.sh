# shellcheck shell=sh disable=SC2034

# -- Hyprland-specific paths and helpers --------------------------------------

HYPRPAPER_FILE="${HOME}/.config/hypr/hyprpaper.conf"
HYPRLOCK_FILE="${HOME}/.config/hypr/hyprlock.conf"

GET_HYPRPAPER_PATH=$(
  sed -n "s|^[[:space:]]*path[[:space:]]*=[[:space:]]*~|$HOME|p" \
  "$HYPRPAPER_FILE" |
  head -n1
)

GET_HYPRLOCK_PATH=$(
  sed -n "s|^[[:space:]]*path[[:space:]]*=[[:space:]]*~|$HOME|p" \
  "$HYPRLOCK_FILE" |
  head -n1
)

WALLPAPER_PATH="$GET_HYPRPAPER_PATH"
HYPRLOCK_PATH="$GET_HYPRLOCK_PATH"
