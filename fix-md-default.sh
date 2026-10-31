#!/bin/zsh
set -u

BASE="${HOME}/Library/Application Support/md-default-guard"
HELPER="$BASE/md-default"
CONF="$BASE/target-bundle-id"
LOG="$HOME/Library/Logs/md-default-guard.log"
UTIS=("com.unknown.md" "net.daringfireball.markdown")

[[ -x "$HELPER" ]] || { print -u2 "helper not built: $HELPER"; exit 1; }
desired="${1:-}"
[[ -z "$desired" && -f "$CONF" ]] && desired="$(<"$CONF")"
[[ -n "$desired" ]] || { print -u2 "missing bundle identifier"; exit 2; }

drift=0
for uti in $UTIS; do
  cur="$($HELPER query "$uti" | cut -f2)"
  [[ "${cur:l}" == "${desired:l}" ]] || drift=1
done

[[ "${1:-}" == "--check" && $drift -eq 0 ]] && exit 0
[[ $drift -eq 0 ]] && exit 0

if "$HELPER" set "$desired"; then
  /usr/bin/killall lsd 2>/dev/null || true
  mkdir -p "$(dirname "$LOG")"
  print -- "$(date '+%Y-%m-%d %H:%M:%S') restored $desired" >> "$LOG"
else
  print -u2 "Launch Services rejected the requested association"
  exit 1
fi
