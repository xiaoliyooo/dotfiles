ZSH_THEME="robbyrussell"
skip_global_compinit=1

# 在 compinit 之前
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# 24h缓存过期重新编译补全
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit -u
else
    compinit -C -u
fi

plugins=(
  git
  autojump
  fzf-tab
  fzf
  zsh-autosuggestions
  zsh-syntax-highlighting
  copypath
  copyfile
  macos
  zsh-vi-mode
)
