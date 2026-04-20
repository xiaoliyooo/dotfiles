#!/bin/zsh
CMD="node dispatch.js '$POPCLIP_TEXT' -t 5"

SOCKET=$(ls -t /tmp/locator_vim_kitty--* 2>/dev/null | head -1)
if [[ -n "$SOCKET" ]] && /opt/homebrew/bin/kitty @ --to "unix:$SOCKET" ls >/dev/null 2>&1; then
  /opt/homebrew/bin/kitty @ --to "unix:$SOCKET" launch --type=os-window --cwd=/Volumes/HIKSEMI/dev/Bugfix_Factory zsh -ic "$CMD; exec zsh"
else
  /opt/homebrew/bin/kitty --directory /Volumes/HIKSEMI/dev/Bugfix_Factory zsh -ic "$CMD; exec zsh" &
fi

echo "Dispatching: $POPCLIP_TEXT"
