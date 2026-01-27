#!/bin/bash

# Dotfiles Sync Script
# This script manages dotfiles by:
# 1. Copying dotfiles to the repository
# 2. Creating symlinks from original locations to the repo
# 3. Keeping everything in sync with git

# Configuration
REPO_DIR="$HOME/Dot-Files" # Adjust this to your repo location
DOTFILES=(
  "$HOME/.bashrc"
  "$HOME/.config/nvim"
  "$HOME/.config/alacritty"
  "$HOME/.config/btop"
  "$HOME/.config/dconf"
  "$HOME/.config/fastfetch"
  "$HOME/.config/fontconfig"
  "$HOME/.config/gh"
  "$HOME/.config/ghostty"
  "$HOME/.config/git"
  "$HOME/.config/github-copilot"
  "$HOME/.config/go"
  "$HOME/.config/hypr"
  "$HOME/.config/kitty"
  "$HOME/.config/mcphub"
  "$HOME/.config/obsidian"
  "$HOME/.config/omarchy"
  "$HOME/.config/uwsm"
  "$HOME/.config/waybar"

  # Add more dotfiles/directories as needed
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Function to backup existing files
backup_file() {
  local file="$1"
  if [ -e "$file" ] && [ ! -L "$file" ]; then
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$file" "$backup"
    print_info "Backed up $file to $backup"
  fi
}

# Function to create symlink
create_symlink() {
  local target="$1"
  local link_name="$2"

  # Remove existing symlink or backup file
  if [ -L "$link_name" ]; then
    rm "$link_name"
    print_info "Removed existing symlink: $link_name"
  elif [ -e "$link_name" ]; then
    backup_file "$link_name"
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$link_name")"

  # Create symlink path/to/link path/to/targert
  ln -s "$target" "$link_name"
  print_info "Created symlink: $link_name -> $target"
}

# Function to sync dotfiles to repo
sync_to_repo() {
  print_info "Syncing dotfiles to repository..."

  for dotfile in "${DOTFILES[@]}"; do
    if [ ! -e "$dotfile" ]; then
      print_warning "Skipping $dotfile (doesn't exist)"
      continue
    fi

    # Get relative path from home
    rel_path="${dotfile#$HOME/}"
    repo_path="$REPO_DIR/$rel_path"

    # Create parent directory in repo
    mkdir -p "$(dirname "$repo_path")"

    # Check if it's already a symlink pointing to repo
    if [ -L "$dotfile" ] && [ "$(readlink -f "$dotfile")" = "$(readlink -f "$repo_path")" ]; then
      print_info "Already synced: $dotfile"
      continue
    fi

    # Copy to repo if not already there or if different
    if [ ! -e "$repo_path" ] || ! diff -q "$dotfile" "$repo_path" >/dev/null 2>&1; then
      if [ -d "$dotfile" ]; then
        cp -r "$dotfile" "$repo_path"
        print_info "Copied directory: $dotfile -> $repo_path"
      else
        cp "$dotfile" "$repo_path"
        print_info "Copied file: $dotfile -> $repo_path"
      fi
    fi

    # Create symlink
    create_symlink "$repo_path" "$dotfile"
  done
}

# Function to restore dotfiles from repo
restore_from_repo() {
  print_info "Restoring dotfiles from repository..."

  cd "$REPO_DIR" || exit 1

  # Find all files in repo (excluding .git)
  find . -type f -not -path '*/.git/*' -not -name 'sync-dotfiles.sh' -not -name 'README.md' -not -name '.gitignore' | while read -r file; do
    # Remove leading ./
    file="${file#./}"

    # Target location in home directory
    target="$HOME/$file"
    repo_file="$REPO_DIR/$file"

    # Create symlink
    create_symlink "$repo_file" "$target"
  done
}

# Function to commit and push changes
commit_changes() {
  print_info "Committing changes to git..."

  cd "$REPO_DIR" || exit 1

  # Check if there are changes
  if [[ -z $(git status -s) ]]; then
    print_info "No changes to commit"
    return
  fi

  git add .
  git commit -m "Update dotfiles - $(date '+%Y-%m-%d %H:%M:%S')"

  read -p "Push changes to GitHub? (y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push
    print_info "Changes pushed to GitHub"
  fi
}

# Function to pull latest changes
pull_changes() {
  print_info "Pulling latest changes from GitHub..."

  cd "$REPO_DIR" || exit 1
  git pull

  print_info "Latest changes pulled"
}

# Main menu
show_menu() {
  echo ""
  echo "===== Dotfiles Manager ====="
  echo "1. Sync dotfiles to repo (copy files and create symlinks)"
  echo "2. Restore dotfiles from repo (create symlinks only)"
  echo "3. Commit and push changes"
  echo "4. Pull latest changes"
  echo "5. Exit"
  echo "============================"
  echo ""
}

# Main script
main() {
  # Check if repo directory exists
  if [ ! -d "$REPO_DIR" ]; then
    print_error "Repository directory not found: $REPO_DIR"
    print_info "Please update REPO_DIR variable in this script"
    exit 1
  fi

  # Check if it's a git repo
  if [ ! -d "$REPO_DIR/.git" ]; then
    print_error "Not a git repository: $REPO_DIR"
    print_info "Initialize git first: cd $REPO_DIR && git init"
    exit 1
  fi

  # If arguments provided, run non-interactively
  case "$1" in
  sync)
    sync_to_repo
    commit_changes
    ;;
  restore)
    restore_from_repo
    ;;
  push)
    commit_changes
    ;;
  pull)
    pull_changes
    ;;
  *)
    # Interactive mode
    while true; do
      show_menu
      read -p "Select an option: " choice
      case $choice in
      1)
        sync_to_repo
        ;;
      2)
        restore_from_repo
        ;;
      3)
        commit_changes
        ;;
      4)
        pull_changes
        ;;
      5)
        print_info "Goodbye!"
        exit 0
        ;;
      *)
        print_error "Invalid option"
        ;;
      esac
    done
    ;;
  esac
}

main "$@"
