# 取消zinit的别名
unalias zi 2>/dev/null

_zoxide_init() {
  unfunction z zi 2>/dev/null
  eval "$(zoxide init zsh)"
  compdef _z z j
}

z() {
  _zoxide_init
  z "$@"
}

zi() {
  _zoxide_init
  zi "$@"
}
