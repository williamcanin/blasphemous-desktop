#!/usr/bin/env sh
# shellcheck shell=sh disable=SC1091

# =============================================================================
# bootstrap.sh — Carrega automaticamente todos os módulos compartilhados.
#
# Uso em scripts:
#   . "${HOME}/.config/.blasphemous-desktop-bootstrap"
#
# Isso disponibiliza todas as APIs (log_*, string_*, json_*, ...)
# e variáveis globais (WALLPAPER_PATH, BUTTON_LAYOUT, ...).
# =============================================================================

ENVIRONMENT_ROOT="${HOME}/.config/blasphemous-desktop"
MODULES_DIR="${ENVIRONMENT_ROOT}/sh"

. "${MODULES_DIR}/variables.sh"
. "${MODULES_DIR}/paths.sh"
. "${MODULES_DIR}/locale.sh"
. "${MODULES_DIR}/log.sh"
. "${MODULES_DIR}/notify.sh"
. "${MODULES_DIR}/string.sh"
. "${MODULES_DIR}/json.sh"
. "${MODULES_DIR}/hypr.sh"
