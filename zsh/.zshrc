source "$ZDOTDIR/exports.zsh"
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/zinit.zsh"
source "$ZDOTDIR/aliases.zsh"

# Load modular configurations
for folder in "$ZDOTDIR"/../*(/); do
  [[ -f "$folder/index.zsh" ]] && source "$folder/index.zsh"
done

setup_zshrc_local && source "$HOME/.zshrc.local"

date
