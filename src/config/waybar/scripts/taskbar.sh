#!/usr/bin/env sh

# shellcheck disable=SC1091
. "$HOME/.config/.blasphemous-desktop-bootstrap"

mkdir -p "$WAYBAR_CACHE_DIR"

case "$XDG_SESSION_DESKTOP" in
  Hyprland)
    DIR="hypr"
    CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')
    ;;
  sway)
    DIR="sway"
    CURRENT_WS=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused).name')
    ;;
  *)
    DIR=""
    CURRENT_WS=""
    ;;
esac

require_session() {
  case "$XDG_SESSION_DESKTOP" in
    Hyprland | sway) return 0 ;;
    *)
      notify-send "[waybar]:taskbar.sh" "Unsupported session: ${XDG_SESSION_DESKTOP:-unknown}"
      exit 1
      ;;
  esac
}

go_workspace() {
  require_session
  case "$XDG_SESSION_DESKTOP" in
    Hyprland) hyprctl dispatch "hl.dsp.focus({ workspace = \"$1\" })" ;;
    sway)     swaymsg workspace "$1" ;;
  esac
}

switch_keyboard_layout() {
  require_session
  case "$XDG_SESSION_DESKTOP" in
    Hyprland)
      # Hyprland: troca layout via hyprctl
      hyprctl switchxkblayout usb-usb-keyboard next
      ;;
    sway)
      swaymsg input type:keyboard xkb_switch_layout next
      ;;
  esac
}

power_menu() {
  [ -n "$DIR" ] || require_session
  # shellcheck disable=SC1091
  # shellcheck disable=SC1090
  . "$(paths_config "$DIR/scripts/power-menu.sh")"
}

term() {
  require_session
  case "$XDG_SESSION_DESKTOP" in
  Hyprland)
    "$TERM" -e btm -C "$(paths_config "bottom/$1.toml")" && hyprctl dispatch "hl.dsp.focus({ workspace = $CURRENT_WS })"
    ;;
  sway)
    "$TERM" -e btm -C "$(paths_config "bottom/$1.toml")"
    ;;
  esac
}

sidebar_toggle() {
  STATE_FILE="$WAYBAR_CACHE_DIR/sidebar-state"

  if [ "$(cat "$STATE_FILE" 2>/dev/null)" = "open" ]; then
    echo "close" > "$STATE_FILE"
  else
    echo "open" > "$STATE_FILE"
  fi

  qs -c sidebar-right ipc call sidebar toggle
}

case $1 in
  --cal)
    ## Google Calendar
    # google-chrome-stable "https://calendar.google.com/calendar/u/0/r/month"

    ## Gsimplecal
    # sudo pacman -S gsimplecal
    # gsimplecal &

    ## Calcurse
    # sudo pacman -S calcurse kitty
    "$TERM" --class calcurse-popup -e calcurse
    go_workspace "$CURRENT_WS"
    ;;
  --mem)
    go_workspace 9
    term "mem"
    go_workspace "$CURRENT_WS"
    ;;
  --cpu)
    go_workspace 9
    term "cpu"
    go_workspace "$CURRENT_WS"
    ;;
  --cpu-temp)
    "$TERM" --class cpu-temp-popup -e sh -c 'sensors; echo; read -p "Pressione Enter para fechar..."'
    go_workspace "$CURRENT_WS"
    ;;
  --gpu-temp)
    if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
      "$TERM" --class gpu-temp-popup -e watch -n 1 nvidia-smi
    else
      "$TERM" --class gpu-temp-popup -e sh -c 'sensors; echo; read -p "Pressione Enter para fechar..."'
    fi
    go_workspace "$CURRENT_WS"
    ;;
  --power-menu)
    power_menu
    ;;
  --layout-keyboard)
    switch_keyboard_layout
    ;;
  --sidebar-toggle)
    sidebar_toggle
    ;;
  *)
    notify-send "[waybar]:taskbar.sh" "Invalid parameter: ${1:-empty}"
    exit 1
    ;;
esac
