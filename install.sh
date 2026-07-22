#!/usr/bin/env bash
# iterm2_colors installer
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
