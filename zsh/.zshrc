source "$ZDOTDIR/exports.zsh"
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/zinit.zsh"
source "$ZDOTDIR/aliases.zsh"

eval "$(starship init zsh)"

unalias zi 2>/dev/null

_zoxide_init() {
  unfunction z zi 2>/dev/null
  eval "$(zoxide init zsh)"
}

z() {
  _zoxide_init
  z "$@"
}

zi() {
  _zoxide_init
  zi "$@"
}

source "$ZDOTDIR/../bd.zsh"
source "$ZDOTDIR/setup_zshrc_local.sh"

setup_zshrc_local && source "$HOME/.zshrc.local"

date
