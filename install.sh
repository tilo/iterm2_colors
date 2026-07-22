#!/usr/bin/env bash
# iterm2_colors installer
#
# Run it:      ./install.sh   (recommended)   or   bash install.sh
# Sourcing it: source install.sh  also works — it re-runs itself in a child
#              shell so it can NEVER close or alter your current terminal.

# --- guard: if this file is being sourced, re-exec in a child and return ---
# (Never let `set -e`, an `exit`, or bash-only syntax touch the caller's shell.)
if [ -n "${ZSH_VERSION:-}" ]; then
  case "${ZSH_EVAL_CONTEXT:-}" in *:file|*:file:*) _itc_sourced=1 ;; *) _itc_sourced=0 ;; esac
  _itc_self="$0"
elif [ -n "${BASH_VERSION:-}" ]; then
  if [ "${BASH_SOURCE[0]}" != "$0" ]; then _itc_sourced=1; else _itc_sourced=0; fi
  _itc_self="${BASH_SOURCE[0]}"
else
  _itc_sourced=0; _itc_self="$0"
fi
if [ "$_itc_sourced" = 1 ]; then
  echo "(sourced) running installer in a child shell so this terminal stays open…"
  bash "$_itc_self" "$@"
  return $?
fi

set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.iterm2_colors"
ZSHRC="$HOME/.zshrc"
BEGIN='# >>> iterm2_colors >>>'
END='# <<< iterm2_colors <<<'

# 1. make sure the files live at ~/.iterm2_colors
if [ "$DIR" != "$TARGET" ]; then
  echo "1. Copying files -> $TARGET"
  mkdir -p "$TARGET"
  cp "$DIR/colors.zsh" "$DIR/apply-iterm-profile.py" "$DIR/README.md" "$TARGET/" 2>/dev/null || \
  cp "$DIR/colors.zsh" "$DIR/apply-iterm-profile.py" "$TARGET/"
else
  echo "1. Files already at $TARGET"
fi

# 2. (re)write a managed block in ~/.zshrc — replaces any previous one, so
#    updates to this stanza actually take effect on re-install (no duplicates).
echo "2. Updating managed block in ~/.zshrc"
touch "$ZSHRC"
if grep -qF "$BEGIN" "$ZSHRC"; then echo "   replacing existing block"; else echo "   adding block"; fi
tmp="$(mktemp)"
# strip any existing BEGIN..END block (inclusive), then append the current one
awk -v b="$BEGIN" -v e="$END" '
  $0==b {skip=1; next}
  $0==e {skip=0; next}
  !skip {print}
' "$ZSHRC" > "$tmp"
{
  cat "$tmp"
  printf '\n%s\n' "$BEGIN"
  printf '# Managed by iterm2_colors (install.sh) — safe to cut & replace this whole block.\n'
  printf '[ -f ~/.iterm2_colors/colors.zsh ] && source ~/.iterm2_colors/colors.zsh\n'
  printf '%s\n' "$END"
} > "$ZSHRC"
rm -f "$tmp"

# 3. apply iTerm Default-profile settings (badge/contrast/cursor)
echo "3. Applying iTerm Default-profile settings"
if pgrep -x iTerm2 >/dev/null 2>&1; then
  echo "   SKIPPED: iTerm2 is running."
  echo "   Quit iTerm2 (Cmd+Q), then from Terminal.app run:"
  echo "     python3 ~/.iterm2_colors/apply-iterm-profile.py"
else
  python3 "$TARGET/apply-iterm-profile.py"
fi

echo
echo "Done. Open a new iTerm tab (or 'source ~/.zshrc') to see the colors."
echo "Optional (Claude Code): set \"theme\": \"light-ansi\" in ~/.claude/settings.json."
