#!/bin/bash

# 定义变量
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_if_missing() {
  local cmd="$1"
  local package="${2:-$1}"

  if command_exists "$cmd"; then
    echo "✓ $cmd 已安装"
  else
    echo "⚠ $cmd 未找到，正在安装 $package..."
    brew install "$package"

    if [ "$package" = "yazi" ]; then
      ya pkg add yazi-rs/plugins:full-border
    fi

    if [ "$cmd" = "opencode" ]; then
      echo "📦 安装 oh-my-opencode..."
      (cd "$CONFIG_DIR/opencode" && bun i oh-my-opencode@3.0.0-beta.6)
      echo "✓ oh-my-opencode 安装完成"
    fi
  fi
}

install_tdf_if_missing() {
  local cmd="tdf"
  local package="$cmd"

  if command_exists "$cmd"; then
    echo "✓ $cmd 已安装"
  else
    echo "⚠ $cmd 未找到，正在安装 $package..."
    cargo install --git https://github.com/itsjunetime/tdf.git
  fi
}

install_zsh_theme() {
  local repo_url="$1"
  local theme_name="$2"
  local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/$theme_name"

  if [ ! -d "$theme_dir" ]; then
    echo "📦 安装 $theme_name"
    git clone "$repo_url" "$theme_dir"
    echo "✓ $theme_name 主题安装完成"
  else
    echo "✓ $theme_name 主题已存在"
  fi
}

install_zsh_plugin() {
  local repo_url="$1"
  local plugin_name="$2"
  local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"

  if [ ! -d "$plugin_dir" ]; then
    echo "📦 安装 $plugin_name"
    git clone "$repo_url" "$plugin_dir"
    echo "✓ $plugin_name 插件安装完成"
  else
    echo "✓ $plugin_name 插件已存在"
  fi
}

install_brew_if_missing() {
  if command_exists "brew"; then
    echo "✓ Homebrew 已安装"
  else
    echo "⚠ Homebrew 未找到，正在安装..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

install_kitty_if_missing() {
  if command_exists "kitty"; then
    echo "✓ kitty 已安装"
  else
    echo "⚠ kitty 未找到，正在安装..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  fi
}

echo "🚀 开始安装 dotfiles..."

ln -sf "$DOTFILES_DIR/bun/.bunfig.toml" "$HOME/.bunfig.toml"

install_brew_if_missing
install_rust_if_missing
install_nvm_if_missing
install_pip3_if_missing
install_kitty_if_missing
install_npm_if_missing "pnpm"
install_npm_if_missing "prettier"
install_npm_if_missing "tsc" "typescript"
install_npm_if_missing "bun"
install_if_missing "git"
install_if_missing "bat"
install_if_missing "delta"
install_if_missing "eza"
install_if_missing "nvim" "neovim"
install_if_missing "gdate" "coreutils"
install_if_missing "mcfly"
install_if_missing "mergiraf"
install_if_missing "starship"
install_if_missing "lazygit"
install_if_missing "nvr" "neovim-remote"
install_if_missing "less"
install_if_missing "zoxide"
install_if_missing "yazi"
install_if_missing "fzf"
install_if_missing "fd"
install_if_missing "tokei"
install_if_missing "fastfetch"
install_if_missing "mprocs"
install_if_missing "git-summary" "git-extras"
install_if_missing "gemini" "gemini-cli"
install_if_missing "opencode" "anomalyco/tap/opencode"

#   ━━━━━━━━━━━━━━━━━━━━ neovim formatter/linter start ━━━━━━━━━━━━━━━━━━
install_if_missing "stylua"
install_if_missing "shfmt"
install_if_missing "shellcheck"
install_if_missing "taplo"
install_if_missing "ruff"
#   ━━━━━━━━━━━━━━━━━━━━━ neovim formatter/linter end ━━━━━━━━━━━━━━━━━━━
install_tdf_if_missing

rm -rf "$CONFIG_DIR/kitty"
mkdir -p "$CONFIG_DIR/lazygit"
mkdir -p "$CONFIG_DIR/git"
mkdir -p "$CONFIG_DIR/yazi"
mkdir -p "$CONFIG_DIR/fastfetch"
mkdir -p "$CONFIG_DIR/opencode"

ln -sf "$DOTFILES_DIR/kitty" "$CONFIG_DIR/kitty"
ln -sf "$DOTFILES_DIR/lazygit/lazygit_config.yml" "$CONFIG_DIR/lazygit/config.yml"
ln -sf "$DOTFILES_DIR/git/attributes" "$CONFIG_DIR/git/attributes"
ln -sf "$DOTFILES_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml"
ln -sf "$DOTFILES_DIR/less/.lesskey" "$HOME/.lesskey"
ln -sf "$DOTFILES_DIR/yazi/keymap.toml" "$CONFIG_DIR/yazi/keymap.toml"
ln -sf "$DOTFILES_DIR/yazi/theme.toml" "$CONFIG_DIR/yazi/theme.toml"
ln -sf "$DOTFILES_DIR/yazi/yazi.toml" "$CONFIG_DIR/yazi/yazi.toml"
ln -sf "$DOTFILES_DIR/yazi/init.lua" "$CONFIG_DIR/yazi/init.lua"
ln -sf "$DOTFILES_DIR/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/config.jsonc"
ln -sf "$DOTFILES_DIR/fastfetch/ascii.txt" "$CONFIG_DIR/fastfetch/ascii.txt"
ln -sf "$DOTFILES_DIR/mprocs" "$CONFIG_DIR/mprocs"

install_zsh_plugin "https://github.com/Aloxaf/fzf-tab" "fzf-tab"
install_zsh_plugin "https://github.com/zsh-users/zsh-autosuggestions" "zsh-autosuggestions"
install_zsh_plugin "https://github.com/zsh-users/zsh-completions.git" "zsh-completions"
install_zsh_plugin "https://github.com/marlonrichert/zsh-autocomplete" "zsh-autocomplete"
install_zsh_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "zsh-syntax-highlighting"
install_zsh_plugin "https://github.com/jeffreytse/zsh-vi-mode" "zsh-vi-mode"
install_zsh_plugin "https://github.com/grigorii-zander/zsh-npm-scripts-autocomplete" "zsh-npm-scripts-autocomplete"

install_zsh_theme "https://github.com/romkatv/powerlevel10k.git" "powerlevel10k"

echo "🔗 配置文件链接完成..."

echo "✅ 安装完成！"
