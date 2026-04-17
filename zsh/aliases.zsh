alias zshc='vim ~/.zshrc'
alias y='yazi'
alias ge='gemini'
alias j='z'

alias ls="eza -la --no-filesize --no-user --git --group-directories-first"

alias clear='printf "\033[2J\033[3J\033[H"'
alias cat="nvimpager"
alias top="btop"
alias vim="nvim"

alias date='gdate "+%Y-%m-%d %H:%M:%S %A"'
alias dt='date'

alias kp="killport"
alias repo="onefetch --churn-pool-size 1000 --number-of-file-churns 15"

alias difftree='GIT_EXTERNAL_DIFF=difft git diff'

alias c='pbcopy'
# alias p='pbpaste'

alias -g G='| rg'
alias -g N='| wc -l'
alias -g C='| tee >(pbcopy)'

alias tq='curl "wttr.in/北京朝阳区?lang=zh-cn"'
