#!/bin/sh
# Claim cropsettle.com for editing (advisory mutex for the multi-agent setup).
# Usage:  .coordination/claim.sh "what you're doing" [minutes]   (default 60)
ME="$(git config coordination.agent 2>/dev/null)"
[ -z "$ME" ] && { echo "Set your id first:  git config coordination.agent windows|mac|doug"; exit 1; }
reason="${1:-editing}"; mins="${2:-60}"; CLAIM=".coordination/active-claim"
branch="$(git rev-parse --abbrev-ref HEAD)"; now="$(date -u +%s)"
git fetch -q origin "$branch" 2>/dev/null || true

rc="$(git show "origin/$branch:$CLAIM" 2>/dev/null || true)"
if [ -n "$rc" ]; then
  a="$(printf '%s\n' "$rc" | grep '^agent=' | cut -d= -f2-)"
  e="$(printf '%s\n' "$rc" | grep '^expires_epoch=' | cut -d= -f2-)"
  if [ -n "$e" ] && [ "$a" != "$ME" ] && [ "$a" != "none" ] && [ "$e" -gt "$now" ] 2>/dev/null; then
    echo "Cannot claim — '$a' holds an active claim. Wait or coordinate."; exit 1
  fi
fi
exp=$((now + mins * 60))
exph="$(date -u -d "@$exp" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -r "$exp" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")"
mkdir -p .coordination
printf 'agent=%s\nreason=%s\nexpires_epoch=%s\nexpires=%s\n' "$ME" "$reason" "$exp" "$exph" > "$CLAIM"
git add "$CLAIM"
git commit -q -m "coord: $ME claims cropsettle.com — $reason (until $exph)"
git pull --rebase -q 2>/dev/null || true
if ! git push -q; then
  echo "Push failed — someone may have claimed first. Run: git pull --rebase, then re-claim."; exit 1
fi
echo "Claimed by $ME until $exph. Release when done:  .coordination/release.sh"
