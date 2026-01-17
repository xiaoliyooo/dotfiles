GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD_GREEN='\033[1;32m'
BOLD_CYAN='\033[1;36m'
NC='\033[0m' # No Color

echo "${BOLD_CYAN}ZDOTDIR${NC} => ${BOLD_GREEN}$ZDOTDIR${NC}"

source "$ZDOTDIR/oh-my-zsh.zsh"
source "$ZDOTDIR/exports.zsh"
source "$ZDOTDIR/functions.zsh"
# source "$ZDOTDIR/plugins/fzf-tab/config.zsh"

source $ZSH/oh-my-zsh.sh
source "$ZDOTDIR/plugins/autocomplete.zsh"

# 后定义别名
source "$ZDOTDIR/aliases.zsh"

eval "$(mcfly init zsh)"
eval "$(starship init zsh)"
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
  # 在 zsh-vi-mode 初始化后手动加载，代替 plugins fzf配置
  [ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh
  [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

  bindkey -M vicmd 'H' beginning-of-line
  bindkey -M vicmd 'L' end-of-line
  bindkey -M vicmd '^R' redo
  bindkey -M viins '^R' mcfly-history-widget

  # fix: kitty-scrollback.nvim回退到终端时，zsh-vi-mode vi mode导致无法粘贴
  # 先切换到 insert 模式，再执行 bracketed paste
  function _ksb_bracketed_paste_viins() {
    if [[ $KEYMAP == vicmd ]]; then
      zvm_enter_insert_mode
    fi
    zle .bracketed-paste
  }
  zle -N _ksb_bracketed_paste_viins
  bindkey -M vicmd "^[[200~" _ksb_bracketed_paste_viins

  # >>> 解决 zsh-vi-mode 与 zsh-autocomplete 的兼容性问题 >>>
  function _menu_select_insert_only() {
    if [[ $ZVM_MODE == $ZVM_MODE_INSERT ]]; then
      zle menu-select
    fi
  }
  zle -N _menu_select_insert_only
  bindkey '^I' _menu_select_insert_only # Tab 进入补全菜单
  # <<< 解决 zsh-vi-mode 与 zsh-autocomplete 的兼容性问题 <<<

  # 菜单中按 ESC 退出菜单
  bindkey -M menuselect '\e' send-break
  # 菜单中用 hjkl 导航
  bindkey -M menuselect 'h' backward-char
  bindkey -M menuselect 'j' down-line-or-history
  bindkey -M menuselect 'k' up-line-or-history
  bindkey -M menuselect 'l' forward-char
}

# normal 模式下禁用实时补全显示
function zvm_after_select_vi_mode() {
  if [[ $ZVM_MODE == $ZVM_MODE_NORMAL ]]; then
    zstyle ':autocomplete:*' min-input 9999
  else
    zstyle ':autocomplete:*' min-input 0
  fi
}

# normal 模式下上下键恢复为普通历史浏览，不触发菜单
function zvm_after_lazy_keybindings() {
  bindkey -M vicmd '^[[A' up-line-or-history
  bindkey -M vicmd '^[[B' down-line-or-history
  bindkey -M vicmd '^[OA' up-line-or-history
  bindkey -M vicmd '^[OB' down-line-or-history
  bindkey -M vicmd 'k' up-line-or-history
  bindkey -M vicmd 'j' down-line-or-history
}

# [[ ! -f ~/dotfiles/p10k/.p10k.zsh ]] || source ~/dotfiles/p10k/.p10k.zsh
source "$ZDOTDIR/../bd.zsh"
