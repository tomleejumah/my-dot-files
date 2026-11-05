#!/usr/bin/env bash
# oneshot: run every 60s via systemd timer
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/common.sh"
TICK=${TICK_SEC:-60}
sf=$STATE_DIR/screen-laptop.state   # "date seconds"
today d
date=$d secs=0
[[ -r $sf ]] && read -r date secs < "$sf" || true
[[ $date == "$d" ]] || { date=$d; secs=0; }

sid=${XDG_SESSION_ID:-$(loginctl list-sessions --no-legend | awk -v u="$USER" '$3==u{print $1; exit}')}
idle=$(loginctl show-session "${sid:-self}" -p IdleHint --value 2>/dev/null || echo no)
[[ $idle == yes ]] || secs=$((secs + TICK))
echo "$date $secs" > "$sf"

post /stats "{\"date\":\"$date\",\"metrics\":{\"screen_laptop\":$secs}}" >/dev/null
echo "$date screen_laptop=${secs}s idle=$idle"
