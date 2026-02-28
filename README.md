# Xiaoli's Dotfiles

> **免责声明**：文档主要由Ai生成，具体功能可以查阅对应文档。

## 项目背景

作为一名前端开发者，我的日常开发和绝大部分工作流程都深度依赖终端环境与 Neovim。为了打造极致的开发体验与工作效率，我构建并开源了这套个人配置文件。该配置专注于追求更快的响应速度和沉浸式的终端体验，它融合了众多现代化的命令行工具，并搭配强大的 Zsh 与 Neovim 整合，以此全面接管日常的编码、版本控制、以及系统管理。

## 核心工作流特性

本配置以“速度快、实用不花哨”为核心，具体特性如下：

### 1. 毫秒级Zsh启动速度

- **按需延迟加载**：利用 Zinit 的 `wait lucid` 机制，将语法高亮、命令补全和 `nvm` 等环境依赖转为后台异步加载，减少首屏启动时间。
- **环境预热**：结合 `bun` 等现代工具链的运行时性能，确保终端环境和别名配置在新建 Tab 时即刻就绪。
- **动态提示符**：配置 `starship` 作为跨多端的终端提示符，针对包含大量提交历史的 Git 目录渲染进行了参数调优。

### 2. 目录跳转

- **基于权重跳转**：使用 `zoxide` 替代 `cd` 命令。在后台记录路径使用频次，通过部分字符匹配实现目录跳转。
- **结构化历史搜索**：配置 `atuin` 接管原生 `Ctrl+R`。历史执行命令被存入 SQLite 数据库，支持跨终端设备同步与查询。
- **并发辅助搜索**：结合 `fzf` 模糊搜索与 `yazi` 终端文件管理器，实现树形结构下的过滤与文件定位。

### 3. 版本管理

- **差异高亮渲染**：引入 `delta` 接管原生 `git diff`，开启 `colorMoved` 功能，对代码重构和移动应用区块颜色标识。
- **抽象语法树比对**：将 `difftastic` 与 `mergiraf` 集成到常规链路中，基于 AST 语法树层面对比代码，滤除格式化引起的非逻辑变动。
- **状态区溯源**：利用 `git-absorb` 自动扫描暂存区变更集，生成对应 `fixup` 分支并挂载至相关联的历史 commit 节点。
- **交互式层级合并**：针对大型冲突合并操作，采用 `git-imerge` 进行增量型分支变基，并结合 `lazygit` 的 TUI 面板执行交互。

### 4. 常用工具链替换

- **基础设施更新**：使用基于 Rust 开发的 `eza`、`bat`、`rg` 和 `fd` 替代系统内置的 `ls`、`cat`、`grep` 与 `find`，提供语法着色和并发查询支持。
- **进程聚合面板**：采用 `mprocs` 作为本地多进程管理工具，将独立服务进程的控制台输出流统一聚合在终端面板内监控。
- **静态质量拦截**：接入 `ruff`、`stylua`、`taplo` 和 `shfmt` 四项静态 linter 工具，对代码提交进行前置格式化拦截；挂载 `ni` 统一抹平包管理器的命令入口差异。

### 5. 快捷键

- **键盘与应用窗口管理**：`karabiner-elements` 键盘快捷键映射。
- **键盘与应用窗口管理**：`alt-tab` 快速切换同一app不同进程。

## 工具列表

本仓库内的 `install.sh` 脚本集成了基础依赖的自动化安装。核心组件如下：

| 工具名称 | 功能说明 |
| :------- | :------- |

### 命令行环境与核心工具

| 工具名称               | 功能说明                                 |
| :--------------------- | :--------------------------------------- |
| **kitty**              | GPU 加速的终端模拟器                     |
| **starship**           | 跨 Shell 的终端提示符                    |
| **vivid**              | `LS_COLORS` 颜色生成工具                 |
| **carapace**           | 跨 Shell 参数补全引擎                    |
| **btop**               | 终端系统资源监控面板                     |
| **bat**                | 带有语法高亮的 `cat` 替代品              |
| **eza**                | 支持颜色和目录树渲染的 `ls` 替代品       |
| **fd**                 | `find` 命令的现代替代品                  |
| **rg (ripgrep)**       | 文本正则内容检索工具                     |
| **tree**               | 目录树状图展示工具                       |
| **tldr**               | 精简版命令行社区使用手册                 |
| **tokei**              | 代码行数统计分析工具                     |
| **dust**               | 命令行磁盘空间可视化工具                 |
| **zinit**              | 支持异步加载的 Zsh 插件管理器            |
| **zoxide**             | 记录频率的终端目录跳转工具               |
| **atuin**              | 基于 SQLite 的全局历史命令搜索同步工具   |
| **fzf**                | 终端命令行模糊搜索器                     |
| **yazi**               | 异步的 TUI 终端文件管理器                |
| **mprocs**             | 多进程统一调度 TUI 日志面板              |
| **ttyd**               | 终端到 Web 的命令行远程接入工具          |
| **lazygit**            | 终端 TUI 模式的 Git 交互面板             |
| **delta**              | 支持语法高亮与代码块移动检查的 Git diff  |
| **difft (difftastic)** | 基于 AST 的代码语法树对比工具            |
| **git-absorb**         | 暂存区代码变更是自动匹配历史 commit 工具 |
| **git-imerge**         | 针对分支冲突的渐进式合并工具             |
| **git-lfs**            | 大型二进制文件版本控制托管工具           |
| **git-summary**        | 仓库活跃报告生成插件                     |
| **mergiraf**           | 基于 AST 的代码冲突合并引擎              |
| **less**               | 标准命令行分页浏览器                     |
| **coreutils (gdate)**  | GNU 核心命令行系统工具集                 |
| **magick**             | 图像渲染与格式转换工具                   |
| **killport**           | 端口进程清理与终止工具                   |
| **onefetch**           | 终端 Git 仓库概览展板工具                |
| **im-select**          | 终端中英文输入法状态机自动切换组件       |
| **pip3**               | Python 包管理器                          |
| **ni**                 | 抹平各个js包管理器差异的通用执行命令     |
| **nvm**                | Node.js 版本管理器                       |
| **bun**                | 前端 JavaScript 运行时及包管理引擎       |
| **pnpm**               | 前端项目依赖包调度管理库                 |
| **prettier**           | 前端跨文件代码格式化工具                 |
| **stylua**             | Lua 语言代码格式化工具                   |
| **shfmt**              | Shell 脚本代码格式化工具                 |
| **taplo**              | TOML 配置文件格式化与校验工具            |
| **ruff**               | Python 代码静态分析与格式化工具          |
| **shellcheck**         | Shell 脚本静态语法扫描与分析工具         |
| **rust-analyzer**      | Rust 语言分析和自动补全语言服务器        |
| **nvim / neovim**      | Neovim 文本编辑器                        |
| **nvimpager**          | 基于 Neovim 的终端分页阅读器             |
| **opencode**           | 开源智能体                               |
| **gemini**             | Gemini Cli                               |
| **yuanbao**            | 腾讯元宝大语言模型                       |

### Mac App

| 工具名称               | 功能说明                           |
| :--------------------- | :--------------------------------- |
| **karabiner-elements** | macOS 系统底层键盘按键映射定制工具 |
| **alt-tab**            | 替换原生逻辑的系统窗口切换控制组件 |
| **jordanbaird-ice**    | macOS 系统顶部状态栏图标管理工具   |
| **clash-verge-rev**    | 网络出口协议流量分流及代理工具     |
| **switchhosts**        | Hosts 文件管理                     |
| **pixpin**             | 多功能截图工具                     |
| **tencent-lemon**      | macOS 系统本地垃圾缓存清理工具     |
| **wechat / qqmusic**   | 微信客户端与 QQ 音乐               |
| **google-chrome**      | Google Chrome 浏览器               |
| **firefox**            | Firefox 浏览器                     |
| **obsidian**           | Obsidian 笔记软件                  |
| **wpsoffice**          | WPS                                |
| **docker**             | Docker                             |
| **visual-studio-code** | VS Code 编辑器                     |

## 配置引用方式

为了对宿主机原生环境进行最小化侵入，可以通过以下声明在原生配置流中完成重定向接管：

```bash
# 修改宿主机的环境基准挂载目录
export ZDOTDIR="$HOME/dotfiles/zsh"

# 在末端追加入口链接
[[ -f "$ZDOTDIR/.zshrc" ]] && source "$ZDOTDIR/.zshrc"
```

同时，我们推荐在局部配置域 `~/.zshrc.local` 中挂载隐私环境变量：

```bash
export GIT_AUTHOR_NAME="YourName"
export GIT_AUTHOR_EMAIL="your@email.com"
export GIT_COMMITTER_NAME="YourName"
export GIT_COMMITTER_EMAIL="your@email.com"
```

> 提示：若执行 `git effort` 时触发异常：`/opt/homebrew/bin/git-effort: line 273:  ${nJobs@P} >= nProcs : bad substitution`，此现象根源在于 macOS 老旧组件基座(`/bin/bash` 停滞于 3.2.57)不支持现代变量展开参数 `${parameter@P}`。仅需执行指令 `brew install bash` 即可修复。
