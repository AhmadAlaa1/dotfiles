#!/bin/bash

if pgrep -x hypridle > /dev/null; then
    pkill hypridle
    notify-send "Idle Disabled" "Screen will stay ON"
else
    hypridle &
    notify-send "Idle Enabled" "Auto lock/suspend active"
fi
