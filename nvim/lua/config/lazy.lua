-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  "nvim-lua/plenary.nvim",
  { "nvim-treesitter/nvim-treesitter", branch = "main", build = ":TSUpdate" },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" }, -- lazy.nvim uses `dependencies`, not packer's `requires`
  },
  { "ThePrimeagen/harpoon", branch = "harpoon2", dependencies = { "nvim-lua/plenary.nvim" } },
  { "mbbill/undotree" },
  { "tpope/vim-fugitive" },

  -- LSP configuration
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-buffer" }, -- the article's cmp.lua uses the `buffer` source but never installs it
  { "hrsh7th/cmp-path" },
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets" },
  },
  { "mason-org/mason.nvim" },
  { "mason-org/mason-lspconfig.nvim" },

  -- Rust. rustaceanvim manages its own rust-analyzer client -- do NOT also
  -- enable rust_analyzer via mason (see after/plugin/lsp.lua exclude list).
  -- The article pins version '^4' and writes `ft = {rust}`; bare `rust` is a nil
  -- global, so that spec resolves to an empty ft list and never loads.
  { "mrcjkb/rustaceanvim", version = "^9", lazy = false },

  -- Debug adapter, used by the Rust config below.
  { "mfussenegger/nvim-dap" },

  -- Go. lsp_cfg = false so gopls is configured once, by mason/lspconfig,
  -- rather than a second time by go.nvim.
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua", "neovim/nvim-lspconfig", "nvim-treesitter/nvim-treesitter" },
    ft = { "go", "gomod" },
    config = function()
      require("go").setup({ lsp_cfg = false })
    end,
  },

  -- Colorschemes
  { "rebelot/kanagawa.nvim" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "frappe", -- latte, frappe, macchiato, mocha
        background = { light = "latte", dark = "mocha" },
        transparent_background = true,
        show_end_of_buffer = false,
        term_colors = false,
        dim_inactive = { enabled = true, shade = "dark", percentage = 0.15 },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        default_integrations = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = { enabled = true, indentscope_color = "" },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}

require("lazy").setup(plugins, {})
