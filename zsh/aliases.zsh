alias reload='. ~/.zshrc'
alias zshc='vim ~/.zshrc'
alias y='yazi'
alias ge='gemini'

if command -v eza >/dev/null 2>&1; then
    alias ls="eza -la"
else
    alias ls="ls -la"
fi

if command -v nvim >/dev/null 2>&1; then
    alias vim="nvim"
fi

if command -v bat >/dev/null 2>&1; then
    alias cat="bat"
fi

if command -v gdate >/dev/null 2>&1; then
    alias date='gdate "+%Y-%m-%d %H:%M:%S %A"'
    alias dt='date'
fi

if command -v tdf >/dev/null 2>&1; then
    alias pdf='tdf'
fi

