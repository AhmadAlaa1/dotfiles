#!/usr/bin/env bash

target="$1"

if [[ -z "$target" ]]; then
  exit 1
fi

current_workspace="$(hyprctl activeworkspace -j | jq -r '.name')"

cmds="$(
  hyprctl clients -j \
  | jq -r --arg cw "$current_workspace" --arg target "$target" '
      .[]
      | select(.workspace.name == $cw)
      | "dispatch movetoworkspacesilent \($target),address:\(.address);"
    '
)"

cmds+="dispatch workspace $target;"

hyprctl --batch "$cmds"