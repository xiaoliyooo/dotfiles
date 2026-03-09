# 取消zinit的别名
unalias zi 2>/dev/null

# 过滤路径保存
export _ZO_EXCLUDE_DIRS="**/node_modules"

_zoxide_init() {
  unfunction z zi 2>/dev/null
  eval "$(zoxide init zsh)"
  compdef _fzf_tab_z z j
}

z() {
  _zoxide_init
  z "$@"
}

zi() {
  _zoxide_init
  zi "$@"
}
