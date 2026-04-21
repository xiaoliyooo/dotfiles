source "$ZDOTDIR/exports.zsh"
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/zinit.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/command-buffer-hotkeys.zsh"

# Load modular configurations
for folder in "$ZDOTDIR"/../*(/); do
  [[ -f "$folder/index.zsh" ]] && source "$folder/index.zsh"
done

setup_local && source "$HOME/.zshrc.local"

# PATH 去重
typeset -gU path
setopt NO_HUP # 确保nohup有效

date
