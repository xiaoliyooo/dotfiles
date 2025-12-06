#!/bin/bash

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

mkdir -p ~/.config/kitty
mkdir -p ~/.config/lazygit
mkdir -p ~/.config/git

ln -sf ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -sf ~/dotfiles/lazygit/lazygit_config.yml ~/.config/lazygit/config.yml
ln -sf ~/dotfiles/git/attributes ~/.config/git/attributes

echo "🔗 配置文件链接完成..."

echo "✅ 安装完成！"

