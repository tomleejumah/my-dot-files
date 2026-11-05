#!/usr/bin/env bash
# long-running service. Needs read access to /dev/input (input group).
. "$(dirname "$(readlink -f "$0")")/common.sh"
EVERY=${POST_EVERY:-60}
sf=$STATE_DIR/keystrokes.state     # "date count"

reader() { # emit "k" per key-down; only type/value bytes inspected
  stdbuf -oL od -An -v -w24 -tx1 "$1" |
    awk '$17=="01"&&$18=="00"&&$21=="01"&&$22=="00"&&$23=="00"&&$24=="00"{print "k";fflush()}'
}

devs=(/dev/input/by-path/*event-kbd)
[[ -e ${devs[0]} ]] || { echo "no keyboards" >&2; exit 1; }

{ for d in "${devs[@]}"; do reader "$d" & done; wait; } |
{
  today d
  date=$d count=0
  [[ -r $sf ]] && read -r date count < "$sf"
  last=$SECONDS
  while :; do
    if IFS= read -r -t 5 _; then
      today d; [[ $date == "$d" ]] || { date=$d; count=0; }
      ((++count))
    else
      (( $? > 128 )) || exit 1   # EOF → readers died
    fi
    if (( SECONDS - last >= EVERY )); then
      today d; [[ $date == "$d" ]] || { date=$d; count=0; }
      echo "$date $count" > "$sf"
      post /stats "{\"date\":\"$date\",\"metrics\":{\"keystrokes\":$count}}" >/dev/null \
        || echo "post failed" >&2
      last=$SECONDS
    fi
  done
}
