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
