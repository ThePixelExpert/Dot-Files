# SDDM Configuration for Hyprlock Match

This directory contains your custom SDDM theme and configuration that matches your hyprlock appearance.

## Files Structure

```
sddm/
├── sddm.conf                    # Main SDDM config file
├── install-sddm-config.sh       # Installation script
├── themes/
│   └── hyprlock-match/          # Custom theme matching hyprlock
│       ├── Main.qml             # Theme UI (QML)
│       ├── theme.conf           # Theme config
│       ├── background.jpg       # Your Beach-BG.jpg wallpaper
│       └── ...                  # Other theme assets
```

## Installation

### Quick Test (Current System)
```bash
# Install the config and theme
~/Dot-Files/sddm/install-sddm-config.sh

# Restart SDDM to see changes
sudo systemctl restart sddm
```

### For Your Arch ISO
Include these commands in your post-install script:
```bash
# Copy SDDM config
cp ~/Dot-Files/sddm/sddm.conf /etc/sddm.conf

# Link custom theme
mkdir -p /usr/share/sddm/themes
ln -sf ~/Dot-Files/sddm/themes/hyprlock-match /usr/share/sddm/themes/hyprlock-match
```

## Customization

### Change Wallpaper
Replace `themes/hyprlock-match/background.jpg` with your desired image.

### Modify Theme Appearance
Edit `themes/hyprlock-match/Main.qml` to adjust:
- Colors
- Font sizes
- Clock position
- Input field styling

### Update Theme Config
Edit `themes/hyprlock-match/theme.conf` for simple settings like background path.

## Current Settings

- **Theme**: hyprlock-match (based on Maldives)
- **Wallpaper**: Your Beach-BG.jpg
- **Autologin**: Enabled for user 'logan'
- **Session**: hyprland-uwsm
- **Display Server**: Wayland

## Notes

- The theme is stored in your Dot-Files so it's portable
- Changes to theme files require SDDM restart: `sudo systemctl restart sddm`
- The ThemeDir points to your Dot-Files, so SDDM loads directly from there
