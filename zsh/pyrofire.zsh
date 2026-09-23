_pyrofire_enter() {
  local tty=/dev/tty
  [[ -t 1 && -r $tty && -w $tty ]] || return 1

  printf '\033[?1049h\033[H\033[2J' >$tty
}

_pyrofire_play() {
  command pyroclear >/dev/tty 2>/dev/null
}

_pyrofire_leave() {
  printf '\033[0m\033[?25h\033[?1049l' >/dev/tty
}

# Show only pyroclear's fire animation; keep the main terminal untouched.
pyrofire() {
  if _pyrofire_enter; then
    _pyrofire_play
    local pyrofire_status=$?
    _pyrofire_leave
    return $pyrofire_status
  fi
}

_pyrofire_command() {
  local target=$1
  shift

  if ! _pyrofire_enter; then
    command "$target" "$@"
    return $?
  fi

  # Interactive programs cannot be preloaded safely without a separate PTY.
  # Keep both phases on this buffer so the main terminal is never cleared.
  _pyrofire_play
  command "$target" "$@"
  local command_status=$?
  _pyrofire_leave
  return $command_status
}
