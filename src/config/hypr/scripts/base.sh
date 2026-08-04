#!/usr/bin/env sh

# shellcheck disable=SC1091
# DEPRECATED: Sourcing base.sh directly is deprecated.
# Prefer: . "${HOME}/.config/.blasphemous-desktop-bootstrap"
. "$HOME/.config/.blasphemous-desktop-bootstrap"

mkdir -p "$HYPR_CACHE_DIR"
