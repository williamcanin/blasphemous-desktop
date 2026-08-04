#!/usr/bin/env sh

# shellcheck disable=SC1091
. "$HOME/.config/.blasphemous-desktop-bootstrap"

STATE_FILE="$HOME/.cache/waybar/sysinfo-state"
CFG="$(paths_config waybar/sysinfo.jsonc)"
CSS="$(paths_config waybar/sysinfo.css)"

ensure_state_dir() {
    mkdir -p "$(dirname "$STATE_FILE")"
}

cmd_on() {
    ensure_state_dir
    echo enabled > "$STATE_FILE"
    nohup waybar -c "$CFG" -s "$CSS" </dev/null >/dev/null 2>&1 &
    printf "enabled\n"
}

cmd_off() {
    ensure_state_dir
    echo disabled > "$STATE_FILE"
    pkill -f '^waybar\b.*sysinfo'
    printf "disabled\n"
}

cmd_status() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    elif pgrep -f '^waybar\b.*sysinfo' >/dev/null 2>&1; then
        printf "enabled\n"
    else
        printf "disabled\n"
    fi
}

cmd_toggle() {
    if [ -f "$STATE_FILE" ] && grep -qx disabled "$STATE_FILE"; then
        cmd_on
    else
        cmd_off
    fi
}

case "$1" in
  on) cmd_on ;;
  off) cmd_off ;;
  status) cmd_status ;;
  toggle) cmd_toggle ;;
  *)
    echo "Usage: $0 {on|off|toggle|status}"
    exit 1
    ;;
esac
