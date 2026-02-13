#!/bin/bash

# Arch Linux Minimal Hyprland Install Script
# Run this after completing base Arch installation with archinstall

echo "================================"
echo "Minimal Arch + Hyprland Setup"
echo "================================"

# Update system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install essential packages
echo "Installing essential packages..."
sudo pacman -S --needed --noconfirm \
    base-devel \
    git \
    grub \
    polkit \
    neovim \
    thunar \
    flatpak

# Install Hyprland ecosystem
echo "Installing Hyprland and components..."
sudo pacman -S --needed --noconfirm \
    hyprland \
    xdg-desktop-portal-hyprland \
    hyprcursor \
    hyprpaper \
    hypridle \
    hyprlock

# Install terminal and shell
echo "Installing terminal and shell tools..."
sudo pacman -S --needed --noconfirm \
    alacritty \
    bash-completion \
    starship

# Install audio
echo "Installing audio system..."
sudo pacman -S --needed --noconfirm \
    pipewire \
    pipewire-audio \
    pipewire-pulse \
    wireplumber

# Install networking
echo "Installing network tools..."
sudo pacman -S --needed --noconfirm \
    networkmanager \
    nm-connection-editor

# Install system utilities
echo "Installing system utilities..."
sudo pacman -S --needed --noconfirm \
    brightnessctl \
    lxsession \
    grim \
    slurp \
    python-pywal

# Install UI components
echo "Installing UI components..."
sudo pacman -S --needed --noconfirm \
    waybar \
    mako

# Install CLI tools
echo "Installing CLI tools..."
sudo pacman -S --needed --noconfirm \
    btop \
    lazygit \
    fastfetch

# Install virtualization tools
echo "Installing virtualization tools..."
sudo pacman -S --needed --noconfirm \
    libvirt \
    virt-manager \
    qemu-full \
    dnsmasq \
    dmidecode

# Enable services (skip if already enabled)
echo "Enabling essential services..."
sudo systemctl enable NetworkManager 2>/dev/null || echo "NetworkManager already enabled"

# Enable and start virtualization services
echo "Enabling virtualization services..."
sudo systemctl enable libvirtd.service 2>/dev/null || echo "libvirtd already enabled"
sudo systemctl enable virtlogd.service 2>/dev/null || echo "virtlogd already enabled"
sudo systemctl start libvirtd.service 2>/dev/null || echo "libvirtd already running"
sudo systemctl start virtlogd.service 2>/dev/null || echo "virtlogd already running"

# Add user to libvirt group (skip if already in group)
echo "Adding user to libvirt group..."
if groups $USER | grep -q '\blibvirt\b'; then
    echo "User already in libvirt group"
else
    sudo usermod -aG libvirt $USER
fi

# Configure default network
echo "Configuring libvirt default network..."
sudo virsh net-autostart default 2>/dev/null || echo "Default network already set to autostart"
sudo virsh net-start default 2>/dev/null || echo "Default network already started"

# Setup Flatpak
echo "Setting up Flatpak..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || echo "Flathub already added"

# Install AUR helper (paru)
echo "Installing AUR helper (paru)..."
if ! command -v paru &> /dev/null; then
    cd /tmp
    sudo rm -rf paru  # Clean up any existing directory
    git clone https://aur.archlinux.org/paru.git
    sudo chmod -R 755 paru
    cd paru
    makepkg -si --noconfirm
    cd ~
else
    echo "paru already installed, skipping..."
fi

# Install AUR packages
echo "Installing AUR packages..."
paru -S --needed --noconfirm \
    impala \
    walker \
    bluetuith \
    uwsm \
    devpod-bin

echo ""
echo "================================"
echo "Installation complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Copy your omarchy config files to ~/.config/"
echo "2. Install Zen browser: flatpak install flathub io.github.zen_browser.zen"
echo "3. Configure starship: starship init bash >> ~/.bashrc"
echo "4. REBOOT to apply libvirt group membership"
echo "5. After reboot, start Hyprland with: uwsm start hyprland.desktop"
echo "   (or just 'Hyprland' if not using uwsm)"
echo ""
echo "Note: Discord will be accessed through Zen browser"
echo "Note: You need to reboot for libvirt group changes to take effect"
echo ""
