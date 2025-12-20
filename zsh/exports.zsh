export PATH="/opt/homebrew/bin:$PATH" # 强制 Homebrew 的 bin 目录排在系统路径之前 覆盖bash版本
export https_proxy="http://127.0.0.1:7897"
export http_proxy="http://127.0.0.1:7897"
export all_proxy="socks5://127.0.0.1:7897"

export EZA_CONFIG_DIR="$HOME/.config/nvim/eza/themes"

export MCFLY_KEY_SCHEME=emacs # 主要为了<C-w>删除单词
export MCFLY_FUZZY=2

export EDITOR=nvim

# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANPAGER="nvim +Man!"

export NVM_DIR="$HOME/.nvm"

