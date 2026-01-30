#!/usr/bin/env bash
set -e

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
	echo "❌Do not source install.h"
	return 1
fi
	

echo "🔧 Installing dotfiles..."

mkdir -p ~/.config

backup() {
	if [ -e "$1" ]; then
		mv "$1" "$1.bak.$(date +%s)"
	fi
}


backup ~/.bashrc
backup ~/.config/nvim

ln -sfn ~/dotfiles/bash/bashrc ~/.bashrc
ln -sfn ~/dotfiles/nvim ~/.config/nvim

# ---- Neovim install (AppImage) ----
if ! command -v nvim >/dev/null 2>&1; then
	echo "📦Neovim not found. Installing..."

	NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
	sudo mkdir -p /opt/nvim
	sudo curl -Lo /opt/nvim/nvim "$NVIM_URL"
	sudo chmod +x /opt/nvim/nvim

	# Add to PATH if not already present
	if ! grep -q '/opt/nvim' ~/.bashrc; then
		echo 'export PATH="$PATH:/opt/nvim"' >> ~/.bashrc
	fi

	echo "✅Neovim installed."
else
	echo "✅Neovim already installed. Skipping."
fi

# Ensure system utilities needed by Mason
echo "📦 Installing system dependencies for Mason..."
if [ -x "$(command -v apt)" ]; then
    sudo apt update
    sudo apt install -y unzip curl tar python3 python3-pip nodejs npm python3-venv xclip
elif [ -x "$(command -v pacman)" ]; then
    sudo pacman -Syu --noconfirm unzip curl tar python python-pip nodejs npm python-virtualenv xclip
elif [ -x "$(command -v dnf)" ]; then
    sudo dnf install -y unzip curl tar python3 python3-pip nodejs npm python3-venv xclip
else
    echo "⚠️ Unknown package manager. Please install unzip, curl, and tar manually."
fi

echo "✅ Done. Restart your shell."
