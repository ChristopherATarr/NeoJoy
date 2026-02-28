-- NeoJoy — Neovim Distribution
-- In honor of Bill Joy (vi, Sun Microsystems co-founder)
-- https://github.com/[tbd]/neojoy

-- Leader must be set before lazy.nvim loads so plugins register correctly
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

require("core.lazy")
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("config.lsp").setup_diagnostics()

-- User overrides loaded last — pcall so errors here don't crash startup
pcall(require, "config.overrides")
