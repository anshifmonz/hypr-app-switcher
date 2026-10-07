#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/anshifmonz/hypr-app-switcher.git"
INSTALL_DIR="${HYPR_APP_SWITCHER_DIR:-$HOME/.local/share/hypr-app-switcher}"
LEGACY_SYSTEMD="$HOME/.config/systemd/user/hypr-app-switcher.service"

echo ":: Initializing hypr-app-switcher installer..."

if ! command -v git >/dev/null 2>&1; then
    echo ":: ERROR: git is required but not installed."
    exit 1
fi

if ! command -v qs >/dev/null 2>&1; then
    echo ":: WARNING: quickshell ('qs') command not found in PATH."
    echo ":: Please make sure quickshell is installed from AUR ('quickshell' or 'quickshell-git')."
fi

if [ -d "$INSTALL_DIR/.git" ]; then
    echo ":: Updating hypr-app-switcher in $INSTALL_DIR..."
    git -C "$INSTALL_DIR" pull --ff-only
    echo ":: hypr-app-switcher updated successfully."
elif [ -d "$INSTALL_DIR" ]; then
    echo ":: ERROR: $INSTALL_DIR exists but is not a git repository."
    echo ":: Please remove or backup $INSTALL_DIR and run this script again."
    exit 1
else
    echo ":: Cloning hypr-app-switcher into $INSTALL_DIR..."
    mkdir -p "$(dirname "$INSTALL_DIR")"
    git clone "$REPO_URL" "$INSTALL_DIR"
    echo ":: hypr-app-switcher cloned successfully."
fi

if [ -f "$LEGACY_SYSTEMD" ]; then
    echo ":: Removing legacy systemd service..."
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user disable --now hypr-app-switcher.service 2>/dev/null || true
        systemctl --user daemon-reload 2>/dev/null || true
    fi
    rm -f "$LEGACY_SYSTEMD"
fi

echo ""
echo "========================================================="
echo "  hypr-app-switcher installed successfully!"
echo "========================================================="
echo ""
echo "1. Add to Autostart:"
echo ""
echo "   --- For ML4W Dotfiles (~/.config/hypr/conf/autostart.lua) ---"
echo '   hl.exec_cmd("qs -p ~/.local/share/hypr-app-switcher")'
echo ""
echo "   --- Or inside ~/.config/ml4w/scripts/ml4w-autostart ---"
echo '   qs -p $HOME/.local/share/hypr-app-switcher &'
echo ""
echo "   --- For Standard Hyprland (~/.config/hypr/hyprland.conf) ---"
echo '   exec-once = qs -p ~/.local/share/hypr-app-switcher'
echo ""
echo "2. Add Keybindings:"
echo ""
echo "   --- For ML4W Lua Keybindings (~/.config/hypr/conf/keybindings/default.lua) ---"
echo '   hl.bind("ALT + Tab",         hl.dsp.exec_cmd("qs -p ~/.local/share/hypr-app-switcher ipc call app-switcher next"), { description = "Switch applications on active workspace" })'
echo '   hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("qs -p ~/.local/share/hypr-app-switcher ipc call app-switcher prev"), { description = "Switch applications on active workspace (backwards)" })'
echo ""
echo "   --- For Standard Hyprland Conf (~/.config/hypr/hyprland.conf) ---"
echo '   bind = ALT, Tab, exec, qs -p ~/.local/share/hypr-app-switcher ipc call app-switcher next'
echo '   bind = ALT SHIFT, Tab, exec, qs -p ~/.local/share/hypr-app-switcher ipc call app-switcher prev'
echo ""
