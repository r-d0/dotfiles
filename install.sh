#!/usr/bin/env bash
set -e

echo "🔧 Installing dotfiles..."

mkdir -p ~/.config

backup () {
  [ -e "$1" ] && mv "$1" "$1.bak"
}

backup ~/.bashrc
backup ~/.config/nvim

ln -sfn ~/dotfiles/bash/bashrc ~/.bashrc
ln -sfn ~/dotfiles/nvim ~/.config/nvim

echo "✅ Done. Restart your shell."
