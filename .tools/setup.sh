#!/usr/bin/env sh
# shellcheck disable=SC1091,SC2086,SC2034,SC2016,SC2317,SC2329
#
# setup.sh — Single-file installer/uninstaller for blasphemous-desktop
#
# Local usage (from the repository):
#   sh .tools/setup.sh --install
#   sh .tools/setup.sh --upgrade
#   sh .tools/setup.sh --uninstall [--dry-run] [--remove-backups] [--purge-packages]
#   sh .tools/setup.sh --help
#   sh .tools/setup.sh --help-dev
#   sh .tools/setup.sh --version
#
# Online usage (via GitHub Releases):
#   sh -c "$(curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh)"
#   sh -c "$(curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh)" -- 0.2.0
#   sh -c "$(curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh)" -- --releases
#
# Pipe form (non-interactive only):
#   curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh | sh
#   curl -fsSL https://williamcanin.github.io/blasphemous-desktop/setup.sh | sh -s -- 0.2.0
#
# Makefile-compatible targets:
#   make install    -> sh .tools/setup.sh --install
#   make upgrade    -> sh .tools/setup.sh --upgrade
#   make uninstall  -> sh .tools/setup.sh --uninstall [ARGS]
#   make version    -> sh .tools/setup.sh --version
#   make help       -> sh .tools/setup.sh --help

set -e

# --- VERSION ------------------------------------------------------------------
VERSION="0.2.4 (Blasphemous)"

# --- Variables ----------------------------------------------------------------
USED_SHELL="/usr/bin/zsh"
ENVIRONMENT_ROOT="${HOME}/.config/blasphemous-desktop"
HYPR_CACHE_DIR="${HOME}/.cache/hypr"
WAYBAR_CACHE_DIR="${HOME}/.cache/waybar"
BUTTON_LAYOUT=":"
GTK_THEME="Adwaita-dark"
ICON_THEME="Yaru-prussiangreen-dark"
GTK_CURSOR="Adwaita"
FINDER="/usr/bin/rofi"
TERM="/usr/bin/kitty"
BAR_SIZE="8"
ACTIVE_THEME="blasphemous-echoes-of-salt"

# Release installer config
AUTHOR_NAME="William C. Canin"
NAME_PROJECT="blasphemous-desktop"
REPO="williamcanin/blasphemous-desktop"
API="https://api.github.com/repos/${REPO}"
SITE_URL="https://williamcanin.github.io/blasphemous-desktop"

# ============================================================================
# MESSAGE FUNCTIONS
# ============================================================================
case "${LANG:-}${LC_ALL:-}" in
  *UTF-8*|*utf8*)
    MSG_ICON_ARROW="→"
    MSG_ICON_OK="✔"
    MSG_ICON_WARN="⚠"
    MSG_ICON_ERROR="✖"
    ;;
  *)
    MSG_ICON_ARROW=">"
    MSG_ICON_OK="[OK]"
    MSG_ICON_WARN="[WARN]"
    MSG_ICON_ERROR="[ERR]"
    ;;
esac

if [ -t 1 ]; then
  MSG_COLOR_CYAN="$(printf '\033[0;36m')"
  MSG_COLOR_MAGENTA="$(printf '\033[0;35m')"
  MSG_COLOR_GREEN="$(printf '\033[0;32m')"
  MSG_COLOR_YELLOW="$(printf '\033[0;33m')"
  MSG_COLOR_RED="$(printf '\033[0;31m')"
  MSG_COLOR_RESET="$(printf '\033[0m')"
else
  MSG_COLOR_CYAN=""
  MSG_COLOR_MAGENTA=""
  MSG_COLOR_GREEN=""
  MSG_COLOR_YELLOW=""
  MSG_COLOR_RED=""
  MSG_COLOR_RESET=""
fi

log() {
  printf "%b%s %s%b%b" \
    "$MSG_COLOR_CYAN" \
    "$MSG_ICON_ARROW" \
    "$1" \
    "$MSG_COLOR_RESET" \
    "${2:-}"
}

ok() {
  printf "%b%s %s%b\n" \
    "$MSG_COLOR_GREEN" \
    "$MSG_ICON_OK" \
    "$*" \
    "$MSG_COLOR_RESET"
}

warn() {
  printf "%b%s %s%b\n" \
    "$MSG_COLOR_YELLOW" \
    "$MSG_ICON_WARN" \
    "$*" \
    "$MSG_COLOR_RESET"
}

die() {
  printf "%b%s %s%b\n" \
    "$MSG_COLOR_RED" \
    "$MSG_ICON_ERROR" \
    "$*" \
    "$MSG_COLOR_RESET" >&2
  exit 1
}

accent() {
  printf "%b%s%b%b" \
    "$MSG_COLOR_MAGENTA" \
    "$1" \
    "$MSG_COLOR_RESET" \
    "${2:-}"
}

plain() {
  printf "%s%b" \
    "$1" \
    "${2:-}"
}

# Simple remote-style messages (no prefix, for release workflow)
r_info() { printf '%s%s%s\n' "$MSG_COLOR_CYAN" "$1" "$MSG_COLOR_RESET"; }
r_ok()   { printf '%s%s%s\n' "$MSG_COLOR_GREEN" "$1" "$MSG_COLOR_RESET"; }
r_warn() { printf '%s%s%s\n' "$MSG_COLOR_YELLOW" "$1" "$MSG_COLOR_RESET" >&2; }
r_die()  { printf '%s%s%s\n' "$MSG_COLOR_RED" "$1" "$MSG_COLOR_RESET" >&2; exit 1; }

# ============================================================================
# HELP
# ============================================================================
help() {
  printf "\n"
  log "Options:" "\n"
  accent "  --install";    plain " ------ Install from local repository" "\n"
  accent "  --upgrade";    plain " ------ Pull latest and reinstall" "\n"
  accent "  --uninstall";  plain " ---- Uninstall (add --dry-run to preview)" "\n"
}

# help_dev() {
#   help
#   printf "\n"
#   log "Development options:" "\n"
#   accent "  --help-dev";   plain " ---------- This message" "\n"
# }

online_usage() {
  printf "\n"
  log "Options:" "\n"
  accent "  --releases";   plain " ---- List available versions" "\n"
  accent "  VERSION";      plain " ------- Install a specific version (e.g. 0.2.0)" "\n"
  accent "  (no args)";    plain " ---- Install the latest release" "\n"
  printf "\n"
  log "Shortcuts:" "\n"
  accent "  --help";       plain " -------- This message" "\n"
}

# ============================================================================
# COPYRIGHT
# ============================================================================
copyright() {
  echo
  echo "-----------------------------------------------------------------"
  echo "© $AUTHOR_NAME <${SITE_URL}>"
  echo "-----------------------------------------------------------------"
}

# ============================================================================
# SYMLINK
# ============================================================================
symlink() {
  if [ -f "$1" ]; then
    ln -fs "$1" "$2"
    chmod +x "$2"
  fi
}

# ============================================================================
# TERM OPTIONS
# ============================================================================
add_term_options() {
  rc_file="$1"
  source_line='. "$HOME/.config/term/options.sh"'
  [ -f "$rc_file" ] || touch "$rc_file"
  if ! grep -Fxq "$source_line" "$rc_file"; then
    cat >> "$rc_file" <<'EOF'

# Colors by Hyprland
. "$HOME/.config/term/options.sh"
EOF
  fi
}

install_term_options() {
  case "$(basename "$SHELL")" in
    bash) add_term_options "$HOME/.bashrc"  ;;
    zsh)  add_term_options "$HOME/.zshrc"   ;;
    *)    add_term_options "$HOME/.profile"  ;;
  esac
}

# ============================================================================
# COSMIC SETTINGS
# ============================================================================
settings_cosmic() {
  log "Cosmic Files settings..." "\n"
  mkdir -p "$HOME/.config/cosmic/com.system76.CosmicTk/v1/"
  echo "false" > "$HOME/.config/cosmic/com.system76.CosmicTk/v1/show_maximize"
  echo "false" > "$HOME/.config/cosmic/com.system76.CosmicTk/v1/show_minimize"
  echo "\"$ICON_THEME\"" > "$HOME/.config/cosmic/com.system76.CosmicTk/v1/icon_theme"
  if command -v cosmic-settings >/dev/null 2>&1 && [ -f "$REPO_ROOT/src/imports/cosmic/dark-theme.ron" ]; then
    cosmic-settings appearance import "$REPO_ROOT/src/imports/cosmic/dark-theme.ron"
  fi
  ok "Settings Cosmic done!"
}

# ============================================================================
# SHARED VARIABLES
# ============================================================================


# ============================================================================
# SHARED PATHS
# ============================================================================
CONFIG_SRC=""
CONFIG_DST=""
FONTS_SRC=""
FONTS_DST=""
LOCK_FILE=""

init_paths() {
  CONFIG_SRC="$REPO_ROOT/src/config"
  CONFIG_DST="$HOME/.config"
  FONTS_SRC="$REPO_ROOT/src/fonts"
  FONTS_DST="$HOME/.local/share/fonts"
  LOCK_FILE="$CONFIG_DST/blasphemous-desktop/.install.lock"
}

# ============================================================================
# ROOT DETECTION
# ============================================================================
fix_home_for_root() {
  if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-${DOAS_USER:-}}" ]; then
    user="${SUDO_USER:-${DOAS_USER:-}}"
    REAL_HOME="$(getent passwd "$user" | cut -d: -f6)" || REAL_HOME=""
    if [ -n "$REAL_HOME" ] && [ -d "$REAL_HOME" ]; then
      HOME="$REAL_HOME"
      warn "Root execution detected — using HOME=$HOME"
    fi
  fi
}

# ============================================================================
# COMMON INSTALL FUNCTIONS
# ============================================================================
default_apps() {
  if command -v xdg-settings >/dev/null 2>&1; then
    if xdg-settings set default-web-browser firefox.desktop; then
      ok "Default browser applied to: Firefox."
    else
      warn "Could not set Firefox as default browser."
    fi
  else
    warn "xdg-settings not found — default browser not changed."
  fi
}

set_gsettings() {
  if command -v gsettings >/dev/null 2>&1; then
    if
      gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" &&
      gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" &&
      gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' &&
      gsettings set org.gnome.desktop.interface cursor-theme "$GTK_CURSOR"
    then
      ok "GTK theme applied."
    else
      warn "Could not apply GTK theme."
    fi
    if
      gsettings set org.gnome.desktop.wm.preferences button-layout "$BUTTON_LAYOUT"
    then
      ok "Disabled buttons 'minimize,maximize,close' in window"
    fi
  fi
}

cleaner() {
  rm -rf "$HOME"/.local/share/gvfs-metadata/
}

copy_configs() {
  [ -d "$CONFIG_SRC" ] || die "Directory of configurations not found: $CONFIG_SRC."
  log "Copying configs → $CONFIG_DST" "\n"
  mkdir -p "$CONFIG_DST"
  find "$CONFIG_SRC" -type f -name "*.sh" -exec chmod +x {} \;

  skip_backup=false
  [ -f "$LOCK_FILE" ] && skip_backup=true

  for src_dir in "$CONFIG_SRC"/*/; do
    [ -d "$src_dir" ] || continue
    name="${src_dir%/}"
    name="${name##*/}"
    dst_dir="$CONFIG_DST/$name"
    if [ -d "$dst_dir" ]; then
      if [ "$skip_backup" = true ]; then
        rm -rf "$dst_dir"
        warn "$name — overwritten (lock present)"
      else
        backup="${dst_dir}.bak.$(date +%Y%m%d%H%M%S)"
        mv "$dst_dir" "$backup"
        warn "$name — backup saved in $backup"
      fi
    fi
    cp -rf "$src_dir" "$CONFIG_DST/"
    ok "$name"
  done

  ENV_BOOTSTRAP_SRC="$CONFIG_SRC/blasphemous-desktop/.blasphemous-desktop-bootstrap"
  if [ -f "$ENV_BOOTSTRAP_SRC" ]; then
    cp -f "$ENV_BOOTSTRAP_SRC" "$CONFIG_DST/.blasphemous-desktop-bootstrap"
    ok ".blasphemous-desktop-bootstrap"
  fi

  find "$CONFIG_DST" -maxdepth 1 -name "*.bak.*" -mtime +30 | while IFS= read -r old; do
    rm -rf "$old"
    warn "Old backup removed: $old"
  done
}

settings() {
  mkdir -p "${HOME}/.cache/waybar"
  printf '%s\n' "open" > "${HOME}/.cache/waybar/sidebar-state"
}

create_lock() {
  mkdir -p "$(dirname "$LOCK_FILE")"
  printf '%s\n' "Installed on: $(date)" > "$LOCK_FILE"
  printf '%s\n' "Version: $VERSION" >> "$LOCK_FILE"
  ok "Installation locked."
}

symlinks() {
  log "Creating symbolic links..." "\n"
  mkdir -p "$HOME/.local/bin"
  symlink "$HOME/.config/kitty/scripts/shortcuts.sh" "$HOME/.local/bin/kitty-help"
  symlink "$HOME/.config/blasphemous-desktop/sh/theme-switch.sh" "$HOME/.local/bin/theme-switch"
  ok "Creation of symbolic links completed."
  warn "Adding \"\$HOME/.local/bin\" in PATH"
}

copy_fonts() {
  [ -d "$FONTS_SRC" ] || { warn "Fonts directory not found: $FONTS_SRC — jumping."; return; }
  log "Copying fonts → $FONTS_DST" "\n"
  mkdir -p "$FONTS_DST"
  count=0
  for font in "$FONTS_SRC"/*; do
    [ -e "$font" ] || continue
    cp -rf "$font" "$FONTS_DST/"
    count=$((count + 1))
  done
  if [ "$count" -eq 0 ]; then
    warn "No source found in $FONTS_SRC."
  else
    ok "$count file(s)/folder(s) copied."
    if command -v fc-cache >/dev/null 2>&1; then
      log "Updating font cache..." "\n"
      fc-cache -f "$FONTS_DST"
      ok "Cache fonts updated."
    else
      warn "fc-cache not found — refresh the cache manually afterwards."
    fi
  fi
}

# ============================================================================
# ARCH-LINUX SPECIFIC
# ============================================================================
ARCH_BASE_DEPS="git base-devel go gcc lua wayland wayland-protocols"
ARCH_PACKAGES="
  firefox hyprland hyprland-qt-support hyprpaper hypridle hyprshutdown hyprlock
  hyprshot rofi-wayland kitty wev playerctl brightnessctl moreutils quickshell
  flameshot grim cliphist wl-clipboard slurp zsh gpu-screen-recorder wf-recorder
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk mpv
  xdg-desktop-portal-wlr unzip zathura terminus-font nautilus imagemagick
  dunst jq rofimoji rofi-calc bottom btop satty gsimplecal calcurse hyprpicker
  kooha xdg-utils gtk3 gtk4 adwaita-icon-theme noto-fonts noto-fonts-emoji uwsm
  ttf-nerd-fonts-symbols-mono ttf-jetbrains-mono-nerd otf-font-awesome vivid
  libnotify pamixer wireplumber networkmanager swappy foot snappy-switcher
  smog-bin xarchiver zip just libqalculate fontconfig qt5-quickcontrols2
  kvantum nwg-look qt5ct qt6ct qt6-declarative qt6-tools cosmic-files
  cosmic-settings file-roller pwvucontrol wtype fastfetch bluez polkit-gnome
  bluez-utils blueman imv hyprpolkitagent superfile zsh-autocomplete zsh-autosuggestions fzf-tab
  zsh-syntax-highlighting
"

install_yay() {
  log "yay not found — installing dependencies..." "\n"
  sudo pacman -S --needed --noconfirm $ARCH_BASE_DEPS || die "Failed to install yay dependencies."
  tmp="$(mktemp -d)" && trap 'rm -rf "$tmp"' EXIT INT TERM
  log "Cloning yay..." "\n"
  git clone https://aur.archlinux.org/yay.git "$tmp/yay" || die "Failed to clone yay."
  log "Compiling and installing yay..." "\n"
  (cd "$tmp/yay" && makepkg -si --noconfirm) || die "Failed to compile yay."
  ok "Yay, installed!"
}

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then
    ok "Yay, it's already installed."
  else
    install_yay
  fi
}

install_arch_packages() {
  log "Installing necessary packages..." "\n"
  yay -S --needed --noconfirm $ARCH_PACKAGES || die "Failed to install required packages."
  ok "All packages installed."
}

install_arch() {
  ensure_yay
  cleaner
  install_arch_packages
  default_apps
  settings_cosmic
  set_gsettings
  copy_configs
  create_lock
  symlinks
  copy_fonts
  install_term_options
  settings
}

# ============================================================================
# FEDORA SPECIFIC
# ============================================================================
FEDORA_BASE_DEPS="git @development-tools golang gcc lua wayland wayland-protocols-devel"
FEDORA_PACKAGES="
  firefox hyprland hyprland-qt-support hyprpaper hypridle hyprlock
  hyprshot rofi-wayland kitty wev playerctl brightnessctl moreutils quickshell
  flameshot grim cliphist wl-clipboard slurp zsh wf-recorder
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk mpv
  xdg-desktop-portal-wlr unzip zathura terminus-fonts nautilus ImageMagick
  dunst jq rofimoji qalculate-gtk bottom btop satty gsimplecal calcurse hyprpicker
  xdg-utils gtk3 gtk4 adwaita-icon-theme google-noto-fonts google-noto-emoji-fonts
  vivid libnotify pamixer wireplumber NetworkManager swappy foot
  xarchiver zip just libqalculate fontconfig qt5-qtquickcontrols2
  kvantum nwg-look qt5ct qt6ct qt6-qtdeclarative qt6-qttools
  file-roller pwvucontrol wtype fastfetch polkit-gnome bluez
  bluez-utils blueman imv hyprpolkitagent superfile
"
HYPERSHUTDOWN_REPO="https://github.com/hyprwm/hyprshutdown.git"

ensure_copr() {
  if ! command -v dnf >/dev/null 2>&1; then
    die "dnf not found. Are you sure this is Fedora?"
  fi
  log "Enabling COPR: solopasha/hyprland..." "\n"
  sudo dnf copr enable -y solopasha/hyprland || die "Failed to enable COPR solopasha/hyprland."
  ok "COPR solopasha/hyprland enabled."
}

install_fedora_base_deps() {
  log "Installing base dependencies..." "\n"
  sudo dnf install -y $FEDORA_BASE_DEPS || die "Failed to install base dependencies."
  ok "Base dependencies installed."
}

install_fedora_packages() {
  log "Installing necessary packages..." "\n"
  sudo dnf install -y $FEDORA_PACKAGES || die "Failed to install required packages."
  ok "All packages installed."
}

install_hyprshutdown() {
  if command -v hyprshutdown >/dev/null 2>&1; then
    ok "hyprshutdown already installed."
    return
  fi
  log "Installing hyprshutdown from git..." "\n"
  tmp="$(mktemp -d)" && trap 'rm -rf "$tmp"' EXIT INT TERM
  git clone "$HYPERSHUTDOWN_REPO" "$tmp/hyprshutdown" || die "Failed to clone hyprshutdown."
  (
    cd "$tmp/hyprshutdown" || die
    cmake --no-warn-unused-cli -B build || die "Failed to configure hyprshutdown."
    cmake --build build || die "Failed to build hyprshutdown."
    sudo cmake --install build || die "Failed to install hyprshutdown."
  )
  ok "hyprshutdown installed."
}

patch_configs_for_fedora() {
  log "Applying Fedora-specific config patches..." "\n"
  if [ -f "$CONFIG_DST/hypr/hyprland.lua" ]; then
    sed -i 's|rofi -show calc -modi calc -no-show-match -no-sort|qalculate-gtk|' \
      "$CONFIG_DST/hypr/hyprland.lua" 2>/dev/null || warn "Could not update calc keybinding"
    ok "Keybinding Super+C now opens qalculate-gtk (Fedora)."
  fi
}

install_fedora() {
  ensure_copr
  cleaner
  install_fedora_base_deps
  install_fedora_packages
  install_hyprshutdown
  default_apps
  settings_cosmic
  set_gsettings
  copy_configs
  create_lock
  patch_configs_for_fedora
  symlinks
  copy_fonts
  install_term_options
  settings
}

# ============================================================================
# DISTRO DETECTION
# ============================================================================
detect_distro() {
  if grep -qi "arch" /etc/os-release 2>/dev/null; then
    echo "arch"
  elif grep -qi "fedora" /etc/os-release 2>/dev/null; then
    echo "fedora"
  else
    die "Unsupported distribution. Only Arch Linux and Fedora are supported."
  fi
}

# ============================================================================
# GIT PULL (for local --upgrade)
# ============================================================================
pull() {
  if ! command -v git >/dev/null 2>&1; then
    die "Git is not installed. Please install it."
  fi
  log "Checking for updates..." "\n"
  git fetch origin || die "Failed to contact the remote repository."
  head=$(git rev-parse HEAD)
  fetch_head=$(git rev-parse FETCH_HEAD)
  if [ "$head" = "$fetch_head" ]; then
    ok "Already been updated."
    return 0
  fi
  git merge --ff-only FETCH_HEAD || die "Failed to apply updates."
  ok "Updated to version: $VERSION."
}

# ============================================================================
# RELEASE API (remote mode)
# ============================================================================
gh_get() {
  curl -fsSL -H "Accept: application/vnd.github+json" -H "User-Agent: ${NAME_PROJECT}-install-script" "$1"
}

extract_tags() {
  grep -o '"tag_name":"[^"]*"' | sed 's/"tag_name":"//;s/"//'
}

list_releases() {
  r_info "Fetching releases for ${REPO}..."
  json=$(gh_get "${API}/releases") || r_die "Failed to query the GitHub API (rate limit or network issue)."
  tags=$(printf '%s\n' "$json" | extract_tags)
  [ -n "$tags" ] || r_die "No releases found."
  printf '%sAvailable releases:%s\n' "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET"
  printf '%s\n' "$tags" | sed 's/^/  - /'
}

latest_tag() {
  json=$(gh_get "${API}/releases/latest") || r_die "Failed to fetch the latest release."
  tag=$(printf '%s\n' "$json" | extract_tags | head -n1)
  [ -n "$tag" ] || r_die "Could not determine the latest version."
  printf '%s' "$tag"
}

tag_exists() {
  status=$(curl -sS -o /dev/null -w '%{http_code}' \
    -H "Accept: application/vnd.github+json" -H "User-Agent: ${NAME_PROJECT}-install-script" \
    "${API}/releases/tags/$1" 2>/dev/null) || status="000"
  [ "$status" = "200" ]
}

resolve_tag() {
  want="$1"
  if tag_exists "$want"; then
    printf '%s' "$want"
    return 0
  fi
  case "$want" in
    v*) : ;;
    *)
      if tag_exists "v${want}"; then
        printf '%s' "v${want}"
        return 0
      fi
      ;;
  esac
  r_die "Version '$want' not found. Use --releases to list available versions."
}

# ============================================================================
# REMOTE INSTALL (download release, extract, run make install)
# ============================================================================
remote_install() {
  need_cmd curl
  need_cmd unzip
  need_cmd make
  need_cmd mktemp

  version_arg="${SETUP_VERSION:-}"
  [ $# -gt 0 ] && version_arg="$1"

  if [ -n "$version_arg" ]; then
    r_info "Resolving requested version: ${version_arg}"
    tag=$(resolve_tag "$version_arg")
  else
    r_info "Fetching the latest available version..."
    tag=$(latest_tag)
  fi
  r_ok "Selected version: ${tag}"

  download_url="https://github.com/${REPO}/archive/refs/tags/${tag}.zip"

  WORKDIR=$(mktemp -d "/tmp/${NAME_PROJECT}.XXXXXX")
  trap 'rm -rf "$WORKDIR"' EXIT INT TERM
  zip_file="${WORKDIR}/${NAME_PROJECT}-${tag}.zip"

  r_info "Downloading ${download_url}..."
  curl -fsSL -o "$zip_file" "$download_url" || r_die "Failed to download the release archive."

  r_info "Extracting archive..."
  unzip -q "$zip_file" -d "$WORKDIR" || r_die "Failed to extract the .zip archive."

  extracted_dir=$(find "$WORKDIR" -mindepth 1 -maxdepth 1 -type d | head -n1)
  [ -n "$extracted_dir" ] && [ -d "$extracted_dir" ] || r_die "Could not locate the extracted folder."

  REAL_USER="${SUDO_USER:-${DOAS_USER:-}}"
  REAL_HOME="${HOME}"

  if [ "$(id -u)" -eq 0 ]; then
    if [ -n "$REAL_USER" ]; then
      REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)" || r_die "Failed to determine home directory for $REAL_USER."
      r_info "Detected sudo — installing as $REAL_USER (HOME=$REAL_HOME)"
    else
      r_die "This script must not be run as root. Run as a regular user with sudo access."
    fi
  fi

  if [ ! -t 0 ]; then
    r_warn "stdin is not a terminal — if prompts appear, re-run using:"
    r_warn "  sh -c \"\$(curl -fsSL ${SITE_URL}/setup.sh)\" instead of '| sh'."
  fi

  r_info "Running 'make install'..."
  if [ -n "$REAL_USER" ]; then
    sudo -u "$REAL_USER" env HOME="$REAL_HOME" make -C "$extracted_dir" install || r_die "Failed to run 'make install'."
  else
    make -C "$extracted_dir" install || r_die "Failed to run 'make install'."
  fi

  ensure_shell
  prompt_logout

  r_ok "${NAME_PROJECT} installed successfully (version ${tag})."
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || r_die "Required command not found: $1"
}

# ============================================================================
# SHELL CHECK
# ============================================================================
ensure_shell() {
  if [ "$SHELL" = "$USED_SHELL" ]; then
    ok "Shell is already $USED_SHELL"
    return
  fi

  echo ""
  log "Current shell:   $SHELL" "\n"
  log "Recommended:     $USED_SHELL" "\n"

  if ! confirm "Switch default shell to $USED_SHELL?"; then
    warn "Shell not changed."
    return
  fi

  if ! grep -qx "$USED_SHELL" /etc/shells 2>/dev/null; then
    warn "$USED_SHELL is not listed in /etc/shells. Cannot change."
    warn "Try: echo '$USED_SHELL' | sudo tee -a /etc/shells && chsh -s $USED_SHELL"
    return
  fi

  if ! command -v chsh >/dev/null 2>&1; then
    warn "chsh not found. Install it (part of util-linux) or run manually:"
    warn "  chsh -s $USED_SHELL"
    return
  fi

  if chsh -s "$USED_SHELL"; then
    ok "Shell changed to $USED_SHELL. Log out and back in to apply."
  else
    warn "Failed to change shell. Try: chsh -s $USED_SHELL"
  fi
}

# ============================================================================
# LOGOUT PROMPT
# ============================================================================
prompt_logout() {
  [ -t 0 ] || return  # skip if non-interactive (pipe mode)
  echo ""
  if confirm "Logout now to apply all changes?"; then
    ok "Logging out..."
    case "${DESKTOP_SESSION:-${XDG_SESSION_DESKTOP:-}}" in
      *hyprland*|*Hyprland*)
        if command -v hyprctl >/dev/null 2>&1; then hyprctl dispatch exit
        else loginctl terminate-session self; fi ;;
      sway)
        if command -v swaymsg >/dev/null 2>&1; then swaymsg exit
        else loginctl terminate-session self; fi ;;
      *) loginctl terminate-session self ;;
    esac
  else
    ok "Logout skipped. Remember to log out manually to apply changes."
  fi
}

# ============================================================================
# UNINSTALL
# ============================================================================
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
  for link in "kitty-help" "theme-switch"; do
    target="$HOME/.local/bin/$link"
    if [ -L "$target" ] || [ -f "$target" ]; then
      dry rm -f "$target"
      ok "Removed: $target"
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
      dry rm -rf "$dst_dir"
      ok "Removed: $dst_dir"
    else
      warn "Not found: $dst_dir"
    fi
  done
  bootstrap_dst="$CONFIG_DST/.blasphemous-desktop-bootstrap"
  if [ -f "$bootstrap_dst" ]; then
    dry rm -f "$bootstrap_dst"
    ok "Removed: $bootstrap_dst"
  fi
  warn "Backups (files ending with .bak.*) were preserved in $CONFIG_DST/"
  if $REMOVE_BACKUPS; then
    if confirm "Remove all backup directories?"; then
      dry find "$CONFIG_DST" -maxdepth 1 -name "*.bak.*" -exec rm -rf {} +
      ok "Backups removed."
    fi
  fi
}

remove_fonts() {
  [ -d "$FONTS_DST" ] || { warn "Fonts directory not found: $FONTS_DST"; return; }
  [ -d "$FONTS_SRC" ] || { warn "Source fonts not found: $FONTS_SRC"; return; }
  log "Removing fonts installed by this project..." "\n"
  removed=0
  for font in "$FONTS_SRC"/*; do
    [ -e "$font" ] || continue
    name="$(basename "$font")"
    dst="$FONTS_DST/$name"
    if [ -e "$dst" ]; then
      removed=$((removed + 1))
      dry rm -rf "$dst"
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
      tmpfile="$(mktemp)"
      grep -vFx "$source_line" "$rc" | grep -vFx "$comment_line" > "$tmpfile" || true
      mv "$tmpfile" "$rc"
      ok "Cleaned: $rc"
    fi
  done
}

remove_cosmic_settings() {
  cosmic_dir="$HOME/.config/cosmic"
  if [ -d "$cosmic_dir" ]; then
    if confirm "Remove Cosmic settings directory ($cosmic_dir)?"; then
      dry rm -rf "$cosmic_dir"
      ok "Removed Cosmic settings."
    fi
  else
    warn "Cosmic settings not found."
  fi
}

remove_lock() {
  if [ -f "$LOCK_FILE" ]; then
    dry rm -f "$LOCK_FILE"
    ok "Removed install lock: $LOCK_FILE"
  fi
}

remove_waybar_cache() {
  cache_file="${HOME}/.cache/waybar/sidebar-state"
  if [ -f "$cache_file" ]; then
    dry rm -f "$cache_file"
    ok "Removed: $cache_file"
  fi
}

revert_fedora_patches() {
  hyprland_lua="$CONFIG_DST/hypr/hyprland.lua"
  [ -f "$hyprland_lua" ] || return
  if grep -q "qalculate-gtk" "$hyprland_lua" 2>/dev/null; then
    dry sed -i 's|qalculate-gtk|rofi -show calc -modi calc -no-show-match -no-sort|' "$hyprland_lua"
    ok "Reverted Fedora calc patch in $hyprland_lua"
  fi
}

revert_gsettings() {
  command -v gsettings >/dev/null 2>&1 || { warn "gsettings not found — skipping."; return; }
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
  command -v xdg-settings >/dev/null 2>&1 || { warn "xdg-settings not found — skipping."; return; }
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
  if [ -f "$CONFIG_DST/.blasphemous-desktop-bootstrap" ]; then
    printf "  %b•%b %s\n" "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET" "$CONFIG_DST/.blasphemous-desktop-bootstrap"
  fi
  echo ""
  accent "Symlinks:"
  for link in "kitty-help" "theme-switch"; do
    target="$HOME/.local/bin/$link"
    [ -L "$target" ] && printf "  %b•%b %s → %s\n" "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET" "$target" "$(readlink "$target")"
    [ -f "$target" ] && printf "  %b•%b %s (file)\n" "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET" "$target"
  done
  echo ""
  accent "Terminal integration:"
  for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    [ -f "$rc" ] && grep -q '. "$HOME/.config/term/options.sh"' "$rc" 2>/dev/null && \
      printf "  %b•%b Term options found in %s\n" "$MSG_COLOR_GREEN" "$MSG_COLOR_RESET" "$rc"
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
  log "blasphemous-desktop — Uninstall" "\n"
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
    warn "Package removal not implemented — uninstall packages manually."
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
          if command -v hyprctl >/dev/null 2>&1; then hyprctl dispatch exit
          else loginctl terminate-session self; fi ;;
        sway)
          if command -v swaymsg >/dev/null 2>&1; then swaymsg exit
          else loginctl terminate-session self; fi ;;
        *) loginctl terminate-session self ;;
      esac
    fi
  fi
}

uninstall_usage() {
  cat <<EOF
Usage: make uninstall [OPTIONS]
   or: sh setup.sh --uninstall [OPTIONS]

Options:
  --dry-run          Show what would be removed without actually removing
  --remove-backups   Also remove .bak.* backup directories
  --purge-packages   Enable package removal hints (does NOT actually remove packages)
  --help             Show this message
EOF
}

# ============================================================================
# LOCAL INSTALL (direct, from repository checkout)
# ============================================================================
local_install() {
  install_"$(detect_distro)"
}

# ============================================================================
# MAIN DISPATCH
# ============================================================================

LOCAL_MODE=false
REPO_ROOT=""
DRY_RUN=false
REMOVE_BACKUPS=false
PURGE_PACKAGES=false
WORKDIR=""

# Determine if running from local repo or piped via curl
dir="$(dirname "$0" 2>/dev/null)" || dir="."
SCRIPT_DIR="$(cd "$dir" 2>/dev/null && pwd 2>/dev/null || pwd)"

if [ -f "$SCRIPT_DIR/src/config/blasphemous-desktop/.blasphemous-desktop-bootstrap" ] || \
   [ -f "$(pwd)/src/config/blasphemous-desktop/.blasphemous-desktop-bootstrap" ]; then
  LOCAL_MODE=true
  if [ -f "$SCRIPT_DIR/src/config/blasphemous-desktop/.blasphemous-desktop-bootstrap" ]; then
    REPO_ROOT="$SCRIPT_DIR"
  else
    REPO_ROOT="$(pwd)"
  fi
  fix_home_for_root
  init_paths
fi

# Normalize: when remote and $@ is empty, the arg may be in $0
# (e.g. sh -c "$(curl ...)" --releases  sets  $0=--releases)
if [ "$LOCAL_MODE" = false ] && [ $# -eq 0 ]; then
  case "${0:-}" in
    --releases|-l|--help|-h|--version|--install|--upgrade|--uninstall)
      set -- "$0"
      ;;
    sh|bash|dash|zsh|/tmp/*)
      # $0 is the shell or a temp path — no real args
      ;;
    *)
      # Looks like a version tag
      set -- "$0"
      ;;
  esac
fi

# Parse arguments
case "${1:-}" in
  # --- Local-only commands ---
  --install)
    if [ "$LOCAL_MODE" = true ]; then
      local_install
      ensure_shell
      prompt_logout
      copyright
    else
      r_warn "In remote mode, just run without arguments to install the latest version."
      r_warn "  sh -c \"\$(curl -fsSL ${SITE_URL}/setup.sh)\""
      exit 0
    fi
    ;;
  --upgrade)
    if [ "$LOCAL_MODE" = true ]; then
      pull
      local_install
      ensure_shell
      prompt_logout
      copyright
    else
      r_warn "'--upgrade' is only available when running from a local repository."
      r_warn "In remote mode, run without arguments to get the latest release."
      exit 0
    fi
    ;;
  --uninstall)
    if [ "$LOCAL_MODE" = false ]; then
      tmpdir="$(mktemp -d)"
      trap 'rm -rf "$tmpdir"' EXIT INT TERM
      git clone --depth 1 https://github.com/williamcanin/blasphemous-desktop.git "$tmpdir" || \
        die "Failed to clone repository."
      REPO_ROOT="$tmpdir"
      init_paths
    fi
    shift
    for arg in "$@"; do
      case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --remove-backups) REMOVE_BACKUPS=true ;;
        --purge-packages) PURGE_PACKAGES=true ;;
        --help) uninstall_usage; exit 0 ;;
        *) warn "Unknown option: $arg"; uninstall_usage; exit 1 ;;
      esac
    done
    uninstall
    copyright
    ;;
  # --- Remote-only commands ---
  --releases|-l)
    if [ "$LOCAL_MODE" = true ]; then
      # Works locally too
      list_releases
    else
      list_releases
    fi
    ;;
  # --- Universal commands ---
  --help|-h)
    if [ "$LOCAL_MODE" = true ]; then
      help
    else
      online_usage
    fi
    copyright
    ;;
  # --help-dev)
  #   help_dev
  #   copyright
  #   ;;
  --version)
    plain "Version: $VERSION" "\n"
    ;;
  # --- Positional: version tag (remote) or error (local) ---
  "")
    # No args — remote: install latest, local: show help
    if [ "$LOCAL_MODE" = false ]; then
      remote_install
      copyright
    else
      help
      copyright
      exit 1
    fi
    ;;
  *)
    # Could be a version tag — only valid in remote mode
    if [ "$LOCAL_MODE" = false ]; then
      remote_install "$1"
      copyright
    else
      help
      copyright
      exit 1
    fi
    ;;
esac
exit 0
