GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD_GREEN='\033[1;32m'
BOLD_CYAN='\033[1;36m'
NC='\033[0m' # No Color

echo "${BOLD_CYAN}ZDOTDIR${NC} => ${BOLD_GREEN}$ZDOTDIR${NC}"

source "$ZDOTDIR/oh-my-zsh.zsh"
source "$ZDOTDIR/exports.zsh"
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/plugins/fzf-tab/config.zsh"

source $ZSH/oh-my-zsh.sh
# 后定义别名
source "$ZDOTDIR/aliases.zsh"

eval "$(mcfly init zsh)"
# eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
# fastfetch

# >>> nvm lazy init >>>
_lazy_nvm() {
    unfunction nvm node npm npx yarn pnpm 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm() { _lazy_nvm && nvm "$@"; }
node() { _lazy_nvm && node "$@"; }
npm() { _lazy_nvm && npm "$@"; }
npx() { _lazy_nvm && npx "$@"; }
yarn() { _lazy_nvm && yarn "$@"; }
# <<< nvm lazy init <<<

function zvm_after_init() {
    bindkey -M vicmd 'H' beginning-of-line
    bindkey -M vicmd 'L' end-of-line
    bindkey -M vicmd '^R' redo
    bindkey -M viins '^R' mcfly-history-widget
}

[[ ! -f ~/dotfiles/p10k/.p10k.zsh ]] || source ~/dotfiles/p10k/.p10k.zsh
