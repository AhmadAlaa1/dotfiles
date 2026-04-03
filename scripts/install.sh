#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
CONFIG_DIR="$HOME/.config"

backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

configs=(
  hypr
  waybar
  kitty
  rofi
  swaync
  fastfetch
  wlogout
  theme-switcher
  gtk-3.0
  gtk-4.0
)

echo "Using dotfiles from: $DOTFILES_DIR"
echo "Backup folder: $backup_dir"
echo

mkdir -p "$CONFIG_DIR"
mkdir -p "$backup_dir"

backup_and_link() {
  local name="$1"
  local src="$DOTFILES_DIR/$name"
  local dest="$CONFIG_DIR/$name"

  if [ ! -e "$src" ]; then
    echo "Skipping $name (not found in repo)"
    return
  fi

  if [ -L "$dest" ]; then
    rm -f "$dest"
  elif [ -e "$dest" ]; then
    echo "Backing up existing $dest -> $backup_dir/$name"
    mv "$dest" "$backup_dir/$name"
  fi

  ln -sfn "$src" "$dest"
  echo "Linked $dest -> $src"
}

for cfg in "${configs[@]}"; do
  backup_and_link "$cfg"
done

mkdir -p "$CONFIG_DIR/hypr"

# Optional: if you keep these inside your repo later, they will be linked automatically
if [ -f "$DOTFILES_DIR/hypr/hyprlock.conf" ]; then
  ln -sfn "$DOTFILES_DIR/hypr/hyprlock.conf" "$CONFIG_DIR/hypr/hyprlock.conf"
  echo "Linked hyprlock.conf"
fi

if [ -f "$DOTFILES_DIR/hypr/hypridle.conf" ]; then
  ln -sfn "$DOTFILES_DIR/hypr/hypridle.conf" "$CONFIG_DIR/hypr/hypridle.conf"
  echo "Linked hypridle.conf"
fi

echo
echo "Done."
echo "Backups saved in: $backup_dir"
echo
echo "Next steps:"
echo "1. Make sure required packages are installed."
echo "2. Make sure GTK themes/icons used by your config are installed."
echo "3. Run your theme switcher if needed:"
echo "   ~/.config/theme-switcher/switch-theme.sh"