#!/usr/bin/env bash
set -e

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    echo "❌ Do not source install.sh"
    return 1
fi

# -------------------------
# Privilege handling
# -------------------------
SUDO=""

if [[ "$EUID" -eq 0 ]]; then
    SUDO=""
elif command -v sudo >/dev/null 2>&1; then
    echo "🔐 This installer requires sudo access."
    echo "   Please enter your password to continue."

    if sudo -v; then
        SUDO="sudo"
    else
        cat <<'EOF'
❌ Failed to obtain sudo access.

This usually means:
  • Your user is not allowed to use sudo
  • You are on a shared / university / restricted system

Please run this installer:
  • As root, or
  • On a machine where you have sudo access, or
  • After an administrator grants you sudo privileges

Aborting to avoid a partial installation.
EOF
        exit 1
    fi
else
    # No sudo installed (e.g. Termux)
    SUDO=""
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

# -------------------------
# Neovim install
# -------------------------
if ! command -v nvim >/dev/null 2>&1; then
    echo "📦 Neovim not found. Installing..."

    if command -v pkg >/dev/null 2>&1; then
        # Termux
        pkg install -y neovim
    else
        NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
        $SUDO mkdir -p /opt/nvim
        $SUDO curl -Lo /opt/nvim/nvim "$NVIM_URL"
        $SUDO chmod +x /opt/nvim/nvim

        if ! grep -q '/opt/nvim' ~/.bashrc; then
            echo 'export PATH="$PATH:/opt/nvim"' >> ~/.bashrc
        fi
    fi

    echo "✅ Neovim installed."
else
    echo "✅ Neovim already installed. Skipping."
fi

# -------------------------
# System dependencies
# -------------------------
echo "📦 Installing system dependencies for Mason..."

if command -v pkg >/dev/null 2>&1; then
    pkg install -y unzip curl tar python nodejs
elif command -v apt >/dev/null 2>&1; then
    $SUDO apt update
    $SUDO apt install -y unzip curl tar python3 python3-pip nodejs npm python3-venv xclip
elif command -v pacman >/dev/null 2>&1; then
    $SUDO pacman -Syu --noconfirm unzip curl tar python python-pip nodejs npm python-virtualenv xclip
elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y unzip curl tar python3 python3-pip nodejs npm python3-venv xclip
else
    echo "⚠️ Unknown package manager. Install dependencies manually."
fi

echo "✅ Done. Restart your shell."
