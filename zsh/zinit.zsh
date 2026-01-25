ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

zinit wait lucid for \
  OMZL::clipboard.zsh \
  OMZL::completion.zsh \
  OMZL::history.zsh \
  OMZL::key-bindings.zsh \
  OMZP::fzf \
  zsh-users/zsh-completions \
  hlissner/zsh-autopair \
  zsh-users/zsh-syntax-highlighting \
  zdharma-continuum/fast-syntax-highlighting

zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C  # 使用缓存，24小时内不重建
fi

# 禁用补全 "do you wish to see all X possibilities?" 提示
LISTMAX=0
