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

3. 如果执行 `git effort` 报错 `/opt/homebrew/bin/git-effort: line 273:  ${nJobs@P} >= nProcs : bad substitution`，因为MacOS 捆绑的 `/bin/bash` 版本 3.2.57太低了，不支持 `${parameter@P}`。执行 `brew install bash` 更新到4.0+。
