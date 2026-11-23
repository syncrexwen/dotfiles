# Dotfiles

个人 macOS 开发环境配置文件，使用 [GNU Stow](https://www.gnu.org/software/stow/) 通过符号链接进行管理。

## 目录结构

```
~/.dotfiles/
├── aerospace/         # AeroSpace 平铺窗口管理器
├── brewfiles/         # Homebrew 依赖清单 (按类别拆分)
│   ├── brewfile       #   入口 — Homebrew taps
│   ├── dev            #   CLI / 运行时 / 数据处理工具
│   ├── gui            #   图形化应用 (编辑器、浏览器、Docker 等)
│   ├── ai             #   AI 助手与本地模型工具
│   ├── fonts          #   Nerd Font 与中英文字体
│   ├── node           #   全局 npm 包
│   └── vscode         #   VS Code 插件
├── docker/            # Docker 配置
├── git/               # Git 全局配置 (.gitconfig)
├── nvim/              # Neovim (基于 LazyVim)
├── rime/              # Rime 输入法配置 (含医学词库)
├── ssh/               # SSH 主机配置
├── starship/          # Starship 命令提示符
├── vscode/            # VS Code settings / keybindings / extensions.txt
├── wallpapers/        # 壁纸
├── wezterm/           # WezTerm 终端模拟器
├── zsh/               # Zsh 配置 (.zshrc)
├── remote/            # 远程服务器一键配置
│   └── bootstrap_with_sudo.sh
├── install_vscode_extensions.sh
└── README.md
```

每个顶层目录都是一个 **Stow 包**，通过 `stow` 将其内容符号链接到 `$HOME` 的对应路径。

## 前置条件

```bash
# macOS 上安装 Homebrew 与必要工具
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow git
```

## 安装

### 一键安装

```bash
git clone https://github.com/SyncrexWen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bash quick_setup.sh
```

### 1. 克隆仓库

```bash
git clone https://github.com/SyncrexWen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. 使用 Stow 建立符号链接

逐一应用各个配置包，按需选择：

```bash
stow -d ~/.dotfiles -t ~ zsh
stow -d ~/.dotfiles -t ~ git
stow -d ~/.dotfiles -t ~ nvim
stow -d ~/.dotfiles -t ~ wezterm
stow -d ~/.dotfiles -t ~ aerospace
stow -d ~/.dotfiles -t ~ starship
stow -d ~/.dotfiles -t ~ vscode
stow -d ~/.dotfiles -t ~ rime
stow -d ~/.dotfiles -t ~ ssh
stow -d ~/.dotfiles -t ~ docker
stow -d ~/.dotfiles -t ~ wallpapers
```

或者一次性应用所有包：

```bash
stow -d ~/.dotfiles -t ~ */
```

> **注意**：一次性应用前请确保 `$HOME` 下没有同名冲突文件，否则 stow 会拒绝操作。

### 3. 安装 Homebrew 依赖

Brewfile 按类别拆分在 `brewfiles/` 目录下，按需逐类安装：

```bash
brew bundle --file=brewfiles/brewfile   # 先装 taps
brew bundle --file=brewfiles/dev        # CLI 与开发工具
brew bundle --file=brewfiles/gui        # 图形化应用
brew bundle --file=brewfiles/fonts      # 字体
brew bundle --file=brewfiles/ai         # AI 工具
brew bundle --file=brewfiles/node       # 全局 npm 包
brew bundle --file=brewfiles/vscode     # VS Code 插件
```

### 4. 安装 VS Code 插件（备用方案）

除 Brewfile 方式外，也可通过 shell 脚本安装：

```bash
chmod +x install_vscode_extensions.sh
./install_vscode_extensions.sh
```

该脚本读取 `vscode/extensions.txt` 并通过 `code --install-extension` 逐行安装。

## 服务器一键配置

以下命令仅在 x86_64 Ubuntu 服务器上执行，需要 sudo 权限。以目标用户登录运行，
不要在整个命令前加 sudo，否则用户配置会写入 root 的家目录。

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/SyncrexWen/dotfiles/main/remote/bootstrap.sh)
```

默认 profile 包含 Neovim / LazyVim。仅安装 Neovim 及其依赖：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/SyncrexWen/dotfiles/main/remote/bootstrap.sh) --only neovim
source ~/.bashrc
nvim
```

- Neovim 会复用满足 [LazyVim 要求](https://www.lazyvim.org/) 的现有版本（>= 0.11.2，带 LuaJIT），
  否则下载官方 v0.12.6 Linux x86_64 tarball，安装到用户目录，不覆盖系统包。
  官方二进制需要系统提供兼容的 glibc。
- 同时安装 Git、C 编译工具、ripgrep、fd 和 tree-sitter CLI v0.27.2。
- Bash 中先按 `Ctrl+X`，再按 `Ctrl+E`，可用 Neovim（没有则用 Vim）编辑当前命令。
  保存退出后只回填命令行，不自动执行；确认后按 Enter 执行。重新登录或 `source ~/.bashrc` 后生效。
- 配置使用官方 LazyVim starter。首次启动 `nvim` 时还需联网下载插件，完成后执行 `:LazyHealth`。
  具体语言的 LSP / 格式化器可在 `:Mason` 中按需安装，部分工具还需要 Node.js 等语言运行时。
- 已有 `~/.config/nvim` 时保留原配置；若要切换到 LazyVim，先自行备份移走原配置。
  设置了 `XDG_CONFIG_HOME` 时使用该目录下的 `nvim`。重复安装不会覆盖已有配置或删除其 `.git`。
- 通过 SSH 使用时，需要在 **Mac 客户端终端**安装并选择 Nerd Font；只在服务器安装字体不会改变
  SSH 的显示，因此服务器安装流程不包含字体。

curl 入口只下载 GitHub 上已推送的内容；本地未提交的修改不会被包含。
测试其他分支时，应同时把入口 URL 中的 `main` 和环境变量 `DOTFILES_REF` 改为该分支名。

## 包含的配置

### Shell (zsh)

- **Starship** — 定制化命令提示符（Gruvbox Dark 配色，多语言版本显示）
- **zsh-autosuggestions** — 命令自动补全建议
- **zsh-syntax-highlighting** — 命令语法高亮
- **zsh-completions** — 扩展补全定义
- **代理别名**：`walless_proxy_on` / `geph_proxy_on` / `proxy_off`
- **核心命令替换**：`ls` → `eza`、`cd` → `zoxide`、`cat` → `bat`
- **uv** 配置为仅使用系统 Python（不下载任何版本）
- **mise** 管理多语言运行时
- **conda (miniforge)** 环境管理

### 终端 & 窗口管理

| 工具                                                  | 说明                                                              |
| ----------------------------------------------------- | ----------------------------------------------------------------- |
| [WezTerm](https://wezfurlong.org/wezterm/)            | GPU 加速终端，Nord 配色，FiraMono Nerd Font，支持 vi 风格窗格导航 |
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | i3 式平铺窗口管理器，Alt+hjkl 导航，多工作区快捷键                |

### Git

- 默认分支 `main`
- 编辑器设为 Neovim
- GPG 签名提交 (`signingkey = F6706A6EE199DA4B`)
- HTTP/HTTPS 代理通过 `walless`（127.0.0.1:7897）

### 编辑器

**Neovim** — 基于 [LazyVim](https://www.lazyvim.org/) 发行版，插件通过 `lazy.nvim` 管理。

- 入口：`nvim/.config/nvim/init.lua`
- 自定义插件目录：`nvim/.config/nvim/lua/plugins/`
- 配置覆盖：`nvim/.config/nvim/lua/config/`

**VS Code** — Catppuccin Frappé 主题，语言特定格式化：

| 语言     | Formatter                        | LSP/工具     |
| -------- | -------------------------------- | ------------ |
| Python   | Ruff                             | Pylance      |
| Go       | golang.go (gofumpt)              | gopls        |
| 默认     | Prettier                         | —            |
| Astro    | astro-vscode                     | Tailwind CSS |
| Markdown | markdown-all-in-one              | —            |
| LaTeX    | LaTeX Workshop (latexmk/xelatex) | —            |

### 其他

- **SSH** — 云服务器连接配置（密钥不入库）
- **Docker** — Docker Desktop 凭证
- **壁纸** — `Pictures/Wallpapers/` 下三张壁纸

## 维护

### 更新已链接的配置

修改文件后重新 stow：

```bash
stow -R -d ~/.dotfiles -t ~ <包名>
```

### 添加新配置

1. 在仓库根目录创建新目录 `toolname/`
2. 在其内部按目标路径放置文件，例如 `toolname/.config/toolname/config.toml`
3. `stow -d ~/.dotfiles -t ~ toolname`
4. 提交到 Git

### 添加新 Homebrew 包

编辑 `brewfiles/` 下对应的类别文件，然后：

```bash
brew bundle --file=brewfiles/<file>
```

## 注意事项

- `ssh/` 目录已在 `.gitignore` 中忽略，私钥绝不入库
- WezTerm 背景图引用 `~/.wp_assets/wp2.jpg`，该文件不在本仓库中，需单独准备
- `CLAUDE.md` 为 Claude Code 上下文文件，不纳入版本管理
