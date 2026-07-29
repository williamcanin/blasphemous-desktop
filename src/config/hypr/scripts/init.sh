#!/usr/bin/env sh

# shellcheck disable=SC1091
. "$HOME/.config/.my-environment-bootstrap"

# Run xdg-user
xdg-user-dirs-update

# set_wallpaper() {
#   hyprctl hyprpaper wallpaper ",$WALLPAPER_PATH" &
# }

set_gsettings() {
  # GTK Theme
  if command -v gsettings >/dev/null 2>&1; then
    if
      gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" &&
      gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" &&
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' &&
      gsettings set org.gnome.desktop.interface cursor-theme "$GTK_CURSOR"
    then
      printf "GTK theme applied."
    else
      printf "Could not apply GTK theme."
    fi
  else
    printf "gsettings not found — GTK theme not changed."
  fi

  # Disabled buttons: minimize,maximize,close.
  if
    gsettings set org.gnome.desktop.wm.preferences button-layout "$BUTTON_LAYOUT"
  then
    printf "Disabled buttons 'minimize,maximize,close' in window"
  fi
}

run_waybars() {
  pkill -x waybar &
  sleep 0.5

  # INFO System (respects sysinfo-state toggle)
  if [ "$(cat "$HOME/.cache/waybar/sysinfo-state" 2>/dev/null)" != "disabled" ]; then
    waybar -c "$(paths_config "waybar/sysinfo.jsonc")" -s "$(paths_config "waybar/sysinfo.css")" &
    echo enabled > "$HOME/.cache/waybar/sysinfo-state" 2>/dev/null
  fi
  sleep 1

  # Status Bar Top
  waybar &
}

case "$1" in
  --started)
    set_gsettings
    pkill hyprpaper; hyprpaper &
    pkill hypridle; hypridle &
    run_waybars
    pkill qs; qs -c sidebar-right &
    # set_wallpaper
    pkill snappy-switcher; snappy-switcher --daemon &
    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &
    systemctl --user restart --now dunst

    ## PolicyKit agent (graphical auth) GNOME
    # /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
    # /usr/lib/hyprpolkitagent &

    # Bluetooth
    systemctl enable --now bluetooth >/dev/null 2>&1 &
    blueman-applet &
  ;;
  --waybars)
    run_waybars
  ;;
  --set-wallpaper)
    # set_wallpaper
  ;;
  --reload)
    pkill qs; qs -c sidebar-right &

    rm -f "$HYPRLOCK_PATH"
    pkill hyprpaper 2>/dev/null || true
    sleep 0.2
    hyprpaper &

    pkill hypridle 2>/dev/null || true
    sleep 0.2
    hypridle &

    systemctl --user restart xdg-desktop-portal-gtk

    set_wallpaper

    run_waybars

    systemctl --user restart --now dunst

    pkill snappy-switcher 2>/dev/null || true
    sleep 0.2
    snappy-switcher --daemon &

    # PolicyKit agent (graphical auth) GNOME
    # /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

    # Bluetooth
    #systemctl enable --now bluetooth >/dev/null 2>&1 &
    #blueman-applet &

    hyprctl reload

  ;;
  *)
    notify-send "Error" "[hyprland:scripts:init]: Invalid parameter"
  ;;
esac
