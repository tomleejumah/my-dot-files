# Neovim Configuration

Personal Lua-based Neovim configuration from the [Arch Linux dotfiles](https://github.com/tomleejumah/my-dot-files) repository.

## Features

- Language Server Protocol (LSP) for Java, Kotlin, JavaScript/TypeScript, Python, Go, Rust, C/C++, PHP, Lua, HTML and CSS
- Autocompletion, snippets, diagnostics, CodeLens, inlay hints and navigation
- Telescope references and search, Treesitter folding, and Conform formatting
- Custom keybindings, autosave, boilerplate helpers and TODO highlighting
- Nerd Font symbols and persistent undo

The configuration lives in `~/.config/nvim`. Its entry point is `init.lua`; LSP settings live in `lua/core/lsp.lua`.

## Requirements

- **Neovim 0.11+**: this configuration uses `vim.lsp.config()` and `vim.lsp.enable()`
- **Git**, **curl**, **unzip**, **ripgrep**, **fd**, and a terminal with true color support
- **Nerd Font** (for icons); the Arch installer installs JetBrains Mono Nerd Font
- Language runtimes for the languages you use:
  - Java: **JDK 21**, with the configured Arch path `/usr/lib/jvm/java-21-openjdk`
  - JavaScript/TypeScript: Node.js and npm
  - Python: Python 3
  - Rust: rustup and stable toolchain
  - Go: Go toolchain
  - C/C++: clang/clangd as needed
- Language servers and formatters, usually installed through **Mason** or the system package manager

The [root installer](../../install.sh) installs Neovim, common runtimes and tools, then attempts a headless `Lazy! sync`. It does not guarantee every language server and formatter is present.

## Setup

### With the Arch dotfiles installer

For a new Arch Linux machine, follow the [root README](../../README.md) and run the installer. It restores `~/.config/nvim` as part of the bare Git checkout.

### Neovim configuration only

If you do not want the entire dotfiles setup:

```bash
sudo pacman -S --needed neovim git curl unzip ripgrep fd nodejs npm jdk-openjdk
git clone https://github.com/tomleejumah/my-dot-files.git /tmp/my-dot-files
mkdir -p ~/.config
# Back up your existing configuration before replacing it:
[[ ! -e ~/.config/nvim ]] || mv ~/.config/nvim ~/.config/nvim.backup
cp -a /tmp/my-dot-files/.config/nvim ~/.config/nvim
nvim
```

The plugin manager is initialized by `lua/core/plugins.lua`. After opening Neovim, use the plugin manager's sync/install command if necessary:

```vim
:Lazy sync
```

Then inspect language server installation and health:

```vim
:Mason
:checkhealth
:LspInfo
```

`Mason` and `Lazy` commands require their corresponding plugins to be installed and loaded.

## Keybindings

The leader key is **Space**.

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find references with Telescope |
| `gt` | Go to type definition |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>wa` / `<leader>wr` | Add/remove workspace folder |
| `<leader>cl` | Run CodeLens |
| `<C-Space>` (insert) | Trigger completion |
| `<CR>` (insert) | Confirm completion |
| `<Tab>` (insert) | Expand/jump snippet if available |

Other mappings are defined in `lua/core/mappings.lua`.

## Language servers and formatting

`lua/core/lsp.lua` configures:

| Language | LSP | Formatter(s) configured |
|---|---|---|
| Java | jdtls | google-java-format |
| Kotlin | kotlin_language_server | ktlint |
| JS/TS | ts_ls | prettier |
| Python | pyright, ruff | black |
| Go | gopls | gofmt |
| Rust | rust_analyzer | rustfmt |
| C/C++ | clangd | clang-format |
| PHP | intelephense | php-cs-fixer |
| Lua | lua_ls | stylua |
| HTML/CSS | html, cssls, emmet_ls | prettier |
| XML | — | xmllint, prettier |

Formatter configuration is provided through Conform. The current configuration disables format-on-save and sets up formatting on leaving insert mode; inspect `lua/core/lsp.lua` to change that behavior.

## Troubleshooting

```bash
nvim --version
java -version
command -v node npm rg fd
```

Inside Neovim, use `:checkhealth`, `:Mason`, and `:LspInfo` to diagnose missing plugins or language servers. For Java specifically, verify the JDK path and Mason jdtls files described below.

---

## Java / jdtls configuration (advanced)

This section is intentionally last: **the current `lua/core/lsp.lua` is Arch/Linux-specific**, and the example below is guidance for making Java setup portable. It is **not** already implemented in the repository.

### Current Java assumptions

The checked-in configuration:

- Invokes `/usr/lib/jvm/java-21-openjdk/bin/java`
- Uses Mason's `~/.local/share/nvim/mason/packages/jdtls` installation
- Looks for the launcher JAR under `plugins/org.eclipse.equinox.launcher_*.jar`
- Uses `config_linux`, a Lombok agent and `~/.cache/jdtls-workspace/`
- Sets Java 21 as the default runtime

Ensure jdtls is installed through Mason and JDK 21 is available before opening a Java project.

### Making jdtls portable

Edit `~/.config/nvim/lua/core/lsp.lua` to derive paths instead of hard-coding the Arch installation:

```lua
local is_windows = vim.fn.has("win32") == 1
local is_mac = vim.fn.has("mac") == 1
local sep = is_windows and "\\" or "/"

local java_home = vim.env.JAVA_HOME
  or (is_windows and [[C:\Program Files\Java\jdk-21]])
  or (is_mac and "/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home")
  or "/usr/lib/jvm/java-21-openjdk"

local mason = vim.fn.stdpath("data") .. sep .. "mason" .. sep .. "packages" .. sep .. "jdtls"
local java_bin = java_home .. sep .. "bin" .. sep .. (is_windows and "java.exe" or "java")
local launcher = vim.fn.glob(mason .. sep .. "plugins" .. sep .. "org.eclipse.equinox.launcher_*.jar")
local config_dir = mason .. sep .. (is_windows and "config_win" or is_mac and "config_mac" or "config_linux")
local lombok = vim.env.LOMBOK_JAR or (mason .. sep .. "lombok.jar")
local workspace = vim.fn.stdpath("cache") .. sep .. "jdtls-workspace" .. sep
  .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

-- Use java_bin, launcher, config_dir, lombok and workspace
-- in the existing vim.lsp.config("jdtls", { cmd = { ... } }) block.
```

Before adapting the `cmd` block, check that the launcher JAR, Lombok agent and OS-specific configuration directory exist. For multi-JDK projects, add runtime entries only for installed JDKs and set `JAVA_HOME` (and optionally `LOMBOK_JAR`) in your environment.

This repository uses Neovim's modern `vim.lsp.config("jdtls", ...)` API. Avoid copying older `lspconfig.jdtls.setup(...)` examples without adapting them.
