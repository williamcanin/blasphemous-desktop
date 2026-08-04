#!/usr/bin/env sh

# Colors using Vivid (theme-aware: follows the active blasphemous theme)
if command -v vivid >/dev/null 2>&1; then
  _vivid_themes="${HOME}/.config/vivid/themes"
  _active=""
  if [ -f "${HOME}/.config/blasphemous-desktop/.active-theme" ]; then
    _active="$(tr -d '\n\r' < "${HOME}/.config/blasphemous-desktop/.active-theme" 2>/dev/null)"
  fi

  _theme=""
  if [ -n "$_active" ] && [ -f "${_vivid_themes}/${_active}.yml" ]; then
    _theme="$_active"
  elif [ -f "${_vivid_themes}/blasphemous-kneeling-stone.yml" ]; then
    _theme="blasphemous-kneeling-stone"
  else
    _theme="one-dark"
  fi

  if _lscolors="$(vivid generate "$_theme" 2>/dev/null)"; then
    export LS_COLORS="$_lscolors"
  fi
  unset _vivid_themes _active _theme _lscolors
fi
