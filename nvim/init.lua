-- Leader must be set BEFORE lazy.nvim loads any plugin that defines keymaps.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Mouse / clipboard: see notes in this file's comments below.
-- Neovim >= 0.8 defaults to mouse=nvi, which makes Neovim grab mouse events
-- and therefore disables the *terminal's* own drag-select and middle-click
-- paste. Uncomment the next line to hand the mouse back to the terminal.
-- vim.opt.mouse = ""

-- Use the system clipboard for y/p (needs wl-clipboard on Wayland, xsel on X11).
vim.opt.clipboard = "unnamedplus"

require("config.lazy")
