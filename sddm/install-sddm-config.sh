#!/bin/bash
# Install SDDM configuration and theme
# Run this script after fresh Arch install

# Copy SDDM config
sudo cp ~/Dot-Files/sddm/sddm.conf /etc/sddm.conf

# Create themes directory if it doesn't exist
sudo mkdir -p /usr/share/sddm/themes

# Symlink or copy custom theme
# Option 1: Symlink (recommended - changes sync automatically)
sudo ln -sf ~/Dot-Files/sddm/themes/hyprlock-match /usr/share/sddm/themes/hyprlock-match

# Option 2: Copy (use this if symlinks don't work)
# sudo cp -r ~/Dot-Files/sddm/themes/hyprlock-match /usr/share/sddm/themes/

echo "SDDM configuration installed!"
echo "Theme: hyprlock-match"
echo "Restart SDDM to apply: sudo systemctl restart sddm"
