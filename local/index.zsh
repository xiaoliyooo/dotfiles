_ZSHRC_CYAN='\033[1;36m'
_ZSHRC_YELLOW='\033[1;33m'
_ZSHRC_GREEN='\033[1;32m'
_ZSHRC_NC='\033[0m'

_setup_zshrc_local() {
  local zshrc_local="$HOME/.zshrc.local"

  if [ ! -f "$zshrc_local" ]; then
    touch "$zshrc_local"
    echo "${_ZSHRC_GREEN}📝 已创建 ~/.zshrc.local${_ZSHRC_NC}"
  fi
}

_setup_gitconfig_local() {
  local gitconfig_local="$HOME/.gitconfig.local"

  if [ -f "$gitconfig_local" ]; then
    return
  fi

  cat >"$gitconfig_local" <<'EOF'
[user]
  name = Your Name
  email = your@email.com
EOF

  echo "${_ZSHRC_GREEN}📝 已创建 ~/.gitconfig.local，请替换为你的真实信息${_ZSHRC_NC}"
}

setup_local() {
  _setup_zshrc_local
  _setup_gitconfig_local
}
