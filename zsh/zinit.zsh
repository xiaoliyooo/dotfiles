ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

zinit wait lucid for \
  OMZL::clipboard.zsh \
  OMZL::completion.zsh \
  OMZL::history.zsh \
  OMZL::key-bindings.zsh \
  zsh-users/zsh-completions \
  hlissner/zsh-autopair \
  lukechilds/zsh-nvm

# 解绑Esc触发fzf搜索
zinit ice wait lucid atload'bindkey -r "\ec"'
zinit snippet OMZP::fzf

# carapace 额外补全
zinit ice wait lucid as"null" atload'source <(carapace _carapace)'
zinit light zdharma-continuum/null

# fzf-tab
zinit ice wait lucid atload'source ${ZDOTDIR}/plugins/fzf-tab.zsh'
zinit light Aloxaf/fzf-tab

zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# fast-syntax-highlighting 必须在 fzf-tab 后加载
# 在 fzf-tab 之后包装 ZLE widgets 才能正确响应补全后的重新高亮
zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting

# atuin 懒加载
zinit ice wait lucid as"null" atload'eval "$(atuin init zsh)"'
zinit light zdharma-continuum/null

zinit ice wait lucid as"program" pick"git-open"
zinit light paulirish/git-open

autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C  # 使用缓存，24小时内不重建
fi

# 禁用补全 "do you wish to see all X possibilities?" 提示
LISTMAX=0
