#!/usr/bin/env bash
# Fan RPM -> POST /laptop/latest. Oneshot (systemd timer).
# Env: FAN_HWMON (hwmon driver name, default thinkpad), HOST_NAME (default lenovo)
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/common.sh"
FAN_HWMON=${FAN_HWMON:-thinkpad}
HOST_NAME=${HOST_NAME:-lenovo}
json=""
for d in /sys/class/hwmon/hwmon*; do
  read -r name < "$d/name" 2>/dev/null || continue
  [[ $name == "$FAN_HWMON" ]] || continue
  for f in "$d"/fan*_input; do
    [[ -r $f ]] || continue
    n=${f##*/fan}; n=${n%_input}
    read -r rpm < "$f"
    [[ $rpm =~ ^[0-9]+$ ]] && json+=",\"fan${n}_rpm\":$rpm"
  done
  break
done
[[ -n $json ]] || { echo "no $FAN_HWMON fan*_input found (see /sys/class/hwmon/*/name)" >&2; exit 1; }
printf -v ts '%(%s)T' -1
payload="{\"ts\":$ts,\"host\":\"$HOST_NAME\"$json}"
post /laptop/latest "$payload" >/dev/null
echo "$payload"
