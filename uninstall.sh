#!/bin/zsh
set -e
launchctl bootout "gui/$(id -u)/com.md-default-guard" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.md-default-guard.plist"
rm -rf "$HOME/Library/Application Support/md-default-guard"
echo "Removed the guard. Existing Launch Services associations were left unchanged."
