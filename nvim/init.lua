-- Leader must be set BEFORE lazy.nvim loads any plugin that defines keymaps.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.lazy")
require("config.settings")
