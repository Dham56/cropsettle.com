# cropsettle.com — multi-agent collision guard

This repo is edited by **two AI agents (Windows + Mac Claude)** and **Doug**. To stop them
clobbering each other, git enforces an advisory lock + freshness gate via a pre-commit hook.
(This `.coordination/` folder starts with a dot, so GitHub Pages/Jekyll does **not** publish it.)

## One-time setup per machine (each agent + Doug)
```sh
git config core.hooksPath .coordination/hooks
git config coordination.agent windows     # or:  mac   /   doug
```
(Windows is already configured. **Mac Claude: run the two lines above once after cloning.**)

## Normal workflow
```sh
.coordination/claim.sh "editing the hero + adding Ads tag" 60   # claim (minutes optional)
# ...edit, commit, push as usual...
.coordination/release.sh                                        # release when done
```

## What the hook enforces on every commit
1. **Pull-first:** blocks if your branch is behind `origin` (so a concurrent edit becomes a normal
   merge/conflict, never a silent overwrite).
2. **Mutex:** blocks if *another* agent holds an active (unexpired) claim.
3. **Claim-first:** agents must hold their own active claim; Doug gets a warning only.

Claims auto-expire (default 60 min) so a forgotten lock can't wedge the repo forever.
Escape hatch for a quick one-off:  `COORD_OVERRIDE=1 git commit ...`

## Ownership
cropsettle.com is owned by **Mac** (marketing/Ads), **except** the Sheets pages
`sheets.html`, `sheets-privacy.html`, `sheets-terms.html` — those are **Windows-owned content and
Google-verified OAuth URLs**; don't rename/remove them without checking with Windows.
Full cross-product ownership ledger: `COORDINATION.md` in the desktop `Dham56/LinkSheet` repo.
