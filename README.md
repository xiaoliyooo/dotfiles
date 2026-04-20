# Xiaoli's Dotfiles

一套面向 `macOS` 的个人开发环境配置，核心目标是：**更快启动、更少摩擦、更顺手的终端工作流**。

它主要围绕 `Zsh`、`Neovim`、`Git` 和一组现代化 CLI 工具展开，适合长期把终端当作主工作台的开发者。

## 这套配置适合谁

- 希望把日常开发、Git 操作和系统管理尽量收敛到终端里
- 已经或准备使用 `Zsh`、`Neovim`、`Git` 作为主工作流
- 喜欢现代 CLI 工具，但不想手动逐个安装、组装和维护
- 需要一套可直接接管宿主机环境、同时保留本地私有配置的 dotfiles

不太适合：

- 只想拿来即用、但不希望修改 `~/.zshrc` 的用户
- 主要使用非 `macOS` 环境，且不打算自行裁剪安装脚本
- 不依赖终端工作流，或更偏好图形界面工具链

## 你能得到什么

- **打开终端就能进入工作状态**：Shell、补全、主题和常用 CLI 会被一次性接好
- **更快找到目录、命令和文件**：`zoxide`、`atuin`、`fzf`、`yazi` 负责常见检索链路
- **更容易看清真实代码变更**：`delta`、`difftastic`、`mergiraf` 改善 diff 与冲突处理体验
- **保留本地私密信息而不污染仓库**：`~/.zshrc.local` 与 `~/.gitconfig.local` 用来承接环境变量和身份信息

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/xiaoliyooo/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. 准备本地私有配置

首次安装前，只需要知道两件事：

- `~/.zshrc.local`：放本机环境变量、私有 PATH、API Key
- `~/.gitconfig.local`：放 Git 用户名和邮箱

安装脚本会自动创建这两个文件的模板，你后续按需补充即可。

### 3. 运行安装脚本

```bash
bash install.sh
```

`install.sh` 会完成这些事情：

- 安装 `Homebrew`、`Rust`、`nvm`、`pip3` 等基础依赖
- 安装常用 CLI、字体、部分 macOS App
- 创建并链接 `~/.gitconfig`、`~/.config/*` 等配置文件
- 初始化 `~/.zshrc.local` 和 `~/.gitconfig.local`
- 安装 `zinit` 插件和 `yazi` 插件

### 4. 接管 Zsh 启动入口

在你原本的 `~/.zshrc` 末尾追加：

```bash
export ZDOTDIR="$HOME/dotfiles/zsh"
[[ -f "$ZDOTDIR/.zshrc" ]] && source "$ZDOTDIR/.zshrc"
```

这样宿主机只保留一个很薄的入口层，主要配置都由本仓库接管。

## 本地私有配置

这套配置默认把**可提交的公共配置**与**只保留在本机的私有信息**拆开处理。

### `~/.zshrc.local`

用于放置本地环境变量或私有路径，例如：

```bash
export PATH="$HOME/.local/bin:$PATH"
# export OPENAI_API_KEY="your_api_key"
```

安装脚本会自动创建该文件，`zsh/.zshrc` 启动时也会主动加载它。

### `~/.gitconfig.local`

用于放置 Git 身份信息：

```bash
[user]
  name = Your Name
  email = your@email.com
```

仓库内的 `git/gitconfig` 会通过 `include.path = ~/.gitconfig.local` 自动引用它。

## 核心工作流

### 跳转、搜索与文件浏览

- `zoxide`：替代频繁的 `cd`
- `atuin`：接管历史命令搜索
- `fzf`：模糊筛选入口
- `yazi`：终端文件管理器

这组工具组合在一起，解决的是“目录太多、命令太散、文件难找”的问题。

### Git 增强

- `delta`：让 `git diff` 更容易阅读
- `difftastic`：基于语法树查看真实代码变动
- `mergiraf`：提升冲突合并体验
- `git-absorb`：把零散修改自动吸附回相关提交
- `git-imerge`：适合处理复杂冲突场景
- `lazygit`：提供 TUI 形式的 Git 操作面板

这部分不是单纯堆工具，而是在优化两个高频痛点：**看清变更** 和 **处理历史/冲突**。

### 常用基础工具替换

| 系统习惯 | 替代工具 | 用途                   |
| :------- | :------- | :--------------------- |
| `ls`     | `eza`    | 更清晰的目录与文件展示 |
| `cat`    | `bat`    | 带语法高亮的文件查看   |
| `find`   | `fd`     | 更快的文件搜索         |
| `grep`   | `rg`     | 更快的文本检索         |

除此之外，还集成了 `btop`、`dust`、`mprocs`、`onefetch`、`killport`、`tldr` 等工具，用来覆盖资源监控、磁盘查看、多进程管理、仓库概览和日常排障。

## 仓库里实际接管了什么

安装脚本会链接或生成以下关键配置：

- `~/.gitconfig` → `git/gitconfig`
- `~/.config/lazygit/config.yml` → `lazygit/lazygit_config.yml`
- `~/.config/starship.toml` → `starship/starship.toml`
- `~/.config/yazi/*` → `yazi/*`
- `~/.config/atuin/config.toml` → `atuin/config.toml`
- `~/.lesskey` → `less/.lesskey`
- `~/.bunfig.toml` → `bun/.bunfig.toml`

如果你只是想“借用一部分配置”，可以按目录挑选，而不必整套照搬。

## 工具清单

下面列出仓库当前主要依赖，方便检索；如果你是第一次看这个项目，建议优先关注上面的“核心工作流”，而不是逐个阅读全部工具名。

### 命令行环境与核心工具

| 工具名称          | 功能说明                                |
| :---------------- | :-------------------------------------- |
| **kitty**         | GPU 加速的终端模拟器                    |
| **starship**      | 跨 Shell 的终端提示符                   |
| **vivid**         | `LS_COLORS` 颜色生成工具                |
| **carapace**      | 跨 Shell 参数补全引擎                   |
| **btop**          | 终端系统资源监控面板                    |
| **bat**           | 带有语法高亮的 `cat` 替代品             |
| **eza**           | 支持颜色和目录树渲染的 `ls` 替代品      |
| **fd**            | `find` 命令的现代替代品                 |
| **ripgrep**       | 文本正则内容检索工具                    |
| **tree**          | 目录树状图展示工具                      |
| **tldr**          | 精简版命令行社区使用手册                |
| **tokei**         | 代码行数统计分析工具                    |
| **dust**          | 命令行磁盘空间可视化工具                |
| **zinit**         | 支持异步加载的 Zsh 插件管理器           |
| **zoxide**        | 记录频率的终端目录跳转工具              |
| **atuin**         | 基于 SQLite 的全局历史命令搜索同步工具  |
| **fzf**           | 终端命令行模糊搜索器                    |
| **yazi**          | 异步的 TUI 终端文件管理器               |
| **mprocs**        | 多进程统一调度 TUI 日志面板             |
| **ttyd**          | 终端到 Web 的命令行远程接入工具         |
| **lazygit**       | 终端 TUI 模式的 Git 交互面板            |
| **delta**         | 支持语法高亮与代码块移动检查的 Git diff |
| **difftastic**    | 基于 AST 的代码语法树对比工具           |
| **git-absorb**    | 暂存区代码变更自动匹配历史 commit 工具  |
| **git-imerge**    | 针对分支冲突的渐进式合并工具            |
| **git-lfs**       | 大型二进制文件版本控制托管工具          |
| **git-summary**   | 仓库活跃报告生成插件                    |
| **mergiraf**      | 基于 AST 的代码冲突合并引擎             |
| **less**          | 标准命令行分页浏览器                    |
| **coreutils**     | GNU 核心命令行系统工具集                |
| **magick**        | 图像渲染与格式转换工具                  |
| **killport**      | 端口进程清理与终止工具                  |
| **onefetch**      | 终端 Git 仓库概览展板工具               |
| **im-select**     | 终端中英文输入法状态自动切换组件        |
| **pip3**          | Python 包管理器                         |
| **ni**            | 抹平各个 JS 包管理器差异的统一命令入口  |
| **nvm**           | Node.js 版本管理器                      |
| **bun**           | JavaScript 运行时及包管理工具           |
| **pnpm**          | 前端项目依赖包管理器                    |
| **prettier**      | 前端跨文件代码格式化工具                |
| **stylua**        | Lua 语言代码格式化工具                  |
| **shfmt**         | Shell 脚本代码格式化工具                |
| **taplo**         | TOML 配置文件格式化与校验工具           |
| **ruff**          | Python 代码静态分析与格式化工具         |
| **shellcheck**    | Shell 脚本静态语法扫描与分析工具        |
| **rust-analyzer** | Rust 语言分析和自动补全语言服务器       |
| **neovim**        | Neovim 文本编辑器                       |
| **nvimpager**     | 基于 Neovim 的终端分页阅读器            |
| **opencode**      | 开源智能体 CLI                          |
| **gemini**        | Gemini CLI                              |
| **7zz**           | 高压缩比的命令行文件归档与解压工具      |
| **has**           | 检查 PATH 中命令行工具的已安装版本      |
| **pstree**        | 进程树查看工具                          |

### Mac App

| 工具名称               | 功能说明                           |
| :--------------------- | :--------------------------------- |
| **hammerspoon**        | macOS 自动化工具                   |
| **karabiner-elements** | macOS 系统底层键盘按键映射定制工具 |
| **alt-tab**            | 替换原生逻辑的系统窗口切换控制组件 |
| **jordanbaird-ice**    | macOS 系统顶部状态栏图标管理工具   |
| **clash-verge-rev**    | 网络出口协议流量分流及代理工具     |
| **switchhosts**        | Hosts 文件管理                     |
| **tencent-lemon**      | macOS 系统本地垃圾缓存清理工具     |
| **wechat**             | 微信                               |
| **qqmusic**            | QQ 音乐                            |
| **google-chrome**      | Google Chrome 浏览器               |
| **firefox**            | Firefox 浏览器                     |
| **obsidian**           | Obsidian 笔记软件                  |
| **wpsoffice**          | WPS                                |
| **docker**             | Docker                             |
| **visual-studio-code** | VS Code 编辑器                     |
| **keystats**           | macOS 菜单栏键盘鼠标使用统计工具   |

### Dmg App

| 工具名称             | 功能说明                 |
| :------------------- | :----------------------- |
| **PopClip**          | 文本选中即时操作增强工具 |
| **Shottr**           | 截图工具                 |
| **Alfred 5**         | 快捷启动与效率工具       |
| **Bob**              | macOS 翻译和 OCR 工具    |
| **DEVONthink 3**     | 知识管理与文档数据库工具 |
| **Keyboard Maestro** | 键盘宏与自动化工具       |
| **Manico**           | 应用快速切换启动器       |
| **Moom**             | 窗口布局管理工具         |
| **ScreenBrush**      | 屏幕实时标注绘画工具     |
| **TextSniper**       | OCR 文字识别提取工具     |

## 已知问题

若执行 `git effort` 时出现：

```bash
/opt/homebrew/bin/git-effort: line 273: ${nJobs@P} >= nProcs : bad substitution
```

原因通常是 macOS 自带的 `/bin/bash` 版本过旧，不支持 `${parameter@P}` 这样的现代参数展开语法。

可通过以下命令修复：

```bash
brew install bash
```

## 说明

这份 README 侧重说明整体思路和接入方式，具体行为仍以仓库内对应目录与配置文件为准。如果你正在挑选一套可长期维护的个人终端环境，希望它既能直接用、又保留本地可定制空间，这个仓库应该会比较适合你。
