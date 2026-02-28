# NeoJoy

A fast, modular Neovim distribution. In honor of Bill Joy.

> *Bill Joy wrote vi, co-founded Sun Microsystems, and shaped the UNIX tools
> that developers still reach for every day. NeoJoy is named for his legacy.*

## Features

- **Fast startup** — target <50ms; everything lazy-loaded by default
- **LSP** — Mason server management, diagnostics, hover, go-to-definition, format on save
- **Completion** — nvim-cmp with LSP, buffer, path, and snippet sources (LuaSnip)
- **Treesitter** — syntax highlighting and indentation for all major languages
- **Git** — gitsigns in the gutter, lazygit integration, hunk navigation
- **Fuzzy finding** — Telescope with native fzf sorter
- **UI** — catppuccin mocha colorscheme, lualine statusline, which-key discovery
- **Polish** — nvim-notify, alpha dashboard, todo-comments, spectre, surround
- **Override-friendly** — extend without forking via `lua/config/overrides.lua`
- **Security-conscious** — pinned plugin versions, no auto-execution on file open

## Requirements

- Neovim >= 0.9
- Git
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- `make` and a C compiler (for telescope-fzf-native)
- Optional: `lazygit` for the lazygit integration

## Installation

> **Note:** NeoJoy uses `NVIM_APPNAME` for isolation and will not interfere
> with an existing Neovim configuration.

```bash
# Clone to your config directory
git clone https://github.com/[tbd]/neojoy ~/.config/neojoy

# Launch with the NeoJoy appname
NVIM_APPNAME=neojoy nvim
```

On first launch, lazy.nvim will install all plugins automatically.

### Shell alias (recommended)

```bash
alias nj='NVIM_APPNAME=neojoy nvim'
```

## Customization

Edit `lua/config/overrides.lua` to adjust options and keymaps without forking:

```lua
-- lua/config/overrides.lua
vim.opt.relativenumber = false
vim.keymap.set("n", "<leader>x", ":MyCommand<cr>", { desc = "My command" })
```

To add plugins, create a file in `lua/plugins/extras/` — lazy.nvim picks it
up automatically on next launch.

## Key Bindings

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>gg` | LazyGit |
| `<C-\>` | Toggle terminal |
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<C-h/j/k/l>` | Window navigation |
| `jk` | Exit insert mode |

## Structure

```
~/.config/neojoy/
├── init.lua                  # Entry point
├── lazy-lock.json            # Pinned plugin versions
├── lua/
│   ├── core/
│   │   ├── lazy.lua          # Plugin manager bootstrap
│   │   ├── options.lua       # Editor options
│   │   ├── keymaps.lua       # Global keymaps
│   │   └── autocmds.lua      # Autocommands
│   ├── plugins/
│   │   ├── lsp.lua           # Mason + nvim-lspconfig
│   │   ├── completion.lua    # nvim-cmp + LuaSnip
│   │   ├── treesitter.lua    # Syntax and indentation
│   │   ├── git.lua           # gitsigns + lazygit + toggleterm
│   │   ├── navigation.lua    # Telescope + which-key
│   │   ├── ui.lua            # Colorscheme + statusline
│   │   ├── polish.lua        # Notifications, dashboard, QoL
│   │   └── extras/           # Your additional plugins
│   └── config/
│       ├── lsp.lua           # LSP on_attach and server config
│       └── overrides.lua     # Your customizations
└── tests/
    └── session*_test.sh      # TDD test suite
```

## Security

Plugin versions are pinned in `lazy-lock.json` to specific commit hashes.
Updates require an explicit `:Lazy update` followed by review and re-commit
of the lockfile. See the [security plan](docs/) for full details.

## License

MIT
