#!/bin/bash
set -e
# This script installs Homebrew
sudo apt update
sudo apt upgrade
sudo apt-get install build-essential procps curl file git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
cd "$HOME"
if [ -d startup/.git ]; then
  echo "↻ Updating ~/startup…"
  git -C startup pull --ff-only
else
  echo "➡️ Cloning ~/startup…"
  git clone https://github.com/austindelic/startup.git
fi
cd startup
echo >>/home/austin/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>/home/austin/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
TARGET_DIR="$HOME/.config"

# Make sure the config folder exists
if [ ! -d "$CONFIG_DIR" ]; then
  echo "Error: '$CONFIG_DIR' does not exist."
  exit 1
fi

echo "Linking config files to $TARGET_DIR"

# Create ~/.config if it doesn't exist
mkdir -p "$TARGET_DIR"

# Loop through all files and folders in ./config and link them
for item in "$CONFIG_DIR"/*; do
  name=$(basename "$item")
  target="$TARGET_DIR/$name"

  # Backup if something already exists
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up existing $target to $target.backup"
    mv "$target" "$target.backup"
  fi

  # Remove existing symlink if any
  [ -L "$target" ] && rm "$target"

  # Create symlink
  ln -s "$item" "$target"
  echo "Linked $item → $target"
done
echo ".config/ symlinks done."
DOT_FILES_DIR="$SCRIPT_DIR/dotfiles"
TARGET_DIR="$HOME"

# Make sure the config folder exists
if [ ! -d "$DOT_FILES_DIR" ]; then
  echo "Error: '$DOT_FILES_DIR' does not exist."
  exit 1
fi

echo "Linking dotfiles to $TARGET_DIR"

# Create ~/.config if it doesn't exist

# Loop through all files and folders in ./config and link them

shopt -s dotglob nullglob
for item in "$DOT_FILES_DIR"/*; do
  name=$(basename "$item")
  target="$TARGET_DIR/$name"

  # Backup if something already exists
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up existing $target to $target.backup"
    mv "$target" "$target.backup"
  fi

  # Remove existing symlink if any
  [ -L "$target" ] && rm "$target"

  # Create symlink
  ln -s "$item" "$target"
  echo "Linked $item → $target"
done
shopt -u dotglob
echo "Dotfiles done."
BREWFILE="./dotfiles/.Brewfile"
if [ -f "$BREWFILE" ]; then
  echo "Installing packages from $BREWFILE..."
  brew bundle --global -v
else
  echo "No Brewfile found. Skipping package installation."
fi
echo "brew done."
nvim --headless "+Lazy! sync" +qa
sudo sh -c 'echo /home/linuxbrew/.linuxbrew/bin/fish >> /etc/shells'
chsh -s $(which fish)

gh auth login
git config --global user.email "austin@austindelic.com"
git config --global user.name "Austin Delic"
echo "Done!"
