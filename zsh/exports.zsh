export PATH="/opt/homebrew/bin:$PATH" # 强制 Homebrew 的 bin 目录排在系统路径之前 覆盖bash版本
export https_proxy="http://127.0.0.1:7897"
export http_proxy="http://127.0.0.1:7897"
export all_proxy="socks5://127.0.0.1:7897"

export EZA_CONFIG_DIR="$HOME/.config/nvim/eza/themes"

export MCFLY_KEY_SCHEME=emacs # 主要为了<C-w>删除单词
export MCFLY_FUZZY=2

export EDITOR=nvim

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
export FZF_COMPLETION_TRIGGER='j'

export LIGHT_GREEN="#0bf432" # 注释绿色

export FZF_DEFAULT_OPTS="
  --preview 'eza --tree --color=always {} | head -200'
  --style full
  --padding 1,2
  --input-label ' Keyword '
  --bind 'result:transform-list-label:
      if [[ -z \$FZF_QUERY ]]; then
        echo \" \$FZF_MATCH_COUNT items \"
      else
        echo \" \$FZF_MATCH_COUNT matches for [\$FZF_QUERY] \"
      fi
      '
  --bind 'focus:transform-preview-label:[[ -n {} ]] && printf \" Previewing [%s] \" {}'
  --color 'label:#cccccc'
  --color 'preview-border:#9999cc,preview-label:#ccccff'
  --color 'list-border:#9999cc,list-label:#ccccff'
  --color 'input-border:#9999cc,input-label:#ccccff'
  --color=hl:#14c0ff,hl+:$LIGHT_GREEN,prompt:$LIGHT_GREEN,pointer:$LIGHT_GREEN
"


# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANPAGER="nvim +Man!"

export NVM_DIR="$HOME/.nvm"

