# Neovim Config

A minimal, modern Neovim configuration built around native LSP (Neovim 0.12+ API), [lazy.nvim](https://github.com/folke/lazy.nvim), and [Mason](https://github.com/williamboman/mason.nvim).

## Structure

```
~/.config/nvim/
├── init.lua              # Entry point — PATH setup, loads plugins + core
├── lazy-lock.json        # Pinned plugin versions
└── lua/
    ├── core/
    │   ├── init.lua      # Vim options & settings
    │   └── keymaps.lua   # General keymaps
    └── plugins/
        ├── init.lua      # Plugin declarations (lazy.nvim bootstrap)
        └── lsp.lua       # Full LSP configuration
```

## Plugins

| Plugin | Purpose |
|---|---|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | Plugin manager |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client configuration |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP server installer |
| [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) | Bridge between Mason and lspconfig |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax parsing & highlighting |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File explorer |
| [catppuccin](https://github.com/catppuccin/nvim) | Colorscheme (frappe flavour) |
| [copilot.vim](https://github.com/github/copilot.vim) | GitHub Copilot AI completion |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keymap hints popup |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Utility library |

## LSP

### Managed Servers

All LSP servers are installed and managed via Mason:

| Server | Language(s) |
|---|---|
| `lua_ls` | Lua |
| `gopls` | Go |
| `pyright` | Python |
| `terraformls` | Terraform |
| `vtsls` | JavaScript, TypeScript, JSX, TSX |
| `cucumber_language_server` | Gherkin / `.feature` files |

### Design Decisions

**Native `vim.lsp.enable()` API**

Uses the Neovim 0.12+ `vim.lsp.enable()` / `vim.lsp.config()` API rather than the conventional `lspconfig.server.setup({})` pattern. This is the forward-looking approach as Neovim absorbs more of lspconfig's responsibilities natively.

**Semantic tokens disabled**

```lua
client.server_capabilities.semanticTokensProvider = nil
```

Semantic token highlighting is disabled globally on every LSP attach. This avoids lag on large files — Treesitter handles all syntax highlighting instead.

**Mason PATH injection at startup**

```lua
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. ":" .. vim.env.PATH
```

Mason's `bin` directory is prepended to `PATH` at the very top of `init.lua`, before any plugins load. This ensures Mason-managed binaries (LSP servers, formatters, etc.) are always discoverable.

### Server Settings

**`lua_ls`** — suppresses the "undefined global `vim`" diagnostic:
```lua
settings = { Lua = { diagnostics = { globals = { "vim" } } } }
```

**`gopls`** — uses `gofumpt` for stricter formatting:
```lua
settings = { gopls = { gofumpt = true } }
```

**`vtsls`** — explicit filetype list to avoid attaching to unrelated buffers:
```lua
filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
```

**`cucumber_language_server`** — configured to pick up all feature files and JS/TS glue:
```lua
settings = {
    cucumber = {
        features = { "**/*.feature" },
        glue = { "**/*.js", "**/*.ts" },
    }
}
```

### Format on Save

A `BufWritePre` autocmd runs on `*.go`, `*.py`, `*.lua`, `*.tf`, `*.js`, `*.jsx`, `*.ts`, `*.tsx`, `*.feature`.

Two steps fire synchronously before every save:

1. **Organize imports** — sends a `source.organizeImports` code action (Go, Python, JS, TS, JSX, TSX) with a 500 ms timeout.
2. **Format** — `vim.lsp.buf.format({ async = false, timeout_ms = 500 })`.

Cursor position is saved and restored around the whole sequence so formatting never moves the viewport.

## Keymaps

Leader key: `<Space>`

### LSP (buffer-local, active when an LSP is attached)

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gI` | Go to implementation |
| `gr` | Show references |
| `K` | Hover documentation |
| `gl` | Show line diagnostics (float) |
| `<leader>la` | Code actions |
| `<leader>lr` | Rename symbol |
| `<leader>lf` | Format buffer |

### Navigation

| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | List buffers |
| `<leader>fh` | Search help tags |

## Editor Settings

| Setting | Value |
|---|---|
| Leader | `<Space>` |
| Indentation | 4 spaces, `expandtab`, `smartindent` |
| Line numbers | Absolute (`number = true`) |
| Sign column | Always visible |
| Scroll offset | 8 lines |
| Clipboard | System clipboard (`unnamedplus`) |
| Mouse | Enabled in all modes |
| Splits | Right / below |
| Colors | `termguicolors` (24-bit) |

## Requirements

- Neovim >= 0.12
- `git` (for lazy.nvim bootstrap)
- A [Nerd Font](https://www.nerdfonts.com/) for icons in nvim-tree / which-key
- Node.js (for `vtsls`, `cucumber_language_server`, Copilot)
- Go toolchain (for `gopls`, `gofumpt`)
- Python (for `pyright`)
- Terraform (for `terraformls`)
