git() {
  if [[ "$1" == "log" ]]; then
    command git log --color=always --date=format:'%Y-%m-%d %H:%M:%S' "${@:2}"
  elif [[ "$1" == "tree" ]]; then
    if [[ "$2" == "add" ]]; then
      local worktree_dir="${WORKTREE_ROOT}/$3"
      if ! git show-ref --verify --quiet "refs/heads/$3"; then
        echo "分支 $3 不存在，已创建 $3 新分支"
        command git branch "$3" || return $?
      fi
      command git worktree add "$worktree_dir" "$3"
    elif [[ "$2" == "remove" ]]; then
      command git worktree remove -f "$3"
    elif [[ "$2" == "list" ]]; then
      command git worktree list
    fi
  elif [[ "$1" == "merge" ]]; then
    if [[ "$2" == "--abort" ]] || [[ "$2" == "--continue" ]] || [[ "$2" == "--quit" ]]; then
      command git "$@"
    else
      command git pull && echo "自动git pull 完成" && command git merge --no-edit "$2"
    fi
  else
    command git "$@"
  fi
}

GIT_PROJECTS=(
  "$HOME/dotfiles"
  "$HOME/.config/nvim"
  "$HOME/xiaoli-notes"
  "$HOME/apps"
)

gs() {
  for proj in "${GIT_PROJECTS[@]}"; do
    proj="${proj/#\~/$HOME}"

    if [ -d "$proj/.git" ]; then
      echo -e "\n\033[1;34m==> Project: $proj\033[0m"
      git -C "$proj" status -s
    else
      echo -e "\n\033[1;33m==> Skipping: $proj (Not a git repo)\033[0m"
    fi
  done
}

pull() {
  setopt local_options no_notify no_monitor
  local pids=()

  for proj in "${GIT_PROJECTS[@]}"; do
    proj="${proj/#\~/$HOME}"

    if [ -d "$proj/.git" ]; then
      (
        result=$(git -C "$proj" pull 2>&1)
        echo -e "\033[1;34m==> $proj\033[0m\n$result"
      ) &
      pids+=($!)
    else
      echo -e "\033[1;33m==> Skipping: $proj (Not a git repo)\033[0m"
    fi
  done

  for pid in "${pids[@]}"; do
    wait $pid
  done

  # 自动执行 dotfiles 安装脚本
  local dotfiles_dir="$HOME/dotfiles"
  if [ -f "$dotfiles_dir/install.sh" ]; then
    echo -e "\033[1;32m==> Running dotfiles install.sh...\033[0m"
    sh "$dotfiles_dir/install.sh"
  fi
}

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export | unset) fzf --preview "eval 'echo \$' {}" "$@" ;;
    ssh) fzf --preview 'dig {}' "$@" ;;
    *) fzf --preview 'bat -n --color=always --line-range :500 {}' "$@" ;;
  esac
}

# tab 补全
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

conf() {
  local conf_dirs=(
    "$HOME/dotfiles"
    "$HOME/.config/opencode"
    "$HOME/xiaoli-nvim"
  )
  local conf_files=(
    "$HOME/.zshrc"
    "$HOME/GUI_Agent_Platform/mprocs.json"
  )

  local selected
  selected=$({
    for dir in "${conf_dirs[@]}"; do
      [[ -d "$dir" ]] && fd --type f --hidden \
        --exclude '{.git,node_modules,*.lock,*lock.json,js-debug}' \
        '\.(json|toml|zsh|rgignore|yml)$|(gitconfig|attributes)$' "$dir"
    done
    for f in "${conf_files[@]}"; do
      [[ -f "$f" ]] && echo "$f"
    done
  } | sed "s|^$HOME/||" | sort | fzf --prompt="Configuration ❯ " \
    --preview "bat -n --color=always --line-range :500 $HOME/{}") || return 0

  [[ -n "$selected" ]] && ${EDITOR:-nvim} "$HOME/$selected"
}

lss() {
  eza -la --no-filesize --no-time --no-user --git | rg -i "$@"
}

tree() {
  command tree -C -L 2 -a -I "node_modules" "$@"
}

ii() {
  cd ~/dotfiles && sh install.sh
}

vim() {
  # 1.无参数打开当前目录
  if [ $# -eq 0 ]; then
    nvim
    return
  fi

  # 2.参数包含路径格式或者. -> (vim .)
  if [[ "$*" == *"/"* ]] || [[ "$*" == *"."* ]]; then
    nvim "$@"
    return
  fi

  # 3.zoxide 路径跳转
  local matches
  matches=$(zoxide query --list "$@" 2>/dev/null | rg -v '\.local|\.cache|node_modules')

  if [ -n "$matches" ]; then
    local dir
    dir=$(echo "$matches" | fzf --height=40% --layout=reverse --border --select-1 --exit-0 --prompt='Select > ')

    if [ -n "$dir" ]; then
      cd "$dir" && nvim
    fi
    return
  else
    echo "zoxide: no match found"
  fi
}
