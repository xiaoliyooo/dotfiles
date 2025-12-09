GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD_GREEN='\033[1;32m'
BOLD_CYAN='\033[1;36m'
NC='\033[0m' # No Color

echo "${BOLD_CYAN}ZDOTDIR${NC} => ${BOLD_GREEN}$ZDOTDIR${NC}"

source "$ZDOTDIR/exports.zsh"
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/oh-my-zsh.zsh"
source "$ZDOTDIR/plugins/fzf-tab/config.zsh"

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# 后定义别名
source $ZSH/oh-my-zsh.sh
source "$ZDOTDIR/aliases.zsh"

eval "$(mcfly init zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"


