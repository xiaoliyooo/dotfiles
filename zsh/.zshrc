source "$ZDOTDIR/exports.zsh"
# 继承了 EDITOR=nvim 的 shell（tmux / nvim 终端）启动时默认是 viins 键位，
# 下面的自定义 bindkey 会落到 viins，随后被 OMZL::key-bindings 的 bindkey -e 丢弃，这里先固定为 emacs
bindkey -e
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
setopt NO_HUP              # 确保nohup有效
setopt interactivecomments # 交互式zsh 支持注释
setopt extended_glob
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_MINUS
zle_highlight=('paste:none')

dt
