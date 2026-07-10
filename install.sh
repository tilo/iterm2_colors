#!/usr/bin/env bash
# iterm2_colors installer
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.iterm2_colors"
LINE='[ -f ~/.iterm2_colors/colors.zsh ] && source ~/.iterm2_colors/colors.zsh'

# 1. make sure the files live at ~/.iterm2_colors
if [ "$DIR" != "$TARGET" ]; then
  echo "1. Copying files -> $TARGET"
  mkdir -p "$TARGET"
  cp "$DIR/colors.zsh" "$DIR/apply-iterm-profile.py" "$DIR/README.md" "$TARGET/" 2>/dev/null || \
  cp "$DIR/colors.zsh" "$DIR/apply-iterm-profile.py" "$TARGET/"
else
  echo "1. Files already at $TARGET"
fi

# 2. wire into ~/.zshrc (idempotent)
echo "2. Wiring into ~/.zshrc"
if grep -qF '.iterm2_colors/colors.zsh' "$HOME/.zshrc" 2>/dev/null; then
  echo "   already sourced - skipping"
else
  printf '\n# iterm2_colors\n%s\n' "$LINE" >> "$HOME/.zshrc"
  echo "   added source line"
fi

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
