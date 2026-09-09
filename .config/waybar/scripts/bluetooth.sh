#!/usr/bin/env bash
#
# Connect to a Bluetooth device using bluetoothctl and fzf
#

SCAN_TIMEOUT=10
WIN_WIDTH="25"
WIN_HEIGHT="30"
# --------------------------------------------------
# Toggle: if the picker window is already open, close it and exit
# --------------------------------------------------
if pkill -f "kitty --class bluetooth-selector"; then
    exit 0
fi

# --------------------------------------------------
# Unblock Bluetooth if it is soft-blocked
# --------------------------------------------------
rfkill unblock bluetooth

# --------------------------------------------------
# Turn Bluetooth on if powered off
# --------------------------------------------------
status=$(bluetoothctl show | awk '/Powered:/ {print $2}')

if [[ "$status" == "no" ]]; then
    bluetoothctl power on >/dev/null
    notify-send 'Bluetooth On' -r 1925
fi

# --------------------------------------------------
# Write the picker logic to a real temp script (avoids nested
# quoting issues from inlining this into `kitty bash -c '...'`)
# --------------------------------------------------
SELECTION_FILE=$(mktemp)
PICKER_SCRIPT=$(mktemp)
trap 'rm -f "$SELECTION_FILE" "$PICKER_SCRIPT"' EXIT

cat > "$PICKER_SCRIPT" <<EOF
#!/usr/bin/env bash
echo "Scanning for devices ($SCAN_TIMEOUT s)..."
bluetoothctl --timeout $SCAN_TIMEOUT scan on >/dev/null

bluetoothctl devices | fzf \\
    --border=sharp \\
    --border-label=" Bluetooth Devices " \\
    --ghost="Search" \\
    --height=~100% \\
    --highlight-line \\
    --info=inline-right \\
    --pointer= \\
    --reverse \\
    --header="Address           Name" \\
    --bind "ctrl-r:reload(bluetoothctl devices)" \\
    > "$SELECTION_FILE"
EOF

chmod +x "$PICKER_SCRIPT"

kitty --class bluetooth-selector \
    -o initial_window_width="$WIN_WIDTH" \
    -o initial_window_height="$WIN_HEIGHT" \
    -o remember_window_size=no \
    bash "$PICKER_SCRIPT"

selected=$(<"$SELECTION_FILE")

# --------------------------------------------------
# Nothing selected
# --------------------------------------------------
[[ -z "$selected" ]] && exit 0

# Get Bluetooth address
address=$(awk '{print $2}' <<< "$selected")

[[ -z "$address" ]] && exit 0

# --------------------------------------------------
# Check if already connected
# --------------------------------------------------
connected=$(bluetoothctl info "$address" | awk '/Connected:/ {print $2}')

if [[ "$connected" == "yes" ]]; then
    echo "Disconnecting..."

    if timeout "$SCAN_TIMEOUT" bluetoothctl disconnect "$address" >/dev/null; then
        notify-send 'Bluetooth' 'Successfully disconnected'
    else
        notify-send 'Bluetooth' 'Failed to disconnect'
    fi

    exit 0
fi

# --------------------------------------------------
# Check if paired
# --------------------------------------------------
paired=$(bluetoothctl info "$address" | awk '/Paired:/ {print $2}')

if [[ "$paired" == "no" ]]; then
    echo "Pairing..."

    if ! timeout "$SCAN_TIMEOUT" bluetoothctl pair "$address" >/dev/null; then
        notify-send 'Bluetooth' 'Failed to pair'
        exit 1
    fi
fi

# --------------------------------------------------
# Connect
# --------------------------------------------------
echo "Connecting..."

if timeout "$SCAN_TIMEOUT" bluetoothctl connect "$address" >/dev/null; then
    notify-send 'Bluetooth' 'Successfully connected'
else
    notify-send 'Bluetooth' 'Failed to connect'
fi
