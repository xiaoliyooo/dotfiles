alias reload='exec zsh'
alias zshc='vim ~/.zshrc'
alias y='yazi'
alias ge='gemini'
alias j='z'

alias ls="eza -la --icons --no-filesize --no-time --no-user --git"
alias vim="nvim"

alias cat="bat"

alias date='gdate "+%Y-%m-%d %H:%M:%S %A"'
alias dt='date'

if command -v tdf >/dev/null 2>&1; then
  alias pdf='tdf'
fi
