zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# zoxide 数据库历史路径替代默认目录补全，fzf-tab接管
_fzf_tab_z() {
  local -a dirs
  dirs=(${(f)"$(zoxide query -l -- ${words[2,-1]} 2>/dev/null)"})
  compadd -U -V 'recent directories' -- "${dirs[@]}"
  # 跳过 / 路径插入
  compstate[list]="force"
  compstate[insert]=''
}

# 补全选择后自动执行
zstyle ':fzf-tab:complete:(vim|nvim|z|j):*' accept-line enter

compdef _fzf_tab_z z j
