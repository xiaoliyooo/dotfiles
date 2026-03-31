#!/bin/bash

# 定义变量
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
source "$DOTFILES_DIR/local/index.zsh"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

link_dir() {
  local src="$DOTFILES_DIR/$1"
  local dest="$CONFIG_DIR/$1"
  [ -d "$dest" ] && [ ! -L "$dest" ] && rm -rf "$dest"
  ln -sfn "$src" "$dest"
}

link_git_scripts() {
  echo "🔗 正在链接 git 脚本..."
  local git_scripts_dir="$DOTFILES_DIR/git"
  local bin_dir="$HOME/.local/bin"

  mkdir -p "$bin_dir"

  for script in "$git_scripts_dir"/git-*; do
    if [ -f "$script" ]; then
      local script_name=$(basename "$script")
      local subcmd=${script_name#git-}

      if git --list-cmds=main,alias | grep -q "^$subcmd$"; then
        echo "  ⚠️  Git 子命令 '$subcmd' 已存在(内置或别名)，跳过链接 $script_name"
        continue
      fi

      ln -sf "$script" "$bin_dir/$script_name"
      chmod +x "$script"
      echo "  ✓ Linked $script_name"
    fi

  done
}

install_if_missing() {
  local cmd="$1"
  local package="${2:-$1}"

  if command_exists "$cmd"; then
    echo "✓ $cmd 已安装"
  else
    echo "⚠ $cmd 未找到，正在安装 $package..."

    if [ "$package" = "im-select" ]; then
      install_tap_if_missing "daipeihust/tap"
    fi

    brew install "$package"

    if [ "$cmd" = "opencode" ]; then
      echo "📦 安装 oh-my-opencode..."
      (cd "$CONFIG_DIR/opencode" && bun i oh-my-opencode@3.0.0-beta.6)
      echo "✓ oh-my-opencode 安装完成"
    fi

    if [ "$package" = "tealdeer" ]; then
      tldr --update
    fi

    if [ "$package" = "kitty" ]; then
      replace_kitty_icon
    fi

    if [ "$package" = "git-lfs" ]; then
      git lfs install
    fi
  fi
}

install_yazi_plugins() {
  local yazi_plugins_dir="$CONFIG_DIR/yazi/plugins"
  mkdir -p "$yazi_plugins_dir"

  local plugins=(
    "yazi-rs/plugins:full-border"
    "yazi-rs/plugins:smart-enter"
    "yazi-rs/plugins:chmod"
  )

  for plugin in "${plugins[@]}"; do
    local plugin_name="${plugin##*:}"
    local plugin_dir="$yazi_plugins_dir/${plugin_name}.yazi"

    if [ -d "$plugin_dir" ]; then
      echo "✓ yazi 插件 $plugin_name 已安装"
    else
      echo "📦 安装 yazi 插件 $plugin_name..."
      # 防止目录不存在但package.toml中仍有记录
      ya pkg delete "$plugin" 2>/dev/null || true
      ya pkg add "$plugin"
    fi
  done

  ln -sfn "$DOTFILES_DIR/yazi/plugins/smart-rename.yazi" "$CONFIG_DIR/yazi/plugins/smart-rename.yazi"
}

install_zinit_if_missing() {
  local zinit_home="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

  if [ -f "$zinit_home/zinit.zsh" ]; then
    echo "✓ zinit 已安装"
  else
    echo "📦 安装 zinit..."
    mkdir -p "$(dirname "$zinit_home")"
    git clone https://github.com/zdharma-continuum/zinit.git "$zinit_home"
    echo "✓ zinit 安装完成"
  fi
}

install_zinit_plugins() {
  echo "📦 安装 zinit 插件..."
  zsh -i -c "@zinit-scheduler burst" 2>/dev/null || true
  echo "✓ zinit 插件安装完成"
}

install_brew_if_missing() {
  if command_exists "brew"; then
    echo "✓ Homebrew 已安装"
  else
    echo "⚠ Homebrew 未找到，正在安装..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

install_tap_if_missing() {
  local tap_name="$1"

  if brew tap | grep -qx "$tap_name"; then
    echo "✓ tap $tap_name 已存在"
  else
    echo "📦 添加 Homebrew tap: $tap_name"
    brew tap "$tap_name"
  fi
}

install_rust_if_missing() {
  if command_exists "rustc"; then
    echo "✓ Rust 已安装"
  else
    echo "⚠ Rust 未找到，正在安装..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  fi
}

install_pip3_if_missing() {
  if command_exists "pip3"; then
    echo "✓ pip3 已安装"
  else
    echo "⚠ pip3 未找到，正在通过 Homebrew 安装 Python..."
    brew install python
  fi
}

install_pipx_package_if_missing() {
  local cmd="$1"
  local package="${2:-$1}"

  if command_exists "$cmd"; then
    echo "✓ $cmd 已安装"
  else
    echo "⚠ $cmd 未找到，正在通过 pipx 安装 $package..."
    pipx install "$package"
  fi
}

install_nvm_if_missing() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  if command_exists "nvm"; then
    echo "✓ nvm 已安装"
  else
    echo "⚠ nvm 未找到，正在安装..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  fi
}

install_npm_if_missing() {
  local cmd="$1"
  local package="${2:-$1}"

  if command_exists "$cmd"; then
    echo "✓ $cmd 已安装"
  else
    echo "⚠ $cmd 未找到，正在安装 $package..."
    npm i -g "$package"
  fi
}

replace_kitty_icon() {
  # https://github.com/DinkDonk/kitty-icon
  local icon_source="$DOTFILES_DIR/kitty/kitty-dark.icns"
  local kitty_app="/Applications/kitty.app"
  local icon_dest="$kitty_app/Contents/Resources/kitty.icns"

  if [ ! -d "$kitty_app" ]; then
    echo "⚠ kitty.app 未找到，跳过图标替换"
    return
  fi

  if [ ! -f "$icon_source" ]; then
    echo "⚠ kitty-dark.icns 未找到，跳过图标替换"
    return
  fi

  if cmp -s "$icon_source" "$icon_dest"; then
    echo "✓ kitty 图标已是最新"
    return
  fi

  echo "🎨 替换 kitty 图标..."
  cp "$icon_source" "$icon_dest"

  rm -rf /var/folders/*/*/*/com.apple.dock.iconcache 2>/dev/null || true
  killall Dock 2>/dev/null || true

  # 触发 Finder 刷新应用图标
  touch "$kitty_app"

  echo "✓ kitty 图标替换完成"
}

install_cask_if_missing() {
  local cask_name="$1"

  if brew list --cask "$cask_name" &>/dev/null; then
    echo "✓ $cask_name 已安装"
  else
    echo "⚠ $cask_name 未找到，正在安装..."
    brew install --cask "$cask_name"
  fi
}

install_app_if_missing() {
  local app_name="$1"
  local cask_name="$2"

  if [ -d "/Applications/$app_name.app" ]; then
    echo "✓ $app_name 已安装"
  else
    echo "⚠ $app_name 未找到，正在安装..."

    if [ "$cask_name" = "keystats" ]; then
      install_tap_if_missing "debugtheworldbot/keystats"
    fi

    brew install --cask "$cask_name"
  fi
}

install_font_if_missing() {
  local font_file="$1"
  local font_name="${font_file%.ttf}"

  if [ -f "$HOME/Library/Fonts/$font_file" ]; then
    echo "✓ $font_name 字体已安装"
  else
    echo "⚠ $font_name 字体未找到，正在安装..."
    cp "$DOTFILES_DIR/fonts/$font_file" "$HOME/Library/Fonts/"
  fi
}

clone_apps_repo() {
  local apps_dir="$HOME/apps"

  if [ -d "$apps_dir" ]; then
    echo "✓ apps 仓库已存在"
  else
    echo "📦 克隆 apps 仓库..."
    git clone https://github.com/xiaoliyooo/apps "$apps_dir"
    echo "✓ apps 仓库克隆完成"
  fi
}

install_from_dmg() {
  local dmg_path="$1"
  local filename=$(basename "$dmg_path")
  # 文件名格式: 软件名_版本.dmg
  local app_name="${filename%%_*}"

  if [ -d "/Applications/$app_name.app" ]; then
    echo "✓ $app_name 已安装"
    return 0
  fi

  echo "⚠ 正在从 dmg 安装 $app_name..."

  local mount_output=$(yes | hdiutil attach "$dmg_path" -nobrowse -noautoopen -noverify 2>/dev/null)
  local mount_point=$(echo "$mount_output" | grep "/Volumes" | sed 's/.*\(\/Volumes\/.*\)/\1/' | head -1)

  if [ -z "$mount_point" ]; then
    echo "✗ 无法挂载 $dmg_path"
    return 1
  fi

  if ls "$mount_point"/*.app 1>/dev/null 2>&1; then
    cp -Rf "$mount_point"/*.app /Applications/
    echo "✓ $app_name 安装完成"
  else
    echo "⚠ $mount_point 中未找到 .app 文件"
  fi
}

scan_and_install_dmgs() {
  local dir="$1"

  if [ ! -d "$dir" ]; then
    echo "⚠ 目录不存在: $dir"
    return 1
  fi

  for item in "$dir"/*; do
    if [ -d "$item" ]; then
      scan_and_install_dmgs "$item"
    elif [ -f "$item" ] && [[ "$item" == *.dmg ]]; then
      install_from_dmg "$item"
    fi
  done
}

echo "🚀 开始安装 dotfiles..."

# 禁用系统默认英文 "Last login:" 消息
[[ ! -e "$HOME/.hushlogin" ]] && touch "$HOME/.hushlogin"

ln -sf "$DOTFILES_DIR/bun/.bunfig.toml" "$HOME/.bunfig.toml"

install_brew_if_missing
install_rust_if_missing
install_nvm_if_missing
install_pip3_if_missing
install_zinit_if_missing
install_zinit_plugins
install_font_if_missing "JetBrainsMonoNL-Bold.ttf"
install_cask_if_missing "font-fira-code"
install_cask_if_missing "font-fira-code-nerd-font"
install_cask_if_missing "hammerspoon"
install_npm_if_missing "tsc" "typescript"
install_npm_if_missing "bun"
install_if_missing "pipx"
install_if_missing "kitty"
install_if_missing "prettier"
install_if_missing "pnpm"
install_if_missing "git"
install_if_missing "bat"
install_if_missing "delta"
install_if_missing "eza"
install_if_missing "tree"
install_if_missing "nvim" "neovim"
install_if_missing "nvimpager"
install_if_missing "gdate" "coreutils"
install_if_missing "mergiraf"
install_if_missing "starship"
install_if_missing "lazygit"
install_if_missing "nvr" "neovim-remote"
install_if_missing "less"
install_if_missing "zoxide"
install_if_missing "yazi"
install_if_missing "7zz" "sevenzip"
install_if_missing "fzf"
install_if_missing "fd"
install_if_missing "tokei"
install_if_missing "mprocs"
install_if_missing "git-summary" "git-extras"
install_if_missing "git-absorb"
install_if_missing "difft" "difftastic"
install_if_missing "git-lfs"
install_if_missing "git-imerge"
install_if_missing "gemini" "gemini-cli"
install_if_missing "opencode" "anomalyco/tap/opencode"
install_if_missing "im-select"
install_if_missing "ttyd"
install_if_missing "ni"
install_if_missing "killport"
install_if_missing "onefetch"
install_if_missing "atuin"
install_if_missing "tldr" "tealdeer"
install_if_missing "vivid"
install_if_missing "carapace"
install_if_missing "btop"
install_if_missing "dust"
install_if_missing "magick" "imagemagick"
install_if_missing "rg" "ripgrep"
install_if_missing "rust-analyzer"
install_pipx_package_if_missing "starcli"

#   ━━━━━━━━━━━━━━━━━━━━ neovim formatter/linter start ━━━━━━━━━━━━━━━━━━
install_if_missing "stylua"
install_if_missing "shfmt"
install_if_missing "shellcheck"
install_if_missing "taplo"
install_if_missing "ruff"
install_if_missing "sql-formatter"
#   ━━━━━━━━━━━━━━━━━━━━━ neovim formatter/linter end ━━━━━━━━━━━━━━━━━━━

mkdir -p "$CONFIG_DIR/lazygit"
mkdir -p "$CONFIG_DIR/git"
mkdir -p "$CONFIG_DIR/yazi"
mkdir -p "$CONFIG_DIR/opencode"
mkdir -p "$CONFIG_DIR/atuin"
mkdir -p "$CONFIG_DIR/btop"

ln -sf "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
[ -d "$HOME/.hammerspoon" ] && [ ! -L "$HOME/.hammerspoon" ] && rm -rf "$HOME/.hammerspoon"
ln -sfn "$DOTFILES_DIR/hammerspoon" "$HOME/.hammerspoon"
ln -sf "$DOTFILES_DIR/lazygit/lazygit_config.yml" "$CONFIG_DIR/lazygit/config.yml"
ln -sf "$DOTFILES_DIR/git/attributes" "$CONFIG_DIR/git/attributes"
ln -sf "$DOTFILES_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml"
ln -sf "$DOTFILES_DIR/less/.lesskey" "$HOME/.lesskey"
ln -sf "$DOTFILES_DIR/yazi/keymap.toml" "$CONFIG_DIR/yazi/keymap.toml"
ln -sf "$DOTFILES_DIR/yazi/theme.toml" "$CONFIG_DIR/yazi/theme.toml"
ln -sf "$DOTFILES_DIR/yazi/yazi.toml" "$CONFIG_DIR/yazi/yazi.toml"
ln -sf "$DOTFILES_DIR/yazi/init.lua" "$CONFIG_DIR/yazi/init.lua"
ln -sf "$DOTFILES_DIR/atuin/config.toml" "$CONFIG_DIR/atuin/config.toml"
setup_local

link_dir "kitty"
link_dir "tealdeer"
link_dir "mprocs"
link_dir "bat"
link_dir "btop"

echo "🔗 配置 nvimpager..."
ln -sfn "$CONFIG_DIR/nvim" "$CONFIG_DIR/nvimpager"
mkdir -p "$HOME/.local/share"
ln -sfn "$HOME/.local/share/nvim" "$HOME/.local/share/nvimpager"

link_git_scripts

echo "🔗 配置文件链接完成..."

install_app_if_missing "WeChat" "wechat"
install_app_if_missing "QQMusic" "qqmusic"
install_app_if_missing "NeteaseMusic" "neteasemusic"
install_app_if_missing "Google Chrome" "google-chrome"
install_app_if_missing "Firefox" "firefox"
install_app_if_missing "元宝" "yuanbao"
install_app_if_missing "Obsidian" "obsidian"
install_app_if_missing "Karabiner-Elements" "karabiner-elements"
install_app_if_missing "Docker" "docker"
install_app_if_missing "wpsoffice" "wpsoffice"
install_app_if_missing "Clash Verge" "clash-verge-rev"
install_app_if_missing "PixPin" "pixpin"
install_app_if_missing "SwitchHosts" "switchhosts"
install_app_if_missing "Ice" "jordanbaird-ice"
install_app_if_missing "Tencent Lemon" "tencent-lemon"
install_app_if_missing "Visual Studio Code" "visual-studio-code"
install_app_if_missing "AltTab" "alt-tab"
install_app_if_missing "KeyStats" "keystats"

clone_apps_repo
scan_and_install_dmgs "$HOME/apps/app-dmg"

install_yazi_plugins

echo "✅ 安装完成！"
