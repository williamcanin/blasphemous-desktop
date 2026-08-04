#!/usr/bin/env sh
# theme-switch - apply a named theme across the whole blasphemous-desktop desktop
# Usage: theme-switch <theme-name>
# shellcheck disable=SC1091

. "${HOME}/.config/.blasphemous-desktop-bootstrap"

THEME="${1:-}"
ACTIVE_FILE="${HOME}/.config/blasphemous-desktop/.active-theme"

if [ -z "$THEME" ]; then
  THEME=$(
    rofi -dmenu -p "   Select Theme" -i -theme-str 'listview {lines: 12;}' <<'EOF'
01 - Blasphemous - Penitent
02 - Blasphemous - Echoes Of Salt
03 - Blasphemous - Fragment Of Guilt
04 - Blasphemous - Kneeling Stone
05 - Blasphemous - Requiem Aeternam
06 - Blasphemous - Ten Piedad
07 - Blasphemous II - Mea Culpa
08 - Blasphemous II - Repose Of The Silent One
09 - Blasphemous II - Red Forest
10 - Blasphemous II - The Third Sin
11 - Blasphemous II - Main Menu
EOF
  )

  [ -z "$THEME" ] && exit 0

  case "$THEME" in
    "01 - Blasphemous - Penitent")                THEME="blasphemous-penitent" ;;
    "02 - Blasphemous - Echoes Of Salt")          THEME="blasphemous-echoes-of-salt" ;;
    "03 - Blasphemous - Fragment Of Guilt")       THEME="blasphemous-fragment-of-guilt" ;;
    "04 - Blasphemous - Kneeling Stone")          THEME="blasphemous-kneeling-stone" ;;
    "05 - Blasphemous - Requiem Aeternam")        THEME="blasphemous-requiem-aeternam" ;;
    "06 - Blasphemous - Ten Piedad")              THEME="blasphemous-ten-piedad" ;;
    "07 - Blasphemous II - Mea Culpa")            THEME="blasphemous-mea-culpa" ;;
    "08 - Blasphemous II - Repose Of The Silent One") THEME="blasphemous-II-repose-of-the-silent-one" ;;
    "09 - Blasphemous II - Red Forest")           THEME="blasphemous-II-red-forest" ;;
    "10 - Blasphemous II - The Third Sin")        THEME="blashphemous-II-the-third-sin" ;;
    "11 - Blasphemous II - Main Menu")             THEME="blasphemous-II-main-menu" ;;
    *) printf 'Invalid theme selection\n' >&2; exit 1 ;;
  esac
fi

HYPR_THEMES="${HOME}/.config/hypr/themes"
WAYBAR_THEMES="${HOME}/.config/waybar/themes"
QS_THEMES="${HOME}/.config/quickshell/sidebar-right/themes"
ROFI_THEMES="${HOME}/.config/rofi/themes"
DUNST_THEMES="${HOME}/.config/dunst/themes"
WLOGOUT_THEMES="${HOME}/.config/wlogout/themes"
KITTY_THEMES="${HOME}/.config/kitty/themes"
BTOP_THEMES="${HOME}/.config/btop/themes"
BOTTOM_THEMES="${HOME}/.config/bottom/themes"
YAZI_THEMES="${HOME}/.config/yazi/themes"
SNAPPY_THEMES="${HOME}/.config/snappy-switcher/themes"
SUPERFILE_THEMES="${HOME}/.config/superfile/theme"
QT6CT_COLORS="${HOME}/.config/qt6ct/colors"

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

find_theme_wallpaper() {
  _theme="$1"

  for _ext in jpeg jpg png webp; do
    _wall="${HYPR_THEMES}/${_theme}/wallpaper.${_ext}"
    [ -f "$_wall" ] && { printf '%s\n' "$_wall"; return 0; }

    _wall="${HYPRPAPER_DIR}/${_theme}.${_ext}"
    [ -f "$_wall" ] && { printf '%s\n' "$_wall"; return 0; }
  done

  # Backward compatibility for older assets with display-case names.
  find "$HYPRPAPER_DIR" -maxdepth 1 -type f -iname "${_theme}.*" | head -n1
}

apply_wallpaper() {
  _wall="$1"
  [ -z "$_wall" ] && return 0

  _config_path=$(printf '%s\n' "$_wall" | sed "s|^$HOME|~|")
  _monitor="$(get_active_monitor)"

  if [ -n "$_monitor" ]; then
    sed -i "s|^[[:space:]]*monitor[[:space:]]*=.*$|  monitor = ${_monitor}|" "$HYPRPAPER_FILE"
  fi

  sed -i "s|^[[:space:]]*path[[:space:]]*=.*$|  path =  ${_config_path}|" "$HYPRPAPER_FILE"

  apply_wallpaper_runtime "$_wall"
}

if [ -z "$THEME" ]; then
  printf 'Usage: theme-switch <theme-name>\n' >&2
  exit 1
fi

for _dir in \
  "$HYPR_THEMES/$THEME" \
  "$WAYBAR_THEMES/$THEME" \
  "$QS_THEMES/$THEME" \
  "$ROFI_THEMES/$THEME" \
  "$DUNST_THEMES/$THEME" \
  "$WLOGOUT_THEMES/$THEME" \
  "$KITTY_THEMES/$THEME" \
  "$BTOP_THEMES/$THEME" \
  "$SNAPPY_THEMES/$THEME"; do
  if [ ! -d "$_dir" ]; then
    printf 'Error: theme directory not found: %s\n' "$_dir" >&2
    exit 1
  fi
 done

if [ ! -f "$SUPERFILE_THEMES/$THEME.toml" ]; then
  printf 'Warning: superfile theme not found: %s\n' "$SUPERFILE_THEMES/$THEME.toml" >&2
fi

if [ ! -f "$QT6CT_COLORS/$THEME.conf" ]; then
  printf 'Warning: qt6ct color scheme not found: %s\n' "$QT6CT_COLORS/$THEME.conf" >&2
fi

printf '%s' "$THEME" > "$ACTIVE_FILE"

# ----- Per-theme waybar layout -----
_waybar_cfg="$(paths_config waybar/config.jsonc)"
_waybar_cfg_sysinfo="$(paths_config waybar/sysinfo.jsonc)"
_sysinfo_css="$(paths_config waybar/sysinfo.css)"

case "$THEME" in
  *)
    sed -i "s|\"margin-top\": [0-9]*|\"margin-top\": 5|" "$_waybar_cfg"
    sed -i "s|\"margin-left\": [0-9]*|\"margin-left\": 20|" "$_waybar_cfg"
    sed -i "s|\"margin-right\": [0-9]*|\"margin-right\": 20|" "$_waybar_cfg"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": -8|" "$_waybar_cfg"
    sed -i "s|\"margin-top\": -\?[0-9]*|\"margin-top\": 15|" "$_waybar_cfg_sysinfo"
    sed -i "s|\"margin-left\": -\?[0-9]*|\"margin-left\": 20|" "$_waybar_cfg_sysinfo"
    sed -i "s|\"margin-bottom\": -\?[0-9]*|\"margin-bottom\": 15|" "$_waybar_cfg_sysinfo"
    sed -i '/^window#waybar {/,/^}/s/border-radius: [0-9]*px;/border-radius: 4px;/' "$(paths_config waybar/style.css)"
    sed -i '/^#workspaces button$/,/^}/s/border-radius: [0-9]*px;/border-radius: 5px;/' "$(paths_config waybar/style.css)"
    sed -i '/^#workspaces button\.active,/,/^}/s/border-radius: [0-9]*px;/border-radius: 4px;/' "$(paths_config waybar/style.css)"
    sed -i '/^tooltip {/,/^}/s/border-radius: [0-9]*px;/border-radius: 8px;/' "$(paths_config waybar/style.css)"
    sed -i '/#right-0, #right-1, #right-2, #mpris {/,/^}/s/border-radius: [0-9]*px;/border-radius: 5px;/' "$(paths_config waybar/style.css)"
    sed -i '/^window#waybar {/,/^}/s/border-radius: [0-9]*px;/border-radius: 8px;/' "$_sysinfo_css"
    _rofi_cfg="$(paths_config rofi/themes/blasphemous-echoes-of-salt-colored.rasi)"
    sed -i '/^window {/,/^}/s/border-radius: [0-9]*px;/border-radius: 6px;/' "$_rofi_cfg"
    sed -i '/^element selected.normal {/,/^}/s/border-radius: [0-9]*px;/border-radius: 5px;/' "$_rofi_cfg"
    ;;
esac

sed -i "s|@import url(\"./themes/.*/theme.css\");|@import url(\"./themes/${THEME}/theme.css\");|" \
  "$(paths_config waybar/style.css)"

sed -i "s|@import url(\"./themes/.*/sysinfo-theme.css\");|@import url(\"./themes/${THEME}/sysinfo-theme.css\");|" \
  "$(paths_config waybar/sysinfo.css)"

sed -i "s|@import url(\"./themes/.*/theme.css\");|@import url(\"./themes/${THEME}/theme.css\");|" \
  "$(paths_config wlogout/style.css)"

sed -i "s|@import \"~/.config/rofi/themes/.*/theme.rasi\"|@import \"~/.config/rofi/themes/${THEME}/theme.rasi\"|" \
  "$(paths_config rofi/themes/blasphemous-echoes-of-salt-colored.rasi)"

sed -i "s|include ~/.config/kitty/themes/.*/theme.conf|include ~/.config/kitty/themes/${THEME}/theme.conf|" \
  "$(paths_config kitty/kitty.conf)"

if [ -f "$DUNST_THEMES/$THEME/dunstrc.theme" ]; then
  _highlight=$(grep '^highlight' "$DUNST_THEMES/$THEME/dunstrc.theme" | cut -d= -f2 | tr -d ' "')
  _frame=$(grep '^frame_color' "$DUNST_THEMES/$THEME/dunstrc.theme" | cut -d= -f2 | tr -d ' "')
  _dunstrc="$(paths_config dunst/dunstrc)"
  sed -i "s|highlight = .*|highlight = \"${_highlight}\"|" "$_dunstrc"
  sed -i "s|frame_color = .*|frame_color = \"${_frame}\"|" "$_dunstrc"
fi

if [ -f "$HYPR_THEMES/$THEME/hyprlock.conf" ]; then
  cp "$HYPR_THEMES/$THEME/hyprlock.conf" "$(paths_config hypr/hyprlock.conf)"
fi

if [ -f "$HYPR_THEMES/$THEME/hyprtoolkit.conf" ]; then
  cp "$HYPR_THEMES/$THEME/hyprtoolkit.conf" "$(paths_config hypr/hyprtoolkit.conf)"
fi

if [ -f "$HYPR_THEMES/$THEME/application-style.conf" ]; then
  cp "$HYPR_THEMES/$THEME/application-style.conf" "$(paths_config hypr/application-style.conf)"
fi

_qt6ct_conf="$(paths_config qt6ct/qt6ct.conf)"
if [ -f "$_qt6ct_conf" ] && [ -f "$QT6CT_COLORS/$THEME.conf" ]; then
  sed -i "s|^color_scheme_path=.*|color_scheme_path=${QT6CT_COLORS}/${THEME}.conf|" "$_qt6ct_conf"
  sed -i "s|^custom_palette=.*|custom_palette=true|" "$_qt6ct_conf"
fi

if [ -f "$HYPR_THEMES/$THEME/hyprtoolkit.conf" ] || [ -f "$HYPR_THEMES/$THEME/application-style.conf" ]; then
  systemctl --user set-environment QT_QPA_PLATFORM=wayland QT_QPA_PLATFORMTHEME=qt6ct QT_QUICK_CONTROLS_STYLE=org.hyprland.style
  systemctl --user restart hyprpolkitagent 2>/dev/null || true
fi

if [ -f "$BTOP_THEMES/$THEME/theme.theme" ]; then
  _btop_conf="$(paths_config btop/btop.conf)"
  sed -i "s|color_theme = .*|color_theme = \"${BTOP_THEMES}/${THEME}/theme.theme\"|" "$_btop_conf"
fi

if [ -f "$SNAPPY_THEMES/$THEME/theme.ini" ]; then
  _snappy_conf="$(paths_config snappy-switcher/config.ini)"
  sed -i "s|^name = .*|name = ${THEME}/theme.ini|" "$_snappy_conf"
fi

if [ -f "$BOTTOM_THEMES/$THEME/bottom.toml" ]; then
  cp "$BOTTOM_THEMES/$THEME/bottom.toml" "$(paths_config bottom/bottom.toml)"
fi

if [ -f "$YAZI_THEMES/$THEME/theme.toml" ]; then
  cp "$YAZI_THEMES/$THEME/theme.toml" "$(paths_config yazi/theme.toml)"
fi

_superfile_conf="$(paths_config superfile/config.toml)"
if [ -f "$_superfile_conf" ] && [ -f "$SUPERFILE_THEMES/$THEME.toml" ]; then
  sed -i "s|^theme = .*|theme = \"${THEME}\"|" "$_superfile_conf"
fi

# Remove old lock screen image
rm -f "$HYPRLOCK_PATH"

# Reset GTK mode to dark (mode.css + .gtk-mode) when switching themes
MODE_CSS="$(paths_config waybar/mode.css)"
printf '/* mode.css — reset on theme switch */\n' > "$MODE_CSS"
GTK_MODE_FILE="${HOME}/.config/blasphemous-desktop/.gtk-mode"
mkdir -p "$(dirname "$GTK_MODE_FILE")"
printf 'dark\n' > "$GTK_MODE_FILE"

# Reload Hyprland config
hyprctl reload

# Restart waybar with new theme CSS (mode.css is now clean/dark)
sh "$(paths_config hypr/scripts/init.sh)" --waybars

# Set wallpaper for the new theme
HYPRPAPER_FILE="$(paths_config hypr/hyprpaper.conf)"
HYPRPAPER_DIR="$(paths_config hypr/wallpapers)"

apply_wallpaper "$(find_theme_wallpaper "$THEME")"

# Restart dunst with new theme colors
systemctl --user restart --now dunst

# Restart snappy-switcher with new theme
pkill snappy-switcher 2>/dev/null || true
sleep 0.2
snappy-switcher --daemon &

# Sidebar NOT restarted — Theme.qml picks up the new theme dynamically
# via FileView watching .active-theme.

notify-send "Theme" "Switched to '${THEME}'" 2>/dev/null || true
printf "Theme '%s' applied.\n" "$THEME"
