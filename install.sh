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
    fi
}

echo "🚀 开始安装 dotfiles..."

install_if_missing "bat"
install_if_missing "eza"
install_if_missing "nvim" "neovim"
install_if_missing "gdate" "coreutils"
install_if_missing "mcfly"
install_if_missing "mergiraf"
install_if_missing "starship"
install_if_missing "lazygit"

mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$CONFIG_DIR/lazygit"
mkdir -p "$CONFIG_DIR/git"

ln -sf "$DOTFILES_DIR/kitty/kitty.conf" "$CONFIG_DIR/kitty/kitty.conf"
ln -sf "$DOTFILES_DIR/lazygit/lazygit_config.yml" "$CONFIG_DIR/lazygit/config.yml"
ln -sf "$DOTFILES_DIR/git/attributes" "$CONFIG_DIR/git/attributes"
ln -sf "$DOTFILES_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml"

echo "🔗 配置文件链接完成..."

echo "✅ 安装完成！"

