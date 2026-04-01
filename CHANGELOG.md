# Changelog

## 2026-04-01

### Added
- Maintenance keymaps: `<leader>uu` (plugins), `<leader>ut` (treesitter),
  `<leader>um` (Mason), `<leader>ua` (update all)
- Man page (`neojoy.1`)
- Theme switcher with Solarized Dark option (`<leader>th` / `:Themery`)
- Cyberdream colorscheme as new default (cyberpunk dark aesthetic)
- Dashboard: theme switcher and update-all buttons on welcome page

### Changed
- Default colorscheme from Catppuccin Mocha to Cyberdream
- Fixed NEOJOY banner Y glyph on dashboard

### Fixed
- nvim-treesitter config error on every file open — updated for Neovim 0.12
  (upstream dropped legacy modules; highlighting/indentation now native)
- tree-sitter CLI upgraded from 0.20.8 to 0.26.8 (`build` subcommand support)

## 2026-02-28

### Fixed
- License corrected from MIT to GPL-3.0

### Added
- DAP debugger support (nvim-dap, dap-ui, mason-nvim-dap)

## 2026-02-25 — Initial Release

- Fast startup (<50ms), lazy-loaded via lazy.nvim
- LSP with Mason, diagnostics, hover, go-to-definition, format on save
- Completion (nvim-cmp + LuaSnip)
- Treesitter syntax highlighting and indentation
- Git integration (gitsigns, lazygit)
- Telescope with native fzf sorter
- Catppuccin Mocha colorscheme, lualine statusline
- Polish: nvim-notify, alpha dashboard, todo-comments, spectre, surround
- Override-friendly customization via `lua/config/overrides.lua`
- Pinned plugin versions, no auto-execution
- 141-test TDD suite across 9 sessions
