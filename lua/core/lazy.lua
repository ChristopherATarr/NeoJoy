-- NeoJoy: lazy.nvim bootstrap and setup

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  defaults = {
    lazy = true, -- async-first: all plugins lazy by default
  },
  performance = {
    rtp = {
      -- Disable unused built-in plugins for startup speed and minimal surface
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  -- Security: changes to lazy-lock.json require explicit review
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
})
