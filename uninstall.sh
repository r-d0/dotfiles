#!/usr/bin/env bash
set -e

# -------------------------
# Privilege handling
# -------------------------
SUDO=""

if [[ "$EUID" -eq 0 ]]; then
    SUDO=""
elif command -v sudo >/dev/null 2>&1; then
    echo "🔐 This uninstaller requires sudo access."
    echo "   Please enter your password to continue."

    if sudo -v; then
        SUDO="sudo"
    else
        cat <<'EOF'
❌ Failed to obtain sudo access.

This usually means:
  • Your user is not allowed to use sudo
  • You are on a shared / university / restricted system

Please run this uninstaller:
  • As root, or
  • On a machine where you have sudo access, or
  • After an administrator grants you sudo privileges

Aborting to avoid partial removal.
EOF
        exit 1
    fi
else
    # No sudo installed (e.g. Termux)
    SUDO=""
fi

echo "🧹 Interactive Uninstall Script"
echo

confirm() {
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
# Dotfiles
# -------------------------
echo "📂 Dotfiles"

[ -L ~/.bashrc ] && confirm "Remove ~/.bashrc symlink?" && rm ~/.bashrc
[ -L ~/.config/nvim ] && confirm "Remove ~/.config/nvim symlink?" && rm -rf ~/.config/nvim

# -------------------------
# Neovim
# -------------------------
echo "📦 Neovim"

if command -v pkg >/dev/null 2>&1; then
    confirm "Uninstall Neovim (Termux)?" && pkg uninstall -y neovim
else
    [ -f /opt/nvim/nvim ] && confirm "Remove Neovim AppImage?" && $SUDO rm -f /opt/nvim/nvim
    [ -d /opt/nvim ] && confirm "Remove /opt/nvim directory?" && $SUDO rmdir /opt/nvim 2>/dev/null || true
    grep -q '/opt/nvim' ~/.bashrc && confirm "Remove /opt/nvim from PATH?" && sed -i '/\/opt\/nvim/d' ~/.bashrc
fi

# -------------------------
# Mason
# -------------------------
echo "📦 Mason"
[ -d ~/.local/share/nvim/mason ] && confirm "Remove Mason?" && rm -rf ~/.local/share/nvim/mason

# -------------------------
# System packages
# -------------------------
echo "📦 System packages"

if command -v pkg >/dev/null 2>&1; then
    confirm "Autoremove unused Termux packages?" && pkg autoremove
elif command -v apt >/dev/null 2>&1; then
    confirm "Autoremove unused system packages?" && $SUDO apt autoremove -y
fi

echo "✅ Uninstall complete. Restart your shell."
