#!/usr/bin/env bash
#
# Uninstall hypr-app-switcher
#

set -euo pipefail

INSTALL_DIR="${HYPR_APP_SWITCHER_DIR:-$HOME/.local/share/hypr-app-switcher}"
SYSTEMD_FILE="$HOME/.config/systemd/user/hypr-app-switcher.service"

echo ":: Stopping and disabling hypr-app-switcher service..."
if command -v systemctl >/dev/null 2>&1; then
    systemctl --user disable --now hypr-app-switcher.service 2>/dev/null || true
fi

if [ -f "$SYSTEMD_FILE" ]; then
    echo ":: Removing systemd service file..."
    rm -f "$SYSTEMD_FILE"
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user daemon-reload || true
    fi
fi

if [ -d "$INSTALL_DIR" ]; then
    echo ":: Removing $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    echo ":: hypr-app-switcher uninstalled successfully."
else
    echo ":: Nothing to do: $INSTALL_DIR does not exist."
fi
