export PATH="/opt/homebrew/bin:$PATH" # 强制 Homebrew 的 bin 目录排在系统路径之前 覆盖bash版本
export PATH="$HOME/.local/bin:$PATH"

export https_proxy="http://127.0.0.1:7897"
export http_proxy="http://127.0.0.1:7897"
export all_proxy="socks5://127.0.0.1:7897"

export TIME_STYLE="+%Y-%m-%d %H:%M"

export TEALDEER_CONFIG_DIR="$HOME/.config/tealdeer"

export EDITOR=nvim

# Ctrl+T 搜索文件
export FZF_CTRL_T_COMMAND="fd --type f --follow --exclude '{.git,node_modules,*.lock,*lock.json,js-debug,.zsh_sessions,apps,awrit,Library,Pictures}'"
# 预览时现实相对路径，插入转换为绝对路径
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}' --bind 'enter:become(zsh -c '\\''print -rl -- \${@:a}'\\'' -- {+})'"
# Ctrl+D 搜索目录
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
export FZF_COMPLETION_TRIGGER='xx'

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

export MANPAGER="nvim +Man!"

export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('ni' 'nlx' 'nr' 'nun' 'nup')

export NVM_DIR="$HOME/.nvm"

export LS_COLORS="$(vivid generate nord)"

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
