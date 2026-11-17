#!/usr/bin/env bash
# Laptop screen time: credits elapsed seconds while the session is not idle
# (logind IdleHint). Oneshot, run every 60s by a systemd timer.
# Env: TICK_SEC (default 60, used on first run), MAX_GAP (default 150;
#      larger gaps, e.g. after suspend, are credited as one TICK only)
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/common.sh"
TICK=${TICK_SEC:-60}
MAX_GAP=${MAX_GAP:-150}
sf=$STATE_DIR/screen-laptop.state          # "date seconds last_epoch"

printf -v now '%(%s)T' -1
today d
date=$d secs=0 last=""
[[ -r $sf ]] && read -r date secs last < "$sf" || true
[[ $date == "$d" ]] || { date=$d; secs=0; last=""; }
[[ $last =~ ^[0-9]+$ ]] || last=$((now - TICK))
gap=$((now - last))
(( gap < 0 )) && gap=0
(( gap > MAX_GAP )) && gap=$TICK

sid=$(loginctl show-user "$USER" -p Display --value 2>/dev/null || true)
[[ -n $sid ]] || sid=${XDG_SESSION_ID:-}
[[ -n $sid ]] || sid=$(loginctl list-sessions --no-legend | awk -v u="$USER" '$3==u{print $1; exit}')
idle=$(loginctl show-session "${sid:-self}" -p IdleHint --value 2>/dev/null || echo no)

[[ $idle == yes ]] || secs=$((secs + gap))
echo "$date $secs $now" > "$sf"
post /stats "{\"date\":\"$date\",\"metrics\":{\"screen_laptop\":$secs}}" >/dev/null
echo "$date screen_laptop=${secs}s idle=$idle"
