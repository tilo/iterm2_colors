#!/usr/bin/env python3
"""
Apply terminal-colors profile settings to your iTerm2 *Default* profile:
  - Badge Color -> neutral gray (tints per background instead of a fixed hue)
  - Minimum Contrast -> 0.5 (un-mutes faint/dim text)
  - Smart Cursor Color -> on

iTerm keeps SEPARATE colors for light and dark mode, so we set the plain key
AND the (Light)/(Dark) variants - otherwise the change appears to do nothing.

IMPORTANT: iTerm rewrites its plist on quit, so run this while iTerm is NOT
running (use Terminal.app), then open iTerm:

    1. Quit iTerm2 (Cmd+Q)
    2. From Terminal.app:  python3 ~/.iterm2_colors/apply-iterm-profile.py
    3. Open iTerm2
"""
import plistlib, os, subprocess, sys

# ---- tweak these for a different badge shade/opacity ----
GRAY = 75/255      # 0..1 ; lower = darker
ALPHA = 110/255    # 0..1 ; higher = more opaque
MIN_CONTRAST = 0.5

PLIST = os.path.expanduser('~/Library/Preferences/com.googlecode.iterm2.plist')

if subprocess.run(['pgrep','-x','iTerm2'], capture_output=True).returncode == 0:
    sys.exit("iTerm2 is running - quit it (Cmd+Q) and re-run this from Terminal.app.")

d = plistlib.load(open(PLIST,'rb'))
guid = d.get('Default Bookmark Guid')
color = {'Red Component':GRAY,'Green Component':GRAY,'Blue Component':GRAY,
         'Alpha Component':ALPHA,'Color Space':'sRGB'}

def apply(b):
    for suffix in ('', ' (Light)', ' (Dark)'):
        b['Badge Color'+suffix] = color
        b['Minimum Contrast'+suffix] = MIN_CONTRAST
        b['Smart Cursor Color'+suffix] = True

target = next((b for b in d.get('New Bookmarks',[]) if b.get('Guid')==guid), None) \
      or next((b for b in d.get('New Bookmarks',[]) if b.get('Name')=='Default'), None)
if target is None:
    sys.exit("Could not find the Default profile.")

apply(target)
plistlib.dump(d, open(PLIST,'wb'))
subprocess.run(['killall','cfprefsd'], capture_output=True)
print(f"Updated profile {target.get('Name')!r}: badge gray, min-contrast {MIN_CONTRAST}, smart cursor on.")
print("Open iTerm2 to see it.")
