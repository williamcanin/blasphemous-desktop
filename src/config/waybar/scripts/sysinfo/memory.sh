#!/usr/bin/env sh

# shellcheck disable=SC1091
. "$HOME/.config/.blasphemous-desktop-bootstrap"

MEM_TOTAL=$(awk '/MemTotal/ {printf "%.1f", $2/1024/1024}' /proc/meminfo)

MEM_AVAIL=$(awk '/MemAvailable/ {printf "%.1f", $2/1024/1024}' /proc/meminfo)

MEM_USED=$(awk -v t="$MEM_TOTAL" -v a="$MEM_AVAIL" \
  'BEGIN {printf "%.1f", t-a}')

MEM_PERC=$(awk -v u="$MEM_USED" -v t="$MEM_TOTAL" \
  'BEGIN {printf "%.0f", (u/t)*100}')

SWAP_TOTAL=$(awk '/SwapTotal/ {printf "%.1f", $2/1024/1024}' /proc/meminfo)

SWAP_FREE=$(awk '/SwapFree/ {printf "%.1f", $2/1024/1024}' /proc/meminfo)

SWAP_USED=$(awk -v t="$SWAP_TOTAL" -v f="$SWAP_FREE" \
  'BEGIN {printf "%.1f", t-f}')

if [ "$SWAP_TOTAL" = "0.0" ]; then
  SWAP_PERC=0
else
  SWAP_PERC=$(awk -v u="$SWAP_USED" -v t="$SWAP_TOTAL" \
    'BEGIN {printf "%.0f", (u/t)*100}')
fi

RAM_BAR=$(string_bar "$MEM_PERC" "$BAR_SIZE")
SWAP_BAR=$(string_bar "$SWAP_PERC" "$BAR_SIZE")

TEXT=$(
  cat <<EOF
Type   Used         Perc
RAM    ${MEM_USED}/${MEM_TOTAL}G   ${MEM_PERC}% $RAM_BAR
Swap   ${SWAP_USED}/${SWAP_TOTAL}G   ${SWAP_PERC}% $SWAP_BAR
EOF
)

json_output "$TEXT"
