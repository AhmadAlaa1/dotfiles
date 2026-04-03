# My Dotfiles

A modern Linux rice setup built with **Hyprland**, designed for speed, aesthetics, and full theme consistency across the system.

---

## ✨ Features

* 🎨 Dynamic theme switching (Gruvbox / Catppuccin)
* 🧩 Fully synchronized setup:

  * Hyprland
  * Waybar
  * Kitty
  * Rofi
  * SwayNC (notifications)
  * SwayOSD (volume/brightness)
  * Wlogout
  * Fastfetch
* ⚡ Smooth animations & transitions
* 🖥️ Clean and minimal UI
* 🔁 One-command setup

---

## 📸 Preview

> Add screenshots here later 🔥

---

## 📁 Structure

```
dotfiles/
├── hypr/
├── waybar/
├── kitty/
├── rofi/
├── swaync/
├── fastfetch/
├── wlogout/
├── theme-switcher/
└── scripts/
```

---

## 🚀 Installation

### 1. Clone the repo

```bash
git clone https://github.com/AhmadAlaa1/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Apply configs

```bash
./scripts/install.sh
```

---

## 🎨 Theme Switching

Use the built-in theme switcher:

```bash
~/.config/theme-switcher/switch-theme.sh
```

---

## 📦 Dependencies

Install required packages (example for Fedora):

```bash
sudo dnf install hyprland waybar kitty rofi swaync fastfetch wlogout nwg-look
```

---

## ⚠️ Notes

* GTK themes and icon packs must be installed manually:

  * Catppuccin GTK
  * Gruvbox GTK
  * Papirus Icons / Gruvbox Plus Icons
* Some configs may require adjustment depending on your system (monitor names, GPU, etc.)

---

## 🛠️ Customization

Feel free to:

* modify themes inside `theme-switcher/themes/`
* adjust colors and animations
* extend the switcher script

---

## 💡 Inspiration

Built with love for:

* clean UI
* smooth UX
* full system consistency

---

## 📌 TODO

* [ ] Add screenshots
* [ ] Add auto package installer script
* [ ] Improve theme variants
* [ ] Add more layouts

---

## ⭐ Support

If you like this setup, consider giving it a ⭐ on GitHub!

---

## 👤 Author

**Ahmad Alaa**
GitHub: https://github.com/AhmadAlaa1
