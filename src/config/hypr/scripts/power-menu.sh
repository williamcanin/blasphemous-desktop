#!/usr/bin/env sh

# shellcheck disable=SC1091
. "$HOME/.config/.blasphemous-desktop-bootstrap"

do_lock() {
  if [ "$WALLPAPER_PATH" -nt "$HYPRLOCK_PATH" ]; then
    magick "$WALLPAPER_PATH" \
      -blur 0x2 \
      -fill black -colorize 20% \
      "$HYPRLOCK_PATH"
  fi
  exec hyprlock
}


# -- power-menu.sh --lock
# Also used for the keyboard shortcut Mod+Shift+l
# ------------------------------------------------------------------------------
[ "$1" = "--lock" ] && {
  do_lock
  exit $?
}

# -- Translate -----------------------------------------------------------------
if locale_is_pt; then
  LOCK="Bloquear"
  SUSPEND="Suspender"
  LOGOUT="Sair"
  REBOOT="Reiniciar"
  SHUTDOWN="Desligar"
else
  LOCK="Lock"
  SUSPEND="Suspend"
  LOGOUT="Log Out"
  REBOOT="Reboot"
  SHUTDOWN="Shut Down"
fi

# -- Menu -----------------------------------------------------------------
if [ "$FINDER" = "/usr/bin/rofi" ]; then
  CHOICE=$(printf '%s\n' \
    "$LOCK" \
    "$SUSPEND" \
    "$LOGOUT" \
    "$REBOOT" \
    "$SHUTDOWN" |
    $FINDER -dmenu -p ">" \
    -theme-str 'window {width: 220px;} listview {lines: 5;}' -no-custom -i)
elif [ "$FINDER" = "/usr/bin/wofi" ]; then
  CHOICE=$(printf '%s\n' \
    "$LOCK" \
    "$SUSPEND" \
    "$LOGOUT" \
    "$REBOOT" \
    "$SHUTDOWN" |
    $FINDER)
fi

# ── Despatch ------------------------------------------------------------------
case "$CHOICE" in
"$LOCK")     do_lock ;;
"$SUSPEND")  systemctl suspend ;;
"$LOGOUT")   hyprshutdown ;; # hyprctl dispatch exit
"$REBOOT")   hyprshutdown -t 'Reiniciando...' --post-cmd 'reboot' ;; # systemctl reboot
"$SHUTDOWN") hyprshutdown -t 'Desligando...' --post-cmd 'shutdown -P 0' ;; # systemctl poweroff
esac
