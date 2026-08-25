-- General editor settings.
-- Adapted from the Fedora Magazine article, with two typos corrected:
-- it wrote `vim.expandtab` and `vim.undodir`, which are no-ops -- the real
-- options live under `vim.opt`.

vim.opt.nu = true
vim.opt.relativenumber = true

-- Indentation. The article uses 4; kept at 2 to match the existing config.
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Persistent undo instead of swap/backup files (undotree reads this).
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- Use the system clipboard for y/p (wl-clipboard on Wayland, xsel on X11).
vim.opt.clipboard = "unnamedplus"

-- Neovim >= 0.8 defaults to mouse=nvi, which makes Neovim grab mouse events and
-- therefore disables the *terminal's* drag-select and middle-click paste.
-- Uncomment to hand the mouse back to the terminal.
-- vim.opt.mouse = ""

-- Escape leaves terminal-insert mode.
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { silent = true, noremap = true })
vim.keymap.set("n", "<leader><leader>term", ":belowright split | terminal<CR>",
  { noremap = true, silent = true })
