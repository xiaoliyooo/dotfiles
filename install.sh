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


install_awrit_if_missing() {
    local cmd="awrit"
    local package="$cmd"
    
    if command_exists "$cmd"; then
        echo "✓ $cmd 已安装"
    else
        echo "⚠ $cmd 未找到，正在安装 $package..."
        curl -fsS https://chase.github.io/awrit/get | bash
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
install_if_missing "less"
install_if_missing "zoxide"
install_if_missing "yazi"
install_if_missing "fzf"
install_if_missing "fastfetch"
install_if_missing "git-summary" "git-extras"
install_awrit_if_missing
install_tdf_if_missing

mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$CONFIG_DIR/lazygit"
mkdir -p "$CONFIG_DIR/git"
mkdir -p "$CONFIG_DIR/yazi"
mkdir -p "$CONFIG_DIR/fastfetch"

ln -sf "$DOTFILES_DIR/kitty/kitty.conf" "$CONFIG_DIR/kitty/kitty.conf"
ln -sf "$DOTFILES_DIR/lazygit/lazygit_config.yml" "$CONFIG_DIR/lazygit/config.yml"
ln -sf "$DOTFILES_DIR/git/attributes" "$CONFIG_DIR/git/attributes"
ln -sf "$DOTFILES_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml"
ln -sf "$DOTFILES_DIR/less/.lesskey" "$HOME/.lesskey"
ln -sf  "$DOTFILES_DIR/yazi/keymap.toml" "$CONFIG_DIR/yazi/keymap.toml" 
ln -sf  "$DOTFILES_DIR/yazi/theme.toml" "$CONFIG_DIR/yazi/theme.toml" 
ln -sf  "$DOTFILES_DIR/yazi/yazi.toml" "$CONFIG_DIR/yazi/yazi.toml" 
ln -sf  "$DOTFILES_DIR/yazi/init.lua" "$CONFIG_DIR/yazi/init.lua" 
ln -sf  "$DOTFILES_DIR/fastfetch/config.jsonc" "$CONFIG_DIR/fastfetch/config.jsonc" 
ln -sf  "$DOTFILES_DIR/fastfetch/ascii.txt" "$CONFIG_DIR/fastfetch/ascii.txt"

FZF_TAB_DIR="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    echo "📦 安装 fzf-tab"
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
    echo "✓ fzf-tab 插件安装完成"
else
    echo "✓ fzf-tab 插件已存在"
fi

ZSH_COMPLETIONS_DIR="${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions"
if [ ! -d "$FZF_TAB_DIR" ]; then
    echo "📦 安装 zsh-completions"
    git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_COMPLETIONS_DIR"
    echo "✓ zsh-completions 插件安装完成"
else
    echo "✓ zsh-completions 插件已存在"
fi


echo "🔗 配置文件链接完成..."

echo "✅ 安装完成！"

