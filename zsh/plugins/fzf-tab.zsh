zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# zoxide 数据库历史路径替代默认目录补全，fzf-tab接管
_fzf_tab_z() {
  # 输入路径前缀，回到标准文件补全
  # ./
  # ../
  # /
  # ~
  if [[ ${words[CURRENT]} == ./* ]] || [[ ${words[CURRENT]} == /* ]] || [[ ${words[CURRENT]} == "~"* ]]; then
    if [[ $service == vim ]]; then
      _files
    else
      _directories
    fi
    return
  fi

  local -a dirs
  dirs=(${(f)"$(zoxide query -l -- ${words[2,-1]} 2>/dev/null)"})
  compadd -U -V 'recent directories' -- "${dirs[@]}"
  # 跳过 / 路径插入
  compstate[list]="force"
  compstate[insert]=''
}

compdef _fzf_tab_z z j vim
