#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="${HYPR_APP_SWITCHER_DIR:-$HOME/.local/share/hypr-app-switcher}"
LEGACY_SYSTEMD="$HOME/.config/systemd/user/hypr-app-switcher.service"

if [ -f "$LEGACY_SYSTEMD" ]; then
    echo ":: Removing legacy systemd service..."
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user disable --now hypr-app-switcher.service 2>/dev/null || true
        systemctl --user daemon-reload 2>/dev/null || true
    fi
    rm -f "$LEGACY_SYSTEMD"
fi

echo ":: Stopping any running hypr-app-switcher instance..."
pkill -f "qs -p .*hypr-app-switcher" 2>/dev/null || true

if [ -d "$INSTALL_DIR" ]; then
    echo ":: Removing $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    echo ":: hypr-app-switcher uninstalled successfully."
else
    echo ":: Nothing to do: $INSTALL_DIR does not exist."
fi
