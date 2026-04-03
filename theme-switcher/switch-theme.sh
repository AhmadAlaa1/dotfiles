#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/.config/theme-switcher"
THEMES_DIR="$BASE/themes"

HYPR_THEME_DIR="$HOME/.config/hypr/themes"
WAYBAR_DIR="$HOME/.config/waybar"
KITTY_DIR="$HOME/.config/kitty"
ROFI_DIR="$HOME/.config/rofi"
FASTFETCH_DIR="$HOME/.config/fastfetch"
SWAYNC_DIR="$HOME/.config/swaync"
GTK3_DIR="$HOME/.config/gtk-3.0"
GTK4_DIR="$HOME/.config/gtk-4.0"
HYPRLOCK_DIR="$HOME/.config/hypr"
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
ROFI_THEME="$ROFI_DIR/current-theme.rasi"

mkdir -p \
  "$HYPR_THEME_DIR" \
  "$WAYBAR_DIR" \
  "$KITTY_DIR" \
  "$ROFI_DIR" \
  "$FASTFETCH_DIR" \
  "$SWAYNC_DIR" \
  "$GTK3_DIR" \
  "$GTK4_DIR"

mapfile -t themes < <(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)

if [ ${#themes[@]} -eq 0 ]; then
    notify-send "Theme Switcher" "No themes found in $THEMES_DIR"
    exit 1
fi

if [ -f "$ROFI_THEME" ]; then
    selected=$(printf '%s\n' "${themes[@]}" | rofi -dmenu -i -p "Select theme" -theme "$ROFI_THEME")
else
    selected=$(printf '%s\n' "${themes[@]}" | rofi -dmenu -i -p "Select theme")
fi

[ -z "${selected:-}" ] && exit 0

src="$THEMES_DIR/$selected"

if [ ! -d "$src" ]; then
    notify-send "Theme Switcher" "Theme not found: $selected"
    exit 1
fi

link_if_exists() {
    local source_file="$1"
    local target_file="$2"

    if [ -f "$source_file" ]; then
        ln -sfn "$source_file" "$target_file"
    fi
}

find_theme_dir() {
    local theme_name="$1"
    local candidate

    for candidate in \
        "$HOME/.themes/$theme_name" \
        "$HOME/.local/share/themes/$theme_name" \
        "/usr/share/themes/$theme_name"
    do
        if [ -d "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

sync_gtk4_theme_files() {
    local theme_name="$1"
    local theme_dir=""
    local src4=""

    if ! theme_dir=$(find_theme_dir "$theme_name"); then
        return 0
    fi

    src4="$theme_dir/gtk-4.0"

    if [ ! -d "$src4" ]; then
        return 0
    fi

    rm -f "$GTK4_DIR/gtk.css" "$GTK4_DIR/gtk-dark.css"
    rm -rf "$GTK4_DIR/assets"

    [ -f "$src4/gtk.css" ] && ln -sfn "$src4/gtk.css" "$GTK4_DIR/gtk.css"
    [ -f "$src4/gtk-dark.css" ] && ln -sfn "$src4/gtk-dark.css" "$GTK4_DIR/gtk-dark.css"
    [ -d "$src4/assets" ] && ln -sfn "$src4/assets" "$GTK4_DIR/assets"
}

link_if_exists "$src/hyprland.conf"   "$HYPR_THEME_DIR/current.conf"
link_if_exists "$src/waybar.css"      "$WAYBAR_DIR/style.css"
link_if_exists "$src/kitty.conf"      "$KITTY_DIR/current-theme.conf"
link_if_exists "$src/rofi.rasi"       "$ROFI_DIR/current-theme.rasi"
link_if_exists "$src/fastfetch.jsonc" "$FASTFETCH_DIR/config.jsonc"
link_if_exists "$src/swaync.css"      "$SWAYNC_DIR/style.css"
link_if_exists "$src/hyprlock.conf" "$HYPRLOCK_DIR/hyprlock.conf"

wallpaper=""
if [ -f "$src/wallpaper.jpg" ]; then
    wallpaper="$src/wallpaper.jpg"
elif [ -f "$src/wallpaper.png" ]; then
    wallpaper="$src/wallpaper.png"
elif [ -f "$src/wallpaper.jpeg" ]; then
    wallpaper="$src/wallpaper.jpeg"
fi

if [ -n "$wallpaper" ] && command -v swww >/dev/null 2>&1; then
    swww img "$wallpaper" \
      --transition-type grow \
      --transition-fps 120
fi

hyprctl reload >/dev/null 2>&1 || true

pkill waybar 2>/dev/null || true
sleep 0.2
nohup waybar >/tmp/theme-switcher-waybar.log 2>&1 &

if pidof kitty >/dev/null 2>&1; then
    pkill -SIGUSR1 kitty 2>/dev/null || true
fi

case "$selected" in
    "Catppuccin Mocha")
        VSCODE_THEME="Catppuccin Mocha"
        VSCODE_ICON_THEME="catppuccin-mocha"
        GTK_THEME="Catppuccin-B-MB-Dark"
        ICON_THEME="oomox-Catppuccin-Mocha"
        ;;
    gruvbox)
        VSCODE_THEME="Gruvbox Dark Hard"
        VSCODE_ICON_THEME="material-icon-theme"
        GTK_THEME="Gruvbox-B-MB-Dark"
        ICON_THEME="Gruvbox-Plus-Dark"
        ;;
    *)
        VSCODE_THEME="Default Dark Modern"
        VSCODE_ICON_THEME="vs-seti"
        GTK_THEME=""
        ICON_THEME=""
        ;;
esac

if [ -f "$VSCODE_SETTINGS" ]; then
    jq empty "$VSCODE_SETTINGS" >/dev/null 2>&1 || {
        notify-send "Theme Switcher" "VS Code settings.json is invalid JSON"
        exit 1
    }

    jq --arg theme "$VSCODE_THEME" \
       --arg iconTheme "$VSCODE_ICON_THEME" \
       '.["workbench.colorTheme"] = $theme |
        .["workbench.preferredDarkColorTheme"] = $theme |
        .["workbench.iconTheme"] = $iconTheme' \
       "$VSCODE_SETTINGS" > "$VSCODE_SETTINGS.tmp" && mv "$VSCODE_SETTINGS.tmp" "$VSCODE_SETTINGS"

    CURRENT_VSCODE_THEME=$(jq -r '.["workbench.colorTheme"]' "$VSCODE_SETTINGS")
    CURRENT_VSCODE_ICON_THEME=$(jq -r '.["workbench.iconTheme"]' "$VSCODE_SETTINGS")
else
    CURRENT_VSCODE_THEME="settings file not found"
    CURRENT_VSCODE_ICON_THEME="settings file not found"
fi

if [ -n "${GTK_THEME:-}" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
fi

if [ -n "${ICON_THEME:-}" ]; then
    gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
fi

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

cat > "$GTK3_DIR/settings.ini" <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=Adwaita Sans 11
gtk-cursor-theme-name=macOS
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF

cat > "$GTK4_DIR/settings.ini" <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=Adwaita Sans 11
gtk-cursor-theme-name=macOS
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

if [ -n "${GTK_THEME:-}" ]; then
    sync_gtk4_theme_files "$GTK_THEME"
fi

sleep 1.0

CURRENT_GTK_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme)
CURRENT_ICON_THEME=$(gsettings get org.gnome.desktop.interface icon-theme)

pkill swaync 2>/dev/null || true
sleep 0.3
nohup swaync >/dev/null 2>&1 &

pkill -x swayosd-server 2>/dev/null || true
sleep 0.5
nohup swayosd-server >/tmp/swayosd.log 2>&1 &

notify-send "Theme Switcher" "Applied: $selected
VS Code Theme: $CURRENT_VSCODE_THEME
VS Code Icons: $CURRENT_VSCODE_ICON_THEME
GTK: $CURRENT_GTK_THEME
Icons: $CURRENT_ICON_THEME"