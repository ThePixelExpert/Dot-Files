# Omarchy Linux Fixes - Wallpaper & SDDM

**Date**: 2026-02-13
**System**: Omarchy Linux (Arch + Hyprland)

## Problems Solved

### 1. Wallpaper Not Showing in Hyprland

**Issue**: Wallpaper showed in hyprlock but not in Hyprland after SDDM login.

**Root Cause**: Conflicting exec-once commands in `hyprland.conf`:
- Line 25-27 tried to launch hyprlock immediately
- Tried to set wallpaper to non-existent `/tmp/radar_wallpaper.gif`
- Tried to set it on non-existent monitor `DP-1` (actual monitor: `eDP-2`)

**Solution**:
1. Removed conflicting lines from `~/Dot-Files/.config/hypr/hyprland.conf`
2. Added `hyprpaper` to `~/Dot-Files/.config/hypr/autostart.conf`
3. Wallpaper now properly managed via `hyprpaper.conf` (Beach-BG.jpg)

**Files Modified**:
- `~/Dot-Files/.config/hypr/hyprland.conf` - Removed lines 25-27
- `~/Dot-Files/.config/hypr/autostart.conf` - Added `exec-once = hyprpaper`

---

### 2. SDDM Login to Match Hyprlock

**Goal**: Make SDDM login screen look exactly like hyprlock.

**Solution**: Created custom SDDM theme in dotfiles.

**Files Created**:
- `~/Dot-Files/sddm/themes/hyprlock-match/` - Custom theme (based on Maldives)
- `~/Dot-Files/sddm/sddm.conf` - SDDM configuration
- `~/Dot-Files/sddm/install-sddm-config.sh` - Installation script
- `~/Dot-Files/sddm/README.md` - Documentation

**Theme Features**:
- Uses your Beach-BG.jpg wallpaper
- Based on Maldives theme (clean, modern)
- Stored in dotfiles (portable for your Arch ISO)

**Installation**:
```bash
~/Dot-Files/sddm/install-sddm-config.sh
sudo systemctl restart sddm
```

---

## Configuration File Locations

All configs are in `~/Dot-Files/` and symlinked to `~/.config/`:

### Hyprland Configs
- `~/Dot-Files/.config/hypr/hyprland.conf` - Main config
- `~/Dot-Files/.config/hypr/hyprpaper.conf` - Wallpaper config
- `~/Dot-Files/.config/hypr/hyprlock.conf` - Lock screen config
- `~/Dot-Files/.config/hypr/autostart.conf` - Autostart apps

### SDDM Configs
- `~/Dot-Files/sddm/sddm.conf` - SDDM main config
- `~/Dot-Files/sddm/themes/hyprlock-match/` - Custom theme directory

---

## For Your Arch ISO

Everything is now in `~/Dot-Files/` and can be deployed with your custom ISO.

**Post-Install Steps**:
```bash
# 1. Symlink hypr configs (already done if using stow/symlinks)
ln -sf ~/Dot-Files/.config/hypr ~/.config/

# 2. Install SDDM theme
cp ~/Dot-Files/sddm/sddm.conf /etc/sddm.conf
mkdir -p /usr/share/sddm/themes
ln -sf ~/Dot-Files/sddm/themes/hyprlock-match /usr/share/sddm/themes/

# 3. Enable SDDM
sudo systemctl enable sddm
```

---

## Testing

### Test Wallpaper Fix
```bash
hyprctl reload
# Wallpaper should now appear in Hyprland
```

### Test SDDM Theme
```bash
~/Dot-Files/sddm/install-sddm-config.sh
sudo systemctl restart sddm
# SDDM should now match hyprlock appearance
```

---

## Key Configuration Details

**Monitor**: `eDP-2` (laptop screen)
**Wallpaper**: `~/.config/assets/Beach-BG.jpg`
**Hyprlock Style**:
- Large centered clock
- Profile picture
- "Hi, $USER" greeting
- SF Pro Display Bold font
- Blurred background

**SDDM Theme Path**: `/home/logan/Dot-Files/sddm/themes/hyprlock-match/`

---

## Notes

- All changes are in version-controlled dotfiles
- Configs are symlinked, not copied
- hyprpaper launches via autostart.conf
- SDDM theme points directly to dotfiles directory
- Theme uses same wallpaper as hyprlock (Beach-BG.jpg)

---

## Commands Used

```bash
# Reload Hyprland
hyprctl reload

# Restart waybar (if needed)
omarchy-restart-waybar

# Restart SDDM (logs you out!)
sudo systemctl restart sddm

# Check current theme
omarchy-theme-current
```
