#!/bin/bash

if pgrep -x hypridle >/dev/null; then
    pkill hypridle
    notify-send -t 3000 "Keep Awake: ON" "Idle actions disabled"
else
    hypridle &
    disown
    notify-send -t 3000 "Keep Awake: OFF" "Idle actions restored"
fi
