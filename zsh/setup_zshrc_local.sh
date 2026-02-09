_ZSHRC_CYAN='\033[1;36m'
_ZSHRC_YELLOW='\033[1;33m'
_ZSHRC_GREEN='\033[1;32m'
_ZSHRC_NC='\033[0m'

_check_env_vars() {
  local category="$1"
  shift
  local env_vars=("$@")
  local zshrc_local="$HOME/.zshrc.local"

  local missing_vars=()
  for var in "${env_vars[@]}"; do
    if ! grep -q "^export $var=" "$zshrc_local"; then
      missing_vars+=("$var")
    fi
  done

  if [ ${#missing_vars[@]} -gt 0 ]; then
    echo "${_ZSHRC_YELLOW}⚠ ~/.zshrc.local 缺少 ${category} 环境变量：${_ZSHRC_NC}"
    for var in "${missing_vars[@]}"; do
      echo "   ${_ZSHRC_CYAN}export $var=\"\"${_ZSHRC_NC}"
    done
  fi
}

_setup_git_env() {
  local git_env_vars=("GIT_AUTHOR_NAME" "GIT_AUTHOR_EMAIL" "GIT_COMMITTER_NAME" "GIT_COMMITTER_EMAIL")
  _check_env_vars "Git" "${git_env_vars[@]}"
}

_setup_zshrc_local() {
  local zshrc_local="$HOME/.zshrc.local"

  if [ ! -f "$zshrc_local" ]; then
    touch "$zshrc_local"
    echo "${_ZSHRC_GREEN}📝 已创建 ~/.zshrc.local${_ZSHRC_NC}"
  fi
}

setup_zshrc_local() {
  _setup_zshrc_local
  _setup_git_env
}
