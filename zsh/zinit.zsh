ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# zsh-users/zsh-syntax-highlighting理论上和fast-syntax-highlighting功能重复，但是通过tab补全后fast-syntax-highlighting不会第一时间高亮，zsh-users/zsh-syntax-highlighting弥补这个场景
zinit wait lucid for \
  OMZL::clipboard.zsh \
  OMZL::completion.zsh \
  OMZL::history.zsh \
  OMZL::key-bindings.zsh \
  OMZP::fzf \
  zsh-users/zsh-completions \
  hlissner/zsh-autopair \
  lukechilds/zsh-nvm \
  zsh-users/zsh-syntax-highlighting \
  zdharma-continuum/fast-syntax-highlighting

# fzf-tab
zinit ice wait lucid atload'source ${ZDOTDIR}/plugins/fzf-tab.zsh'
zinit light Aloxaf/fzf-tab

zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# atuin 懒加载
zinit ice wait lucid as"null" atload'eval "$(atuin init zsh)"'
zinit light zdharma-continuum/null

autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C  # 使用缓存，24小时内不重建
fi

# 禁用补全 "do you wish to see all X possibilities?" 提示
LISTMAX=0
