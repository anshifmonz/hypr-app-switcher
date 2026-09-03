#!/usr/bin/env bash
#
# Install or update hypr-app-switcher
#

set -euo pipefail

REPO_URL="https://github.com/anshifmonz/hypr-app-switcher.git"
INSTALL_DIR="${HYPR_APP_SWITCHER_DIR:-$HOME/.local/share/hypr-app-switcher}"
SYSTEMD_DIR="$HOME/.config/systemd/user"

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

# Setup systemd user service
mkdir -p "$SYSTEMD_DIR"
cat << SERVICE_EOF > "$SYSTEMD_DIR/hypr-app-switcher.service"
[Unit]
Description=Quickshell Hyprland App Switcher Daemon
PartOf=graphical-session.target
After=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/env qs -p $INSTALL_DIR
Restart=always
RestartSec=1

[Install]
WantedBy=default.target
SERVICE_EOF

# Reload and enable service if systemd is active
if command -v systemctl >/dev/null 2>&1; then
    echo ":: Setting up systemd user service..."
    systemctl --user daemon-reload || true
    systemctl --user enable --now hypr-app-switcher.service || true
    echo ":: hypr-app-switcher service configured."
fi

echo ""
echo "========================================================="
echo "  hypr-app-switcher installed successfully!"
echo "========================================================="
echo ""
echo "To activate keybindings, add these to your Hyprland config:"
echo ""
echo "--- For ML4W Lua Keybindings (~/.config/hypr/conf/keybindings/default.lua) ---"
echo 'hl.bind("ALT + Tab",         hl.dsp.exec_cmd("qs -p ~/.local/share/hypr-app-switcher ipc call app-switcher next"), { description = "Switch applications on active workspace" })'
echo ""
echo "--- For Standard Hyprland Conf (~/.config/hypr/hyprland.conf) ---"
echo 'bind = ALT, Tab, exec, qs -p ~/.local/share/hypr-app-switcher ipc call app-switcher next'
echo ""
