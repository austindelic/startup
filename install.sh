#!/bin/bash
set -e
# This script installs Homebrew
sudo apt update
sudo apt upgrade
sudo apt-get install build-essential procps curl file git
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

BREWFILE="Brewfile"
if [ -f "$BREWFILE" ]; then
  echo "Installing packages from $BREWFILE..."
  brew bundle --file="$BREWFILE"
else
  echo "No Brewfile found. Skipping package installation."
fi

nvim --headless "+Lazy! sync" +qa

echo "Done!"
