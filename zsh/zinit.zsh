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
zinit ice wait lucid as"null" atload'eval "$(atuin init zsh --disable-up-arrow)"'
zinit light zdharma-continuum/null

zinit ice wait lucid as"program" pick"git-open"
zinit light paulirish/git-open

autoload -Uz compinit
compinit -C -u

# 前台启动使用补全缓存，每24小时后台重建缓存
refresh_stamp=(~/.zcompdump-refresh-stamp(N.mh+24))
if [[ ! -e ~/.zcompdump-refresh-stamp || ${#refresh_stamp} -ne 0 ]]; then
  (
    lock_dir="${TMPDIR:-/tmp}/zcompdump-refresh-${UID}"
    if ! mkdir "${lock_dir}" 2>/dev/null; then
      exit 0
    fi
    trap 'rmdir "${lock_dir}"' EXIT

    touch ~/.zcompdump-refresh-stamp
    print -P "%F{244}[zcompdump]%f start: rebuilding .zcompdump"
    autoload -Uz compinit
    compinit -u -d ~/.zcompdump >/dev/null 2>&1
    print -P "%F{244}[zcompdump]%f done: rebuilt .zcompdump"
  ) &!
fi

# 禁用补全 "do you wish to see all X possibilities?" 提示
LISTMAX=0
