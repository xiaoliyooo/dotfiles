ZSH_THEME="robbyrussell"
# ZSH_THEME="powerlevel10k/powerlevel10k"

function compinit() {
  local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
  local zcompdump_zwc="${zcompdump}.zwc"

  # Unset this wrapper function so we can load the real compinit
  unfunction compinit
  autoload -Uz compinit

  # Check if zcompdump is fresh (< 20h)
  if [[ -n ${zcompdump}(#qN.mh-20) ]]; then
    # Cache is valid, skip security checks (-C) for speed
    compinit -C -d "$zcompdump"
  else
    # Cache is old or missing, run full checks (-i) and update (-u)
    # We ignore the arguments passed by oh-my-zsh.sh (usually -i or -u) 
    # and strictly use our logic, but we could pass "$@" if we wanted to be safer.
    # However, OMZ passes specific flags we might want to override.
    compinit -i -d "$zcompdump"
    
    # Background compilation of zcompdump for faster loading next time
    {
      if [[ -f "$zcompdump" ]]; then
        if [[ ! -f "$zcompdump_zwc" || "$zcompdump" -nt "$zcompdump_zwc" ]]; then
           zcompile "$zcompdump"
        fi
      fi
    } &!
  fi
}

plugins=(
  git
  autojump
  # fzf-tab 和 zsh-autocomplete 二选一
  zsh-autocomplete
  zsh-autosuggestions
  zsh-completions
  copypath
  copyfile
  zsh-vi-mode
  zsh-syntax-highlighting
)
