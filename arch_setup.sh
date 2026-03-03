#!/bin/bash

# Arch Linux Minimal Hyprland Install Script
# Run this after completing base Arch installation with archinstall

echo "================================"
echo "Minimal Arch + Hyprland Setup"
echo "================================"

# -----------------------------------------------
# Determine the real user (works whether run as root or via sudo)
# -----------------------------------------------
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")
echo "Running as: $USER | Real user: $REAL_USER | Home: $REAL_HOME"

# -----------------------------------------------
# Helper functions
# -----------------------------------------------

pacman_install() {
    local pkg=$1
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "[SKIP] $pkg is already installed"
    else
        echo "[INSTALL] $pkg"
        pacman -S --needed --noconfirm "$pkg"
    fi
}

# Run makepkg-based installs as the real (non-root) user
paru_install() {
    local pkg=$1
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "[SKIP] $pkg is already installed"
    else
        echo "[INSTALL] $pkg (AUR)"
        sudo -u "$REAL_USER" paru -S --needed --noconfirm "$pkg"
    fi
}

yay_install() {
    local pkg=$1
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "[SKIP] $pkg is already installed"
    else
        echo "[INSTALL] $pkg (AUR/yay)"
        sudo -u "$REAL_USER" yay -S --needed --noconfirm "$pkg"
    fi
}

flatpak_install() {
    local app_id=$1
    if flatpak list --app | grep -q "$app_id"; then
        echo "[SKIP] $app_id is already installed"
    else
        echo "[INSTALL] $app_id (Flatpak)"
        flatpak install flathub "$app_id" -y
    fi
}

# -----------------------------------------------
# Update system
# -----------------------------------------------
echo "Updating system..."
pacman -Syu --noconfirm

# -----------------------------------------------
# Install yay (AUR helper) from source
# -----------------------------------------------
echo ""
echo "Checking yay AUR helper..."
if command -v yay &>/dev/null; then
    echo "[SKIP] yay is already installed"
else
    echo "[INSTALL] yay"
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    chown -R "$REAL_USER":"$REAL_USER" yay
    cd yay
    sudo -u "$REAL_USER" makepkg -si --noconfirm
    cd ~
fi

# -----------------------------------------------
# Install paru (AUR helper) — installed early so paru_install() works below
# -----------------------------------------------
echo ""
echo "Checking paru AUR helper..."
if command -v paru &>/dev/null || pacman -Qi paru &>/dev/null; then
    echo "[SKIP] paru is already installed"
else
    echo "[INSTALL] paru"
    cd /tmp
    rm -rf paru
    git clone https://aur.archlinux.org/paru.git
    chown -R "$REAL_USER":"$REAL_USER" paru
    cd paru
    sudo -u "$REAL_USER" makepkg -si --noconfirm
    cd ~
fi

# -----------------------------------------------
# Essential packages
# -----------------------------------------------
echo ""
echo "Installing essential packages..."
pacman_install base-devel
pacman_install git
pacman_install grub
pacman_install wget
pacman_install polkit
pacman_install neovim
pacman_install thunar
pacman_install flatpak
pacman_install obsidian
pacman_install docker
pacman_install ttf-roboto
pacman_install ttf-jetbrains-mono
pacman_install rofi-wayland
pacman_install rofi-calc

# -----------------------------------------------
# Hyprland ecosystem
# -----------------------------------------------
echo ""
echo "Installing Hyprland and components..."
pacman_install hyprland
pacman_install xdg-desktop-portal-hyprland
pacman_install hyprcursor
pacman_install hyprpaper
pacman_install hypridle
pacman_install hyprlock

# -----------------------------------------------
# Terminal and shell
# -----------------------------------------------
echo ""
echo "Installing terminal and shell tools..."
pacman_install alacritty
pacman_install bash-completion
pacman_install starship

# -----------------------------------------------
# Audio
# -----------------------------------------------
echo ""
echo "Installing audio system..."
pacman_install pipewire
pacman_install pipewire-audio
pacman_install pipewire-pulse
pacman_install wireplumber
pacman_install pulsemixer
pacman_install cava

# -----------------------------------------------
# Networking
# -----------------------------------------------
echo ""
echo "Installing network tools..."
pacman_install networkmanager
pacman_install nm-connection-editor

# -----------------------------------------------
# System utilities
# -----------------------------------------------
echo ""
echo "Installing system utilities..."
pacman_install brightnessctl
pacman_install lxsession
pacman_install grim
pacman_install slurp
pacman_install python-pywal

# -----------------------------------------------
# UI components
# -----------------------------------------------
echo ""
echo "Installing UI components..."
pacman_install waybar
pacman_install mako

# -----------------------------------------------
# CLI tools
# -----------------------------------------------
echo ""
echo "Installing CLI tools..."
pacman_install btop
pacman_install lazygit
pacman_install fastfetch

# -----------------------------------------------
# Virtualization tools
# -----------------------------------------------
echo ""
echo "Installing virtualization tools..."
pacman_install libvirt
pacman_install virt-manager
pacman_install qemu-full
pacman_install dnsmasq
pacman_install dmidecode

# -----------------------------------------------
# TTY1 Autologin (so hyprlock is the only login screen)
# -----------------------------------------------
echo ""
echo "Setting up TTY1 autologin..."
if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
    echo "[SKIP] TTY1 autologin already configured"
else
    if [ -f "$REAL_HOME/Dot-Files/.config/dconf/autologin.conf" ]; then
        mkdir -p /etc/systemd/system/getty@tty1.service.d
        cp "$REAL_HOME/Dot-Files/.config/dconf/autologin.conf" /etc/systemd/system/getty@tty1.service.d/autologin.conf
        sed -i "s/logan/$REAL_USER/g" /etc/systemd/system/getty@tty1.service.d/autologin.conf
        systemctl daemon-reload
        echo "[SET] TTY1 autologin configured for $REAL_USER"
    else
        echo "[SKIP] autologin.conf not found in Dot-Files repo"
    fi
fi

# -----------------------------------------------
# Enable services
# -----------------------------------------------
echo ""
echo "Enabling essential services..."
systemctl enable NetworkManager 2>/dev/null || echo "[SKIP] NetworkManager already enabled"

echo "Enabling virtualization services..."
systemctl enable libvirtd.service 2>/dev/null || echo "[SKIP] libvirtd already enabled"
systemctl enable virtlogd.service 2>/dev/null || echo "[SKIP] virtlogd already enabled"
systemctl start libvirtd.service 2>/dev/null || echo "[SKIP] libvirtd already running"
systemctl start virtlogd.service 2>/dev/null || echo "[SKIP] virtlogd already running"

# -----------------------------------------------
# User groups
# -----------------------------------------------
echo ""
echo "Configuring user groups..."
for group in libvirt video input render; do
    if groups "$REAL_USER" | grep -qw "$group"; then
        echo "[SKIP] $REAL_USER already in $group group"
    else
        echo "[ADD] Adding $REAL_USER to $group group"
        usermod -aG "$group" "$REAL_USER"
    fi
done

# -----------------------------------------------
# Libvirt default network
# -----------------------------------------------
echo ""
echo "Configuring libvirt default network..."
virsh net-autostart default 2>/dev/null || echo "[SKIP] Default network already set to autostart"
virsh net-start default 2>/dev/null || echo "[SKIP] Default network already started"

# -----------------------------------------------
# Flatpak
# -----------------------------------------------
echo ""
echo "Setting up Flatpak..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || echo "[SKIP] Flathub already added"

flatpak_install com.discordapp.Discord
flatpak_install app.zen_browser.zen

# -----------------------------------------------
# AUR packages via paru
# -----------------------------------------------
echo ""
echo "Installing AUR packages..."
paru_install impala
paru_install bluetuith
paru_install uwsm
paru_install devpod-bin
paru_install apple-fonts
paru_install elephant
paru_install otf-codenewroman-nerd

sudo systemctl enable bluetoooth
# -----------------------------------------------
# Dotfiles setup
# -----------------------------------------------
echo ""
if [ -d "$REAL_HOME/Dot-Files" ]; then
    cd "$REAL_HOME/Dot-Files"

    echo "Installing wal for Beach BG..."
    BG_IMG="$REAL_HOME/Dot-Files/.config/assets/Beach-BG.jpg"
    if [ -f "$BG_IMG" ]; then
        if command -v wal &>/dev/null; then
            sudo -u "$REAL_USER" wal -i "$BG_IMG"
        else
            echo "[SKIP] wal not found, skipping wallpaper setup"
        fi
    else
        echo "[SKIP] Beach-BG.jpg not found at $BG_IMG"
    fi
else
    echo "[SKIP] Dot-Files directory not found at $REAL_HOME/Dot-Files"
fi

# -----------------------------------------------
# TERMINAL environment variable
# -----------------------------------------------
echo ""
echo "Setting TERMINAL environment variable..."
if grep -q "export TERMINAL" "$REAL_HOME/.bashrc"; then
    echo "[SKIP] TERMINAL already set in .bashrc"
else
    echo 'export TERMINAL=alacritty' >> "$REAL_HOME/.bashrc"
    echo "[SET] TERMINAL=alacritty added to .bashrc"
fi

if grep -q "export TERMINAL" "$REAL_HOME/.bash_profile"; then
    echo "[SKIP] TERMINAL already set in .bash_profile"
else
    echo 'export TERMINAL=alacritty' >> "$REAL_HOME/.bash_profile"
    echo "[SET] TERMINAL=alacritty added to .bash_profile"
fi

# -----------------------------------------------
# Hyprland autostart on TTY1
# -----------------------------------------------
echo ""
echo "Setting up Hyprland autostart on TTY1..."
if grep -q "uwsm start hyprland" "$REAL_HOME/.bash_profile"; then
    echo "[SKIP] Hyprland autostart already configured"
else
    cat >> "$REAL_HOME/.bash_profile" << 'EOF'

# Autostart Hyprland on TTY1
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec uwsm start hyprland.desktop
fi
EOF
    echo "[SET] Hyprland autostart added to .bash_profile"
fi

# -----------------------------------------------
# Keyboard config (kanata)
# -----------------------------------------------
echo ""
echo "Installing keyboard config..."
yay_install kanata-bin

echo "Setting up kanata systemd service..."
if systemctl is-enabled kanata.service &>/dev/null; then
    echo "[SKIP] kanata service already enabled"
else
    if [ -f "$REAL_HOME/Dot-Files/.config/kanata/kanata.service" ]; then
        cp "$REAL_HOME/Dot-Files/.config/kanata/kanata.service" /etc/systemd/system/kanata.service
        systemctl daemon-reload
        systemctl enable --now kanata.service
        echo "[SET] kanata service installed and enabled"
    else
        echo "[SKIP] kanata.service not found in Dot-Files repo"
    fi
fi

# -----------------------------------------------
# BetterDiscord
# -----------------------------------------------
echo ""
echo "Installing Better Discord and themes..."
if [ -f "$REAL_HOME/Dot-Files/install_betterdiscord.sh" ]; then
    bash "$REAL_HOME/Dot-Files/install_betterdiscord.sh"
else
    echo "[SKIP] install_betterdiscord.sh not found"
fi

# -----------------------------------------------
# Done
# -----------------------------------------------
echo ""
echo "================================"
echo "Installation complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Copy your dotfiles config files to ~/.config/"
echo "2. Configure starship: starship init bash >> ~/.bashrc"
echo "3. REBOOT to apply group membership changes"
echo "4. After reboot, Hyprland will autostart on TTY1 login"
echo ""
echo "Note: You need to reboot for group changes to take effect"
echo ""
