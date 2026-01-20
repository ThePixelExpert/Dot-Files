# Dot-Files

My personal dotfiles configuration, managed with symbolic links.

## Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/ThePixelExpert/Dot-Files.git ~/Dot-Files
   ```

2. Make the sync script executable:
   ```bash
   chmod +x ~/Dot-Files/sync-dotfiles.sh
   ```

3. Edit the script to add your dotfiles:
   - Open `sync-dotfiles.sh`
   - Modify the `DOTFILES` array to include your configuration files

4. Run the initial sync:
   ```bash
   ~/Dot-Files/sync-dotfiles.sh sync
   ```

## Usage

### Interactive Mode
```bash
~/Dot-Files/sync-dotfiles.sh
```

### Command Line Mode
```bash
# Sync dotfiles and commit
~/Dot-Files/sync-dotfiles.sh sync

# Restore dotfiles (create symlinks only)
~/Dot-Files/sync-dotfiles.sh restore

# Commit and push changes
~/Dot-Files/sync-dotfiles.sh push

# Pull latest changes
~/Dot-Files/sync-dotfiles.sh pull
```

## How It Works

1. **Sync**: Copies your dotfiles to the repository and creates symlinks from original locations to the repo
2. **Restore**: Creates symlinks from dotfiles in the repo to their expected locations
3. **Symlinks**: Any changes to files in either location are reflected in both (they're the same file)

## Adding More Dotfiles

Edit the `DOTFILES` array in `sync-dotfiles.sh`:

```bash
DOTFILES=(
    "$HOME/.bashrc"
    "$HOME/.config/nvim"
    # Add more here...
)
```

## Automation

Add to your `.bashrc` or `.zshrc` to auto-commit changes:

```bash
alias dotfiles-sync='~/Dot-Files/sync-dotfiles.sh sync'
```