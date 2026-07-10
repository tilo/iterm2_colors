# iterm2_colors

Do you have multiple work directories for parallel work streams, and parallel AI sessions?
Having many iTerm2 sessions open, can make it really hard to know in which directory you're working in.

This light-weight utility automatically colors your iTerm2 session based on the directory name.

The per-directory color coding for iTerm2, is tuned so text stays readable on light
backgrounds (Molokai-inspired).

Each terminal recolors itself based on the `Work_<color>` / `GitHub_<color>` directory you're in — `Work_red`, `Work_blue`, `Work_green`, `Work_yellow`, `Work_purple`, `Work_gray`, `Work_white`, `Work_black`.
Similarly you could use `GitHub_` as the prefix.

## What it does

- Recolors the **current** iTerm2 session with `SetColors` escape codes, so `CMD +/-`
  zoom, font size, and split panes **survive a directory change**. (Switching iTerm
  profiles would reset those; this doesn't.)
- Sets a neutral **gray badge** (watermark) that tints to match each background,
  raises **Minimum Contrast** so faint text pops, and turns on **Smart Cursor Color**.

## Install

```sh
git clone git@github.com:tilo/iterm2_colors.git
cd iterm2_colors
./install.sh
```

The installer:
1. Copies the files to `~/.iterm2_colors/` (wherever you cloned the repo,
   the installed copy always ends up there).
2. Adds `source ~/.iterm2_colors/colors.zsh` to `~/.zshrc` (idempotent).
3. Applies the badge / Minimum Contrast / Smart Cursor settings to your iTerm
   **Default** profile.

### Important: the profile step needs iTerm2 closed

iTerm2 rewrites its preferences when it quits, so the profile settings can only be
written while iTerm2 is **not running**. If iTerm2 is open when you run `install.sh`,
step 3 is skipped with instructions. To do it:

```sh
# Quit iTerm2 (Cmd+Q), then from Terminal.app:
python3 ~/.iterm2_colors/apply-iterm-profile.py
# Reopen iTerm2
```

## Files

| File | Purpose |
| ---- | ------- |
| `colors.zsh`            | The palette + per-directory hook. Sourced from `~/.zshrc`. |
| `apply-iterm-profile.py`| Writes badge / contrast / cursor to the iTerm2 Default profile (plist). No dependencies. Run with iTerm2 quit. |
| `install.sh`            | Wires everything up. |

## Customizing

- **Colors / backgrounds:** edit the `_ITERM_PAYLOAD[...]` lines in `colors.zsh`.
  Each is a set of `SetColors=key=hex` escape codes (`bg`, `fg`, the 16 ANSI slots,
  `tab`, and the base64 `SetBadgeFormat` label).
- **Badge shade / opacity:** edit `GRAY` / `ALPHA` at the top of
  `apply-iterm-profile.py`, then re-run it (with iTerm2 quit).

## Claude Code (optional)

Claude Code's `dark` / `light` themes ignore the terminal palette. To make Claude
use these colors, set an **`-ansi`** theme in `~/.claude/settings.json`:

```json
{ "theme": "light-ansi" }
```

For a dark directory (e.g. `Work_black`), drop a
`.claude/settings.local.json` with `{ "theme": "dark-ansi" }` in that tree.
Theme is read at startup — restart `claude` to pick it up.

## Notes / gotchas

- **iTerm2 keeps separate colors for light and dark mode.** The profile setting
  "Use Separate Colors for Light and Dark Mode" means the plain color key is
  ignored in favor of `(Light)` / `(Dark)` variants — so the installer writes all
  three. If a profile setting ever seems ignored, this is why.
- The badge color has **no escape code** — it can only be set on the profile,
  which is why `apply-iterm-profile.py` exists.
