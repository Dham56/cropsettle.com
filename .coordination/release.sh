#!/bin/sh
# Release your cropsettle.com claim.
ME="$(git config coordination.agent 2>/dev/null)"; CLAIM=".coordination/active-claim"
printf 'agent=none\nreason=\nexpires_epoch=0\nexpires=\n' > "$CLAIM"
git add "$CLAIM"
git commit -q -m "coord: ${ME:-someone} releases cropsettle.com"
git pull --rebase -q 2>/dev/null || true
git push -q || true
echo "Released."
