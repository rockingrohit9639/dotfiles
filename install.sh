#!/bin/bash

# Exit immediately if any command fails
set -e

os=$(uname -s)

exit_with_error() {
    echo "Error: $1"
    exit 1
}

# Function to install a package if it's not already installed
install_package() {
    if ! dpkg -l | grep -q "$1"; then
        echo "Installing $1..."
        sudo apt-get install -y "$1"
    else
        echo "$1 is already installed."
    fi
}


# This script is created only for Linux OS
if [ "$os" != "Linux" ]; then
    exit_with_error "You are not running linux."
fi

# Update and upgrade system packages
echo "Updating and upgrading system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Packages to install
PACKAGES=(
  curl
  git
  tmux
  zsh
  rsync
  stow
  neovim
)

# Installing all the packages in the list
for package in "${PACKAGES[@]}"; do
  install_package package
done

# Installing starship 
curl -sS https://starship.rs/install.sh | sh

# Install NVM (Node Package Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Clone dotfiles repo
DOTFILES_DIRECTORY="$HOME/dotfiles"
echo "Cloning dotfiles into $DOTFILES_DIRECTORY..."

if [ ! -d "$DOTFILES_DIRECTORY" ]; then
  git clone git@github.com:rockingrohit9639/dotfiles.git "$DOTFILES_DIRECTORY"
else
  echo "dotfiles already exists."
fi

# Apply kitty config 
stow --target="$HOME" kitty

# Apply nvim config
stow --target="$HOME" nvim

# Apply starship config
stow --target="$HOME" starship

# Apply zsh config
stow --target="$HOME" zsh


# Set Zsh as default shell 
if [ "$SHELL" != "/bin/zsh" ]; then
    chsh -s /bin/zsh
    echo "Default shell changed to Zsh. Restart your terminal."
fi

