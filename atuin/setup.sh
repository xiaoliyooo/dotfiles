#!/bin/bash

atuin_version_at_least() {
  local version="$1" major minor patch

  [[ "$version" =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]] || return 1
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  patch="${BASH_REMATCH[3]}"
  ((major > 18 || (major == 18 && minor > 23) || (\
  major == 18 && minor == 23 && patch >= 0)))
}

atuin_auto_upgrade_supported() {
  local macos_version major

  macos_version="$(sw_vers -productVersion 2>/dev/null)" || return 1
  major="${macos_version%%.*}"
  [[ "$major" =~ ^[0-9]+$ ]] || return 1
  ((major >= 15))
}

ensure_atuin_version() {
  local version atuin_bin

  if command -v atuin >/dev/null 2>&1; then
    atuin_bin="$(command -v atuin)"
  elif brew list --formula atuin >/dev/null 2>&1 &&
    [ -x "$(brew --prefix atuin)/bin/atuin" ]; then
    atuin_bin="$(brew --prefix atuin)/bin/atuin"
  else
    brew update || return 1
    brew install atuin || return 1
    hash -r
    atuin_bin="$(command -v atuin)" || return 1
  fi

  version="$("$atuin_bin" --version)" || return 1
  if [[ ! "$version" =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    echo "⚠ 无法识别 Atuin 版本: $version" >&2
    return 1
  fi

  if ! atuin_version_at_least "$version"; then
    if atuin_auto_upgrade_supported; then
      echo "📦 Atuin $version 低于 18.23.0，正在升级..."
      if brew list --formula atuin >/dev/null 2>&1; then
        brew update || return 1
        brew upgrade atuin || return 1
      else
        brew install atuin || return 1
      fi
      hash -r
      atuin_bin="$(brew --prefix atuin)/bin/atuin"
      version="$("$atuin_bin" --version)" || return 1
      if ! atuin_version_at_least "$version"; then
        echo "⚠ Atuin 升级后仍低于 18.23.0: $version" >&2
        return 1
      fi
    else
      echo "⚠ Atuin $version 低于 18.23.0，当前 macOS 版本已跳过自动升级" >&2
    fi
  fi

  echo "✓ $version"
}

setup_atuin() {
  local config_dir="$1" atuin_dir="$2"

  ensure_atuin_version || return 1
  mkdir -p "$config_dir/atuin" || return 1
  ln -sf "$atuin_dir/config.toml" "$config_dir/atuin/config.toml" || return 1

  local launch_agent="$HOME/Library/LaunchAgents/com.atuin.daemon.plist"
  local launcher="$HOME/.local/bin/atuin-daemon-start"

  if [ -e "$launch_agent" ] || [ -L "$launch_agent" ]; then
    launchctl bootout "gui/$(id -u)/com.atuin.daemon" 2>/dev/null || true
    rm -f "$launch_agent" || return 1
  fi

  if [ -e "$launcher" ] || [ -L "$launcher" ]; then
    rm -f "$launcher" || return 1
  fi
}
