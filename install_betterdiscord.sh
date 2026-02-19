#!/bin/bash

# ─── Step 1: Install bun ─────────────────────────────────────────────────────
if command -v bun &> /dev/null; then
    echo ">>> bun is already installed, skipping."
else
    echo ">>> Installing bun..."
    curl -fsSL https://bun.sh/install | bash || { echo "ERROR: bun installation failed."; exit 1; }
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    echo ">>> bun installed successfully."
fi

# ─── Step 2: Install betterdiscordctl ────────────────────────────────────────
echo ">>> Installing betterdiscordctl..."
curl -O https://raw.githubusercontent.com/bb010g/betterdiscordctl/master/betterdiscordctl || { echo "ERROR: Failed to download betterdiscordctl."; exit 1; }
chmod +x betterdiscordctl
sudo mv betterdiscordctl /usr/local/bin || { echo "ERROR: Failed to install betterdiscordctl."; exit 1; }
echo ">>> betterdiscordctl installed."

# ─── Step 3: Install BetterDiscord for Flatpak Discord ───────────────────────
echo ">>> Installing BetterDiscord..."
betterdiscordctl --d-install flatpak install || { echo "ERROR: BetterDiscord installation failed."; exit 1; }

echo ""
echo "✅ BetterDiscord installed successfully!"
echo ">>> Please restart Discord: flatpak run com.discordapp.Discord"
