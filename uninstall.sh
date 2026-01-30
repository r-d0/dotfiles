#!/usr/bin/env bash
set -e

echo "🧹 Interactive Uninstall Script"
echo "This will allow you to uninstall packages and clean up dotfiles, Neovim, and Mason."
echo

# -------------------------
# Helper function
# -------------------------
confirm() {
    # $1 = message
    while true; do
        read -rp "$1 [y/n]: " yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# -------------------------
# Remove dotfiles and backups
# -------------------------
echo
echo "📂 Dotfiles and backups"

if [ -L ~/.bashrc ]; then
    confirm "Remove symlink ~/.bashrc?" && rm ~/.bashrc
fi
if [ -f ~/.bashrc.bak ]; then
    confirm "Restore backup ~/.bashrc.bak?" && mv ~/.bashrc.bak ~/.bashrc
fi

if [ -L ~/.config/nvim ]; then
    confirm "Remove symlink ~/.config/nvim?" && rm -rf ~/.config/nvim
fi
if [ -d ~/.config/nvim.bak ]; then
   confirm "Restore backup ~/.config/nvim.bak?" && mv ~/.config/nvim.bak ~/.config/nvim
fi

# -------------------------
# Remove Neovim AppImage
# -------------------------
echo
echo "📦 Neovim"

if [ -f /opt/nvim/nvim ]; then
    confirm "Remove /opt/nvim/nvim AppImage?" && sudo rm -f /opt/nvim/nvim
fi

if [ -d /opt/nvim ]; then
    confirm "Remove /opt/nvim directory?" && sudo rmdir /opt/nvim 2>/dev/null || true
fi

if grep -q '/opt/nvim' ~/.bashrc; then
    confirm "Remove /opt/nvim from PATH in ~/.bashrc?" && sed -i '/\/opt\/nvim/d' ~/.bashrc
fi

# -------------------------
# Remove Mason
# -------------------------
echo
echo "📦 Mason"

if [ -d ~/.local/share/nvim/mason ]; then
    confirm "Remove Mason folder (~/.local/share/nvim/mason)?" && rm -rf ~/.local/share/nvim/mason
fi

# -------------------------
# Interactive system package uninstall (non-essential only)
# -------------------------
echo
echo "📦 System packages"

PACKAGES=(unzip curl tar python3 python3-pip nodejs npm python3-venv xclip)
ESSENTIAL_PACKAGES=(curl tar python3)

# Detect package manager
if [ -x "$(command -v apt)" ]; then
    PKG_MANAGER="apt"
elif [ -x "$(command -v dnf)" ]; then
    PKG_MANAGER="dnf"
elif [ -x "$(command -v pacman)" ]; then
    PKG_MANAGER="pacman"
else
    echo "⚠️ Unsupported package manager. Cannot uninstall system packages."
    PKG_MANAGER=""
fi

for pkg in "${PACKAGES[@]}"; do
    # Skip essential packages
    if [[ " ${ESSENTIAL_PACKAGES[*]} " == *" $pkg "* ]]; then
        echo "⚠️ Skipping essential package $pkg"
        continue
    fi

    # Only prompt if package exists
    if command -v "$pkg" >/dev/null 2>&1; then
        if confirm "Uninstall $pkg?"; then
            case $PKG_MANAGER in
                apt)
                    sudo apt remove --purge -y "$pkg"
                    ;;
                dnf)
                    sudo dnf remove -y "$pkg"
                    ;;
                pacman)
                    sudo pacman -Rns --noconfirm "$pkg"
                    ;;
            esac
        fi
    fi
    echo
done

echo
echo "✅ Uninstall complete. Restart your shell to apply changes."
