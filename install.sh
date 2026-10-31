#!/bin/zsh
set -e
target="${1:-com.google.Chrome}"
base="$HOME/Library/Application Support/md-default-guard"
plist="$HOME/Library/LaunchAgents/com.md-default-guard.plist"
mkdir -p "$base" "$HOME/Library/LaunchAgents"
clang -O2 -framework CoreServices -o "$base/md-default" md-default.c
cp fix-md-default.sh "$base/fix-md-default.sh"
chmod 700 "$base/fix-md-default.sh" "$base/md-default"
print -r -- "$target" > "$base/target-bundle-id"
"$base/fix-md-default.sh"
cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>com.md-default-guard</string>
<key>ProgramArguments</key><array><string>/bin/zsh</string><string>$base/fix-md-default.sh</string><string>--check</string></array>
<key>RunAtLoad</key><true/>
<key>StartInterval</key><integer>1800</integer>
<key>WatchPaths</key><array><string>/Applications/WorkBuddy.app/Contents/Info.plist</string><string>/Applications/WorkBuddy.app</string></array>
<key>StandardErrorPath</key><string>$HOME/Library/Logs/md-default-guard.err.log</string>
</dict></plist>
PLIST
plutil -lint "$plist"
launchctl bootout "gui/$(id -u)/com.md-default-guard" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$plist"
echo "Installed. Target: $target"
