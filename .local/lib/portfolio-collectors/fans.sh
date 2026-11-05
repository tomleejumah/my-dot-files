#!/usr/bin/env bash
# oneshot: run via systemd timer
set -euo pipefail
. "$(dirname "$(readlink -f "$0")")/common.sh"
json=""
for d in /sys/class/hwmon/hwmon*; do
  read -r name < "$d/name" 2>/dev/null || continue
  [[ $name == thinkpad ]] || continue
  for f in "$d"/fan*_input; do
    [[ -r $f ]] || continue
    n=${f##*/fan}; n=${n%_input}
    read -r rpm < "$f"
    [[ $rpm =~ ^[0-9]+$ ]] && json+=",\"fan${n}_rpm\":$rpm"
  done
  break
done
[[ -n $json ]] || { echo "no thinkpad fan*_input found" >&2; exit 1; }
printf -v ts '%(%s)T' -1
payload="{\"ts\":$ts,\"host\":\"lenovo\"$json}"
post /laptop/latest "$payload" >/dev/null
echo "$payload"
