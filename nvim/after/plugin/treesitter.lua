-- NOTE: rewritten for nvim-treesitter's `main` branch.
-- The article uses `require("nvim-treesitter.configs").setup{ ensure_installed, highlight }`,
-- which is the legacy `master` branch API. That module no longer exists on main:
-- parsers are installed imperatively, and highlighting is started per-buffer
-- with vim.treesitter.start() instead of a `highlight` config table.

local ok, ts = pcall(require, "nvim-treesitter")
if not ok then return end

ts.setup({})

local ensure_installed = { "lua", "python", "rust", "go", "vimdoc", "c", "bash", "json", "yaml", "markdown" }

local installed = ts.get_installed()
local missing = vim.tbl_filter(function(lang)
  return not vim.tbl_contains(installed, lang)
end, ensure_installed)

if #missing > 0 then
  ts.install(missing)
end

-- Enable highlighting + treesitter indent per buffer, skipping large files
-- (the article's 100KB guard).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("ts_highlight", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
    if not lang then
      return
    end

    local max_filesize = 100 * 1024
    local stat_ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
    if stat_ok and stats and stats.size > max_filesize then
      return
    end

    if pcall(vim.treesitter.start, buf, lang) then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
