-- NeoJoy: core editor options

local opt = vim.opt

-- Line numbers
opt.number         = true
opt.relativenumber = true

-- Indentation
opt.expandtab    = true   -- spaces, not tabs
opt.shiftwidth   = 2
opt.tabstop      = 2
opt.softtabstop  = 2
opt.smartindent  = true

-- Display
opt.wrap        = false
opt.cursorline  = true
opt.signcolumn  = "yes"   -- always show, prevents layout shifts
opt.scrolloff   = 8
opt.sidescrolloff = 8
opt.termguicolors = true
opt.colorcolumn = "80"

-- Search
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Files
opt.undofile = true       -- persistent undo across sessions
opt.swapfile = false
opt.backup   = false

-- Performance
opt.updatetime = 250      -- faster completion / CursorHold
opt.timeoutlen = 300      -- which-key popup delay

-- Clipboard
opt.clipboard = "unnamedplus"

-- Completion
opt.completeopt = { "menuone", "noselect" }
