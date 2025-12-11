# dotfiles

1. 为zsh配置文件增加如下引用：

```bash

# .zshrc
export ZDOTDIR="$HOME/dotfiles/zsh"
# ...code
[[ -f "$ZDOTDIR/.zshrc" ]] && source "$ZDOTDIR/.zshrc"
```

2. 为全局git配置文件 `~/.gitconfig` 增加下面引用：

```bash
[include]
   path = ~/dotfiles/git/gitconfig
```

3. 如果执行 `git effort` 报错，执行 `brew install bash`
