#!/usr/bin/env bash
#
# Connect to a Wi-Fi network using nmcli and fzf
#
WIFI_PID="/tmp/wifi_script.pid"

if [[ -f $WIFI_PID ]] && kill -0 "$(<"$WIFI_PID")" 2>/dev/null; then
    echo "Script already running, killing and turning off wifi..."
    kill "$(<"$WIFI_PID")"
    rm -f "$WIFI_PID"
    exit 0
fi

echo $$ > "$WIFI_PID"
trap 'rm -f "$WIFI_PID"' EXIT

status=$(nmcli radio wifi)
if [[ $status == 'disabled' ]]; then
    nmcli radio wifi on
    notify-send 'Wi-Fi Enabled' -r 1125
fi

nmcli device wifi rescan 2>/dev/null
s=5
for ((i = 1; i <= s; i++)); do
    echo -en "\rScanning for networks... ($i/$s)"
    output=$(timeout 1 nmcli device wifi list)
    list=$(tail -n +2 <<<"$output" | awk '$2 != "--"')
    [[ -n $list ]] && break
done
printf '\n\n'

if [[ -z $list ]]; then
    notify-send 'Wi-Fi' 'No networks found'
    exit 1
fi

header=$(head -n 1 <<<"$output")
options=(
    --border=sharp
    --border-label=' Wi-Fi Networks '
    --ghost='Search'
    --header="$header"
    --height=~100%
    --highlight-line
    --info=inline-right
    --pointer=
    --reverse
)
options+=("${colors[@]}")

bssid=$(fzf "${options[@]}" <<<"$list" | awk '{print $1}')
[[ -z $bssid ]] && exit 0

if [[ $bssid == '*' ]]; then
    notify-send 'Wi-Fi' 'Already connected to this network'
    exit 0
fi

echo 'Connecting...'
if nmcli device wifi connect "$bssid" --ask; then
  ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
    # Check for actual internet access
    sleep 5
    if ping -c 1 -W 3 1.1.1.1 &>/dev/null; then
        notify-send "$ssid" 'Successfully connected' -i network-wireless
    else
        notify-send "$ssid" 'Connected but no internet access' -i network-wireless-offline
    fi
else
    notify-send "$ssid" 'Failed to connect' -i network-wireless-offline
fi
