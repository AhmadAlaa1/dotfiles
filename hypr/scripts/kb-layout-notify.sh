#!/usr/bin/env bash

# Get all keyboard device names
mapfile -t KEYBOARDS < <(hyprctl -j devices | jq -r '.keyboards[].name')

# Switch each keyboard to the next layout
for kb in "${KEYBOARDS[@]}"; do
    hyprctl switchxkblayout "$kb" next >/dev/null
done

# Read the active layout from the first keyboard
CURRENT_LAYOUT=$(hyprctl -j devices | jq -r '.keyboards[0].active_keymap')

notify-send -a "Hyprland" "Keyboard Layout" "$CURRENT_LAYOUT"
