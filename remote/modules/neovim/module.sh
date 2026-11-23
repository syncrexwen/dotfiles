# shellcheck shell=bash disable=SC2034
MOD_DESC="Neovim 与 LazyVim（Ubuntu x86_64）"
MOD_APT=(git build-essential unzip)
MOD_DEPS=(base shell ripgrep)
MOD_CHECK=(nvim tree-sitter)

# apt 的 Neovim 可能太旧；LazyVim 要求 >= 0.11.2 且带 LuaJIT。
_neovim_ready() {
  nvim --clean --headless -i NONE \
    '+lua if vim.fn.has("nvim-0.11.2") == 0 or not jit then vim.cmd("cquit 1") end' \
    '+qa' >/dev/null 2>&1
}

mod_install() (
  local tmp store="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles-remote"
  tmp=$(mktemp -d) || return 1
  trap 'rm -rf "$tmp"' EXIT
  mkdir -p "$store" "$BIN" || return 1

  if ! _neovim_ready; then
    curl -fsSL --retry 3 \
      https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-linux-x86_64.tar.gz \
      -o "$tmp/nvim.tar.gz" || return 1
    tar -xzf "$tmp/nvim.tar.gz" -C "$store" || return 1
    ln -sfnT "$store/nvim-linux-x86_64/bin/nvim" "$BIN/nvim" || return 1
    hash -r
    _neovim_ready || { warn "Neovim 无法运行，请检查 Ubuntu / glibc 版本"; return 1; }
  fi

  # nvim-treesitter 需要 CLI；直接安装官方二进制，无需 npm / Rust。
  if ! tree-sitter --version 2>/dev/null | grep -E '^tree-sitter 0\.27\.2( |$)' >/dev/null; then
    curl -fsSL --retry 3 \
      https://github.com/tree-sitter/tree-sitter/releases/download/v0.27.2/tree-sitter-linux-x64.gz \
      -o "$tmp/tree-sitter.gz" || return 1
    gzip -dc "$tmp/tree-sitter.gz" > "$tmp/tree-sitter" || return 1
    chmod 755 "$tmp/tree-sitter" || return 1
    "$tmp/tree-sitter" --version >/dev/null || return 1
    install -m 755 "$tmp/tree-sitter" "$BIN/tree-sitter" || return 1
  fi
)

mod_configure() (
  local config_home="${XDG_CONFIG_HOME:-$CFG}" config tmp
  config="$config_home/nvim"
  _neovim_ready || { warn "Neovim 尚未就绪，跳过 LazyVim 配置"; return 1; }
  if [ -e "$config" ] || [ -L "$config" ]; then
    log "保留已有 Neovim 配置: $config；需要切换到 LazyVim 时请先备份移走"
    return 0
  fi

  # 先完整下载再放入配置目录，避免失败后留下半成品。
  mkdir -p "$config_home" || return 1
  tmp=$(mktemp -d "$config_home/.lazyvim.XXXXXX") || return 1
  trap 'rm -rf "$tmp"' EXIT
  git clone --depth=1 https://github.com/LazyVim/starter.git "$tmp/nvim" || return 1
  rm -rf "$tmp/nvim/.git" || return 1
  mv -T "$tmp/nvim" "$config" || return 1
  log "首次运行 nvim 会下载插件，完成后运行 :LazyHealth"
)
