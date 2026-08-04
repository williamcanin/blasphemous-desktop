# shellcheck shell=sh disable=SC2034

# -- Path helpers -------------------------------------------------------------
paths_cache() { echo "${HOME}/.cache/${1}"; }
paths_config() { echo "${HOME}/.config/${1}"; }
